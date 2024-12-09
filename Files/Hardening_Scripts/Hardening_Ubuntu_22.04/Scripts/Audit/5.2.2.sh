#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.2.2"

# Initialize output variables
l_output=""
l_output2=""

# Function to check sudo configuration for use_pty
CHECK_USE_PTY() {
    # Check if Defaults use_pty is set (using quiet mode to suppress output)
    if sudo grep -qP '^\s*Defaults\s+([^#\n\r]+,)?use_pty(,\s*)*(#.*)?$' /etc/sudoers; then
        l_output+="- /etc/sudoers: Defaults use_pty is set.\n"
    else
        l_output2+="- /etc/sudoers: Defaults use_pty is not set.\n"
    fi

    # Check if Defaults !use_pty is set, which is not allowed (using quiet mode)
    if sudo grep -qP '^\s*Defaults\s+([^#\n\r]+,)?!use_pty(,\s*)*(#.*)?$' /etc/sudoers; then
        l_output2+="- /etc/sudoers: Defaults !use_pty is set, which is not allowed.\n"
    fi

    # Check sudoers.d directory for individual configuration files
    for sudo_file in /etc/sudoers.d/*; do
        if [ -f "$sudo_file" ]; then
            if sudo grep -qP '^\s*Defaults\s+([^#\n\r]+,)?use_pty(,\s*)*(#.*)?$' "$sudo_file"; then
                l_output+="- $sudo_file: Defaults use_pty is set.\n"
            else
                l_output2+="- $sudo_file: Defaults use_pty is not set.\n"
            fi

            if sudo grep -qP '^\s*Defaults\s+([^#\n\r]+,)?!use_pty(,\s*)*(#.*)?$' "$sudo_file"; then
                l_output2+="- $sudo_file: Defaults !use_pty is set, which is not allowed.\n"
            fi
        fi
    done
}

# Perform the check
CHECK_USE_PTY

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [ -z "$l_output2" ]; then
    RESULT+="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
