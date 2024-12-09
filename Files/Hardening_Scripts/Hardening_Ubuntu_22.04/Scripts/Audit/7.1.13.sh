#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.1.13"

# Initialize result variables
l_output=""
l_output2=""
a_suid=(); a_sgid=()  # Arrays for SUID and SGID files

# Search through mounted filesystems
while IFS= read -r l_mount_point; do
    # Check if the mount point is not /run/usr and does not have the noexec flag
    if ! grep -Pqs '^\h*\/run\/usr\b' <<< "$l_mount_point" && ! grep -Pqs -- '\bnoexec\b' <<< "$(findmnt -krn "$l_mount_point")"; then
        # Search for SUID and SGID files
        while IFS= read -r -d $'\0' l_file; do
            if [ -e "$l_file" ]; then
                l_mode="$(stat -Lc '%#a' "$l_file")"
                [ $(( $l_mode & 04000 )) -gt 0 ] && a_suid+=("$l_file")  # Add SUID files
                [ $(( $l_mode & 02000 )) -gt 0 ] && a_sgid+=("$l_file")  # Add SGID files
            fi
        done < <(find "$l_mount_point" -xdev -type f \( -perm -2000 -o -perm -4000 \) -print0 2>/dev/null)
    fi
done <<< "$(findmnt -Derno target)"

# Check if there are any SUID files
if [ ${#a_suid[@]} -eq 0 ]; then
    l_output+="\n- No executable SUID files found on the system."
else
    l_output2+="\n- List of \"$(printf '%s' "${#a_suid[@]}")\" executable SUID files:\n$(printf '%s\n' "${a_suid[@]}")\n - End of list -\n"
fi

# Check if there are any SGID files
if [ ${#a_sgid[@]} -eq 0 ]; then
    l_output+="\n- No SGID files found on the system."
else
    l_output2+="\n- List of \"$(printf '%s' "${#a_sgid[@]}")\" executable SGID files:\n$(printf '%s\n' "${a_sgid[@]}")\n - End of list -\n"
fi

# Reminder to check the lists
[ -n "$l_output2" ] && l_output2+="\n- Review the previous lists of SUID and/or SGID files to\n- ensure no unauthorized programs have been introduced to the system.\n"

# Check the result and output it
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure of the check:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
