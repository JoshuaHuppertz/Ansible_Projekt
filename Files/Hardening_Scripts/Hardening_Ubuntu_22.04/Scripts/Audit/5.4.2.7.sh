#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.2.7"

# Retrieve valid shells
l_valid_shells="^($(sudo awk -F\/ '$NF != \"nologin\" {print}' /etc/shells 2>/dev/null | sed -r '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

# Check for system accounts with valid shells
output=$(sudo awk -v pat="$l_valid_shells" -F: '($1!~/^(root|halt|sync|shutdown|nfsnobody)$/ && ($3<'"$(sudo awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' || $3 == 65534) && $NF ~ pat) {print "Service account: \"" $1 "\" has a valid shell: " $7}' /etc/passwd 2>/dev/null)

# Prepare the result and write to the appropriate file
RESULT=""
if [ -z "$output" ]; then
    RESULT="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n *** PASS ***\n- All system accounts have no valid login shell.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for failure * :\n$output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
