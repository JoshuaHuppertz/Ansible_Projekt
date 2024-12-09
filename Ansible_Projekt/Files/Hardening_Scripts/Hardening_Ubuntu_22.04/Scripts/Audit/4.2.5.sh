#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.2.5"

# Initialize output variables
l_output=""
l_output2=""

# Check for nftables base chains
input_chain=$(nft list ruleset 2>/dev/null | grep -E 'hook input')
forward_chain=$(nft list ruleset 2>/dev/null | grep -E 'hook forward')
output_chain=$(nft list ruleset 2>/dev/null | grep -E 'hook output')

# Verify that each required chain exists
if [[ -n "$input_chain" ]]; then
    l_output+="\n- INPUT base chain is present:\n$input_chain"
else
    l_output2+="\n- INPUT base chain is missing"
fi

if [[ -n "$forward_chain" ]]; then
    l_output+="\n- FORWARD base chain is present:\n$forward_chain"
else
    l_output2+="\n- FORWARD base chain is missing"
fi

if [[ -n "$output_chain" ]]; then
    l_output+="\n- OUTPUT base chain is present:\n$output_chain"
else
    l_output2+="\n- OUTPUT base chain is missing"
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Correctly set:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
