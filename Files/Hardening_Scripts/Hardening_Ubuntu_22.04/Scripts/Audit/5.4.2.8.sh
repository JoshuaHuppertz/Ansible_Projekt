#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.2.8"

# Retrieve valid shells
l_valid_shells="^($(awk -F\/ '$NF != \"nologin\" {print}' /etc/shells 2>/dev/null | sed -r '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

# Check all non-root accounts without valid shells
output=""
while IFS= read -r l_user; do
    # Check if the account is locked and suppress passwd errors
    result=$(passwd -S "$l_user" 2>/dev/null | awk '$2 !~ /^L/ {print "Account: \"" $1 "\" does not have a valid login shell and is not locked"}')
    if [ -n "$result" ]; then
        output+="$result\n"
    fi
done < <(awk -v pat="$l_valid_shells" -F: '($1 != "root" && $(NF) !~ pat) {print $1}' /etc/passwd)

# Prepare the result and write to the appropriate file
RESULT=""
if [ -z "$output" ]; then
    RESULT="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n *** PASS ***\n- All non-root accounts without a valid login shell are locked.\n"
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
