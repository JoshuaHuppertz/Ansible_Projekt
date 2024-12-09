#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.4.3"

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

    # Check if the log_group parameter is set to adm or root
    log_group_output=$(grep -Piws -- '^\h*log_group\h*=\h*\H+\b' "$AUDIT_CONF_PATH" | grep -Pvi -- '(adm|root)')

    # Check if the command produces any output
    if [ -n "$log_group_output" ]; then
        l_output2+="\n- ** FAIL **\n - The log_group parameter is not correctly set. It should be set to \"adm\" or \"root\".\n"
    fi

    # Read the log directory from the configuration file
    l_fpath="$(dirname "$(sudo awk -F "=" '/^\s*log_file/ {print $2}' "$AUDIT_CONF_PATH" | xargs)")"
    
    # Check if the directory exists
    if [ -d "$l_fpath" ]; then
        # Find files that are not owned by group "root" or "adm"
        while IFS= read -r -d $'\0' l_file; do
            l_output2+="\n - File: \"$l_file\" is not owned by group \"root\" or \"adm\""
        done < <(sudo find -L "$l_fpath" -not -path "$l_fpath"/lost+found -type f \( ! -group root -a ! -group adm \) -print0 2>/dev/null)
        
        # Check if no files were found
        if [ -z "$l_output2" ]; then
            l_output+="\n- All files in the directory \"$l_fpath\" are owned by group \"root\" or \"adm\""
        fi
    else
        l_output2+="\n- ** FAIL **\n- The log directory \"$l_fpath\" does not exist. Please specify the directory in \"/etc/audit/auditd.conf\"."
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
