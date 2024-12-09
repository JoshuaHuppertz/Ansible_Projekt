#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.4.2"

# Initialize result variables
l_output=""
l_output2=""

# Search for the auditd.conf file dynamically
AUDIT_CONF_PATH=$(sudo find /etc -type f -name "auditd.conf" 2>/dev/null)

# Debugging: Log the result of the find command
#echo "Searching for auditd.conf..."

# Check if the auditd.conf file was found
if [ -n "$AUDIT_CONF_PATH" ]; then
    #echo "auditd.conf found at $AUDIT_CONF_PATH. Proceeding with configuration check."

    # Read the log directory from the configuration file
    l_audit_log_directory="$(dirname "$(sudo awk -F= '/^\s*log_file\s*/{print $2}' "$AUDIT_CONF_PATH" | xargs)")"

    # If log directory is not set in the configuration, fall back to default directory
    if [ -z "$l_audit_log_directory" ]; then
        l_audit_log_directory="/var/log/audit"
    fi

    #echo "Using log directory: $l_audit_log_directory"

    # Check if the directory exists
    if [ -d "$l_audit_log_directory" ]; then
        # Find files that are not owned by the user "root"
        while IFS= read -r -d $'\0' l_file; do
            l_output2+="\n - File: \"$l_file\" is owned by user: \"$(sudo stat -Lc '%U' "$l_file")\"\n (should be owned by user: \"root\")\n"
        done < <(sudo find "$l_audit_log_directory" -maxdepth 1 -type f ! -user root -print0 2>/dev/null)

        # Check if no files were found
        if [ -z "$l_output2" ]; then
            l_output+="\n- All files in the directory \"$l_audit_log_directory\" are owned by user: \"root\"\n"
        fi
    else
        l_output2+="\n- ** FAIL **\n- The log directory \"$l_audit_log_directory\" does not exist."
    fi
else
    # If the file was not found, output failure message and log the error
    echo "auditd.conf not found! Please check if auditd is installed and configured."
    l_output2+="\n- ** FAIL **\n- File: \"/etc/audit/auditd.conf\" not found.\n- ** Please check if auditd is installed **"
fi

# Check and output the result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
