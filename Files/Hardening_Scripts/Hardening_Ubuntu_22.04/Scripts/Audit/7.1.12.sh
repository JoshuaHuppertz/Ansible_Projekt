#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.1.12"

# Initialize result variables
l_output=""
l_output2=""
a_nouser=()  # Array for files with no owner
a_nogroup=() # Array for files with no group

# Define path exclusion patterns
a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path \
"*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path \
"*/kubelet/plugins/*" -a ! -path "/sys/fs/cgroup/memory/*" -a ! -path \
"/var/*/private/*")

# Search mounted filesystems
while IFS= read -r l_mount; do
    # Search for files or directories with no owner or group
    while IFS= read -r -d $'\0' l_file; do
        if [ -e "$l_file" ]; then
            while IFS=: read -r l_user l_group; do
                [ "$l_user" = "UNKNOWN" ] && a_nouser+=("$l_file")   # Add files with no owner
                [ "$l_group" = "UNKNOWN" ] && a_nogroup+=("$l_file") # Add files with no group
            done < <(stat -Lc '%U:%G' "$l_file")
        fi
    done < <(find "$l_mount" -xdev \( "${a_path[@]}" \) \( -type f -o -type d \) \( -nouser -o -nogroup \) -print0 2> /dev/null)
done < <(findmnt -Dkerno fstype,target | awk '($1 !~ /^\s*(nfs|proc|smb|vfat|iso9660|efivarfs|selinuxfs)/ && $2 !~ /^\/run\/user\//){print $2}')

# Check if there are files with no owner
if [ ${#a_nouser[@]} -eq 0 ]; then
    l_output+="\n- No files or directories with no owner found on the local filesystem."
else
    l_output2+="\n- There are \"${#a_nouser[@]}\" files or directories with no owner on the system.\n - The following files and/or directories have no owner:\n$(printf '%s\n' "${a_nouser[@]}")\n - End of list"
fi

# Check if there are files with no group
if [ ${#a_nogroup[@]} -eq 0 ]; then
    l_output+="\n- No files or directories with no group found on the local filesystem."
else
    l_output2+="\n- There are \"${#a_nogroup[@]}\" files or directories with no group on the system.\n - The following files and/or directories have no group:\n$(printf '%s\n' "${a_nogroup[@]}")\n - End of list"
fi

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
