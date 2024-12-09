#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.6.4"

# Initialize output variables
l_output=""
l_check_motd=""

# Function to check /etc/motd file permissions and ownership
check_motd() {
    # Check if /etc/motd exists
    if [ -e /etc/motd ]; then
        # Get the file status using stat
        motd_status=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' /etc/motd)

        # Check if Access is 644 or more restrictive, and if Uid and Gid are both 0/root
        if [[ "$motd_status" == "Access: (0644/-rw-r--r--) Uid: ( 0/ root) Gid: ( 0/ root)" ]]; then
            l_check_motd="The permissions and ownership of /etc/motd are correct."
        else
            l_check_motd="The actual status of /etc/motd is:\n$motd_status"
        fi
    else
        l_check_motd="No /etc/motd file found."
    fi
}

# Run the check
check_motd

# Compile the output
l_output+="- $l_check_motd\n"

# Determine the overall result
if [[ "$l_check_motd" == *"FAIL"* ]]; then
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
