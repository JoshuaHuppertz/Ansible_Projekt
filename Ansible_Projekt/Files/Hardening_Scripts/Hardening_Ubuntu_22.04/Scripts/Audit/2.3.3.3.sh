#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.3.3.3"

# Initialize output variables
is_enabled=""
is_active=""

# Check if chrony.service is enabled
if systemctl is-enabled chrony.service &>/dev/null; then
    is_enabled="chrony.service is enabled."
else
    is_enabled="chrony.service is not enabled."
fi

# Check if chrony.service is active
if systemctl is-active chrony.service &>/dev/null; then
    is_active="chrony.service is active."
else
    is_active="chrony.service is not active."
fi

# Prepare the result report
RESULT=""
failures=()

# Check results and prepare output
if [[ "$is_enabled" == *"not enabled"* ]]; then
    failures+=("$is_enabled")
fi

if [[ "$is_active" == *"not active"* ]]; then
    failures+=("$is_active")
fi

if [ ${#failures[@]} -eq 0 ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- $is_enabled\n - $is_active\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    for failure in "${failures[@]}"; do
        RESULT+="- $failure\n"
    done
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"