#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.6.3"

# Initialize output variables
l_output=""
l_check_issue_net=""
l_check_grep_net=""

# Function to check the contents of /etc/issue.net
check_issue_net() {
    # Check if /etc/issue.net exists
    if [ -e /etc/issue.net ]; then
        # Get the contents of /etc/issue.net
        issue_net_content=$(cat /etc/issue.net)

        # Verify if it matches the site policy (replace this with actual policy check)
        if [[ "$issue_net_content" == *"Your site policy message here"* ]]; then
            l_check_issue_net="The contents of /etc/issue.net match site policy."
        else
            l_check_issue_net="The contents of /etc/issue.net do not match site policy."
        fi
    else
        l_check_issue_net="No /etc/issue.net file found."
    fi
}

# Function to check for specific strings in /etc/issue.net
check_grep_net() {
    # Verify no results are returned for the grep command
    if [ -e /etc/issue.net ] && grep -E -i "(\\\v|\\\r|\\\m|\\\s|$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g'))" /etc/issue.net &> /dev/null; then
        l_check_grep_net="Unexpected content found in /etc/issue.net."
    else
        l_check_grep_net="No unexpected content found in /etc/issue.net."
    fi
}

# Run the checks
check_issue_net
check_grep_net

# Compile the output
l_output+="- $l_check_issue_net\n"
l_output+="- $l_check_grep_net\n"

# Determine the overall result
if [[ "$l_check_issue_net" == *"FAIL"* ]] || [[ "$l_check_grep_net" == *"FAIL"* ]]; then
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
