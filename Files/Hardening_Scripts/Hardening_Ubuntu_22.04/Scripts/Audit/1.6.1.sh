#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.6.1"

# Initialize output variables
l_output=""
l_check_motd=""
l_check_grep=""

# Function to check the contents of /etc/motd
check_motd() {
    # Check if /etc/motd exists
    if [ -e /etc/motd ]; then
        # Get the contents of /etc/motd
        motd_content=$(cat /etc/motd)

        # Verify if it matches the site policy (you should replace this condition with the actual policy check)
        if [[ "$motd_content" == *"Your site policy message here"* ]]; then
            l_check_motd="The contents of /etc/motd match site policy."
        else
            l_check_motd="The contents of /etc/motd do not match site policy."
        fi
    else
        l_check_motd="No /etc/motd file found."
    fi
}

# Function to check for specific strings in /etc/motd
check_grep() {
    # Verify no results are returned for the grep command
    if grep -E -i "(\\\v|\\\r|\\\m|\\\s|$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g'))" /etc/motd &> /dev/null; then
        l_check_grep="Unexpected content found in /etc/motd."
    else
        l_check_grep="No unexpected content found in /etc/motd."
    fi
}

# Run the checks
check_motd
check_grep

# Compile the output
l_output+="- $l_check_motd\n"
l_output+="- $l_check_grep\n"

# Determine the overall result
if [[ "$l_check_motd" == *"FAIL"* ]] || [[ "$l_check_grep" == *"FAIL"* ]]; then
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
