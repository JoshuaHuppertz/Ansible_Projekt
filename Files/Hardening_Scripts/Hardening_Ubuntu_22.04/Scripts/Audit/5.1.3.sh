#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.3"

# Initialize output variables
l_output=""
l_output2=""
l_pmask="0133" 
l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"

# Function to check SSH public key files
FILE_CHK() {
    while IFS=: read -r l_file_mode l_file_owner l_file_group; do
        l_out2=""
        if [ $(( l_file_mode & l_pmask )) -gt 0 ]; then
            l_out2="$l_out2\n- Mode: \"$l_file_mode\" should be mode: \"$l_maxperm\" or more restrictive"
        fi
        if [ "$l_file_owner" != "root" ]; then
            l_out2="$l_out2\n- Owned by: \"$l_file_owner\" should be owned by \"root\""
        fi
        if [ "$l_file_group" != "root" ]; then
            l_out2="$l_out2\n- Owned by group \"$l_file_group\" should be group owned by group: \"root\""
        fi
        
        if [ -n "$l_out2" ]; then
            l_output2="$l_output2\n- File: \"$l_file\"$l_out2"
        else
            l_output="$l_output\n- File: \"$l_file\"\n- Correct: mode: \"$l_file_mode\", owner: \"$l_file_owner\", and group owner: \"$l_file_group\" configured"
        fi
    done < <(stat -Lc '%#a:%U:%G' "$l_file")
}

# Find and check SSH public key files
while IFS= read -r -d $'\0' l_file; do
    if ssh-keygen -lf &>/dev/null "$l_file"; then
        if file "$l_file" | grep -Piq -- '\bopenssh\h+([^#\n\r]+\h+)?public\h+key\b'; then
            FILE_CHK
        fi
    fi
done < <(find -L /etc/ssh -xdev -type f -print0 2>/dev/null)

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    [ -z "$l_output" ] && l_output="\n- No openSSH public keys found"
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure *:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
