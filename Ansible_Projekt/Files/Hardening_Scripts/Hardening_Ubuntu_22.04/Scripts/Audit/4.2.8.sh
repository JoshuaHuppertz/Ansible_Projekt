#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.2.8"

# Initialize output variables
l_output=""
l_output2=""

# Check for base chains and their policies
input_policy=$(nft list ruleset 2>/dev/null | grep 'hook input')
forward_policy=$(nft list ruleset 2>/dev/null | grep 'hook forward')
output_policy=$(nft list ruleset 2>/dev/null | grep 'hook output')

# Check input policy
if [[ "$input_policy" == *"policy drop;"* ]]; then
    l_output+="\n- INPUT chain policy is set to DROP:\n$input_policy"
else
    l_output2+="\n- INPUT chain policy is not set to DROP as expected:\n$input_policy"
fi

# Check forward policy
if [[ "$forward_policy" == *"policy drop;"* ]]; then
    l_output+="\n- FORWARD chain policy is set to DROP:\n$forward_policy"
else
    l_output2+="\n- FORWARD chain policy is not set to DROP as expected:\n$forward_policy"
fi

# Check output policy
if [[ "$output_policy" == *"policy drop;"* ]]; then
    l_output+="\n- OUTPUT chain policy is set to DROP:\n$output_policy"
else
    l_output2+="\n- OUTPUT chain policy is not set to DROP as expected:\n$output_policy"
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
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
