#!/usr/bin/env bash

# Set the results directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.4.5"

# Initialize result variables
l_output=""
l_output2=""

# Permission mask
l_perm_mask="0137"
l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )) )"

# Check the configuration files
while IFS= read -r -d $'\0' l_fname; do
    l_mode=$(sudo stat -Lc '%#a' "$l_fname")
    if [ $(( "$l_mode" & "$l_perm_mask" )) -gt 0 ]; then
        l_output2+="\n- File: \"$l_fname\" has permission: \"$l_mode\"\n (should be at least \"$l_maxperm\" or more restrictive)"
    fi
done < <(sudo find /etc/audit/ -type f \( -name "*.conf" -o -name '*.rules' \) -print0 2>/dev/null)

# Check and output the result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- All audit configuration files have the required permissions: \"$l_maxperm\" or more restrictive."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
