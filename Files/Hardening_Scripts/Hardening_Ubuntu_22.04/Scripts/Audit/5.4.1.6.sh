#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.1.6"

# Initialize output variable
output=""

# Function to check for users with last password change date in the future
CHECK_FUTURE_PASSWORD_CHANGE() {
    while IFS= read -r l_user; do
        # Get the last password change date in seconds
        l_change=$(date -d "$(sudo chage --list "$l_user" | grep '^Last password change' | cut -d: -f2 | grep -v 'never$')" +%s 2>/dev/null)

        # Check if the last change date is in the future
        if [[ -n "$l_change" && "$l_change" -gt "$(date +%s)" ]]; then
            output+="User: \"$l_user\" last password change was \"$(sudo chage --list "$l_user" | grep '^Last password change' | cut -d: -f2)\"\n"
        fi
    done < <(sudo awk -F: '$2~/^\$.+\$/{print $1}' /etc/shadow)
}

# Run the check
CHECK_FUTURE_PASSWORD_CHANGE

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ -z "$output" ]]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- No users have a future password change date."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
