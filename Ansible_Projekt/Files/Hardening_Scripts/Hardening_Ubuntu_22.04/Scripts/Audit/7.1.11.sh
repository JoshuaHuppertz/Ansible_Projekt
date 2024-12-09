#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.1.11"

# Initialize result variables
l_output=""
l_output2=""

# Arrays to store results
a_file=()  # World-writable files
a_dir=()   # World-writable directories without sticky bit

# Define path exclusion patterns
a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path \
"*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path \
"*/kubelet/plugins/*" -a ! -path "/sys/*" -a ! -path "/snap/*")

# Search mounted filesystems
while IFS= read -r l_mount; do
    # Search for world-writable files and directories
    while IFS= read -r -d $'\0' l_file; do
        if [ -e "$l_file" ]; then
            [ -f "$l_file" ] && a_file+=("$l_file")  # Add world-writable files
            if [ -d "$l_file" ]; then  # Add directories without sticky bit
                l_mode="$(stat -Lc '%#a' "$l_file")"
                if [ ! $(( l_mode & 01000 )) -gt 0 ]; then  # Check if sticky bit is set
                    a_dir+=("$l_file")
                fi
            fi
        fi
    done < <(find "$l_mount" -xdev \( "${a_path[@]}" \) \( -type f -o -type d \) -perm -0002 -print0 2> /dev/null)
done < <(findmnt -Dkerno fstype,target | awk '($1 !~ /^\s*(nfs|proc|smb|vfat|iso9660|efivarfs|selinuxfs)/ && $2 !~ /^(\/run\/user\/|\/tmp|\/var\/tmp)/){print $2}')

# Check if there are world-writable files
if [ ${#a_file[@]} -eq 0 ]; then
    l_output+="\n- No world-writable files found on the local filesystem."
else
    l_output2+="\n- There are \"${#a_file[@]}\" world-writable files on the system.\n - The following files are world-writable:\n$(printf '%s\n' "${a_file[@]}")\n - End of list\n"
fi

# Check if there are world-writable directories without sticky bit
if [ ${#a_dir[@]} -eq 0 ]; then
    l_output+="\n- The sticky bit is set on all world-writable directories on the local filesystem."
else
    l_output2+="\n- There are \"${#a_dir[@]}\" world-writable directories without the sticky bit on the system.\n - The following directories are world-writable without sticky bit:\n$(printf '%s\n' "${a_dir[@]}")\n - End of list\n"
fi

# Check the result and output it
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for the failure of the check:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
