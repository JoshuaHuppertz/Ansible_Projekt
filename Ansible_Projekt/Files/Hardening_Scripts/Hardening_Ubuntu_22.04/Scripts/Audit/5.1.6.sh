#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.6"

# Initialize output variables
l_output=""
l_output2=""

# Function to check weak ciphers in SSHD configuration
CHECK_WEAK_CIPHERS() {
    local cipher_output
    cipher_output=$(sshd -T 2>/dev/null | grep -Pi 'ciphers\s+"?([^#\n\r]+,)?(3des|blowfish|cast128|aes(128|192|256)-cbc|arcfour(128|256)?|rijndael-cbc@lysator\.liu\.se|chacha20-poly1305@openssh\.com)\b')

    if [ -n "$cipher_output" ]; then
        l_output+="\n- Weak ciphers found:\n$cipher_output\n"
    else
        l_output+="\n- No weak ciphers found in SSHD settings.\n"
    fi
}

# Perform the check
CHECK_WEAK_CIPHERS

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$l_output" | grep -q 'Weak ciphers found'; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"