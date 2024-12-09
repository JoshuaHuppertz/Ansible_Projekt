#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.6.2"

# Initialize output variables
l_output=""
l_check_issue=""
l_check_grep=""

# Function to check the contents of /etc/issue
check_issue() {
    # Check if /etc/issue exists
    if [ -e /etc/issue ]; then
        # Get the contents of /etc/issue
        issue_content=$(cat /etc/issue)

        # Verify if it matches the site policy (you should replace this condition with the actual policy check)
        if [[ "$issue_content" == *"Your site policy message here"* ]]; then
            l_check_issue="The contents of /etc/issue match site policy."
        else
            l_check_issue="The contents of /etc/issue do not match site policy."
        fi
    else
        l_check_issue="No /etc/issue file found."
    fi
}

# Function to check for specific strings in /etc/issue
check_grep() {
    # Verify no results are returned for the grep command
    if grep -E -i "(\\\v|\\\r|\\\m|\\\s|$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g'))" /etc/issue &> /dev/null; then
        l_check_grep="Unexpected content found in /etc/issue."
    else
        l_check_grep="No unexpected content found in /etc/issue."
    fi
}

# Run the checks
check_issue
check_grep

# Compile the output
l_output+="- $l_check_issue\n"
l_output+="- $l_check_grep\n"

# Determine the overall result
if [[ "$l_check_issue" == *"FAIL"* ]] || [[ "$l_check_grep" == *"FAIL"* ]]; then
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