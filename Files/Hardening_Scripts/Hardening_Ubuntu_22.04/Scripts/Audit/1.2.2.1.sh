#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.2.2.1"

# Initialize output variable
l_output=""
l_update_check=""
l_upgrade_check=""

# Run the command to check for updates
l_update_check=$(apt update 2>&1)

# Run the command to check for available upgrades
l_upgrade_check=$(apt -s upgrade 2>&1)

# Check if there are updates or patches to install
if echo "$l_upgrade_check" | grep -q 'upgraded'; then
    l_output+="\n- There are updates available for installation:\n$l_upgrade_check"
else
    l_output+="\n- No updates or patches to install."
fi

# Prepare result report
if [[ "$l_output" == *"There are updates available for installation:"* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
