#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.2.7"

# Initialize output variables
l_output=""
group_name=""
group_check=""

# Function to check pam_wheel configuration
CHECK_PAM_WHEEL() {
    # Check for pam_wheel configuration in /etc/pam.d/su
    output=$(sudo grep -Pi '^\h*auth\h+(?:required|requisite)\h+pam_wheel\.so' /etc/pam.d/su)
    if [ -n "$output" ]; then
        # Check if the line includes the 'group' option
        group_name=$(echo "$output" | sudo grep -oP "group=\K\H+")
        if [ -n "$group_name" ]; then
            l_output+="- pam_wheel is configured with group $group_name\n"
        else
            l_output+="- pam_wheel is configured, but no group specified.\n"
        fi
    else
        l_output+="- pam_wheel is NOT configured correctly in /etc/pam.d/su.\n"
    fi
}

# Function to check the specified group for users
CHECK_GROUP_USERS() {
    if [ -n "$group_name" ]; then
        group_check=$(sudo grep "$group_name" /etc/group)
        if [ -n "$group_check" ]; then
            # Extract the list of users in the group
            user_list=$(echo "$group_check" | awk -F: '{print $4}')
            if [ -n "$user_list" ]; then
                user_count=$(echo "$user_list" | tr ',' '\n' | wc -l)
                if [ "$user_count" -gt 0 ]; then
                    l_output+="- Group $group_name contains users: $user_list\n"
                else
                    l_output+="- Group $group_name is empty.\n"
                fi
            else
                l_output+="- No users found in group $group_name.\n"
            fi
        else
            l_output+="- Group $group_name does not exist.\n"
        fi
    fi
}

# Perform the checks
CHECK_PAM_WHEEL
CHECK_GROUP_USERS

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ $l_output == *"NOT configured correctly"* || $l_output == *"does not exist"* || $l_output == *"is empty"* || $l_output == *"No users found"* ]]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :\n$l_output"
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
