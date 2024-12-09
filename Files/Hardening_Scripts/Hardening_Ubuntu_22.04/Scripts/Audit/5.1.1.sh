#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.1"

# Initialize output variables
l_output=""
l_output2=""
perm_mask='0177'
maxperm="$( printf '%o' $(( 0777 & ~$perm_mask )) )"

# Function to check SSHD files
SSHD_FILES_CHK() {
    while IFS=: read -r l_mode l_user l_group; do
        l_out2=""
        [ $(( l_mode & perm_mask )) -gt 0 ] && l_out2="$l_out2\n- Is mode: \"$l_mode\"; should be: \"$maxperm\" or more restrictive"
        [ "$l_user" != "root" ] && l_out2="$l_out2\n- Is owned by \"$l_user\"; should be owned by \"root\""
        [ "$l_group" != "root" ] && l_out2="$l_out2\n- Is group owned by \"$l_user\"; should be group owned by \"root\""

        if [ -n "$l_out2" ]; then
            l_output2="$l_output2\n- File: \"$l_file\":$l_out2"
        else
            l_output="$l_output\n- File: \"$l_file\":\n- Correct: mode ($l_mode), owner ($l_user), and group owner ($l_group) configured"
        fi
    done < <(stat -Lc '%#a:%U:%G' "$l_file")
}

# Check main sshd_config file
if [ -e "/etc/ssh/sshd_config" ]; then
    l_file="/etc/ssh/sshd_config"
    SSHD_FILES_CHK
fi

# Check .conf files in /etc/ssh/sshd_config.d
while IFS= read -r -d $'\0' l_file; do
    [ -e "$l_file" ] && SSHD_FILES_CHK
done < <(find -L /etc/ssh/sshd_config.d -type f -name '*.conf' \( -perm /077 -o ! -user root -o ! -group root \) -print0 2>/dev/null)

# Check Include statements in the main configuration
include_files=$(awk '/^\s*Include/ {print $2}' /etc/ssh/sshd_config)
for include in $include_files; do
    if [ -d "$include" ]; then
        while IFS= read -r -d $'\0' l_file; do
            [ -e "$l_file" ] && SSHD_FILES_CHK
        done < <(find -L "$include" -type f -name '*.conf' \( -perm /077 -o ! -user root -o ! -group root \) -print0 2>/dev/null)
    fi
done

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure *:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly set *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
