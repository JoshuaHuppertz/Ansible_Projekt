#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.4.2"

# Initialize output variables
l_output=""
l_check=""

# Run the stat command and capture the output
stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' /boot/grub/grub.cfg)

# Clean up the stat_output to remove extra spaces for comparison
cleaned_stat_output=$(echo "$stat_output" | sed 's/[[:space:]]\+/ /g' | sed 's/^\s*//;s/\s*$//')

# Define the expected output string for a valid result
expected_output="Access: (0600/-rw-------) Uid: (0/root) Gid: (0/root)"

# Check if the cleaned output matches the expected output
if [[ "$cleaned_stat_output" == "$expected_output" ]]; then
    l_check="The conditions for permissions and ownership are met."
else
    l_check="The actual output is:\n$stat_output"
fi

# Compile the output
l_output+="- $l_check\n"

# Determine the overall result
if [[ "$l_check" == *"FAIL"* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the file and also display it on the console
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
