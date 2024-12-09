#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.2.1.1.3"

# Initialize result variables
l_output=""
l_output2=""

# Function to check log rotation settings
check_log_rotation() {
    local config_file="$1"
    local param_name="$2"
    
    param_value=$(grep -Po "^\h*$param_name\s*=\s*.*" "$config_file")
    if [ -n "$param_value" ]; then
        l_output="$l_output\n- $param_value"
    else
        l_output2="$l_output2\n- Parameter \"$param_name\" is missing in \"$config_file\""
    fi
}

# Check the main configuration file
main_config_file="/etc/systemd/journald.conf"
if [ -f "$main_config_file" ]; then
    check_log_rotation "$main_config_file" "SystemMaxUse"
    check_log_rotation "$main_config_file" "SystemKeepFree"
    check_log_rotation "$main_config_file" "RuntimeMaxUse"
    check_log_rotation "$main_config_file" "RuntimeKeepFree"
    check_log_rotation "$main_config_file" "MaxFileSec"
else
    l_output2="$l_output2\n- Configuration file \"$main_config_file\" not found."
fi

# Check configuration files in /etc/systemd/journald.conf.d/
conf_dir="/etc/systemd/journald.conf.d/"
if [ -d "$conf_dir" ]; then
    while IFS= read -r -d '' conf_file; do
        l_output="$l_output\nChecking configuration file: $conf_file"
        check_log_rotation "$conf_file" "SystemMaxUse"
        check_log_rotation "$conf_file" "SystemKeepFree"
        check_log_rotation "$conf_file" "RuntimeMaxUse"
        check_log_rotation "$conf_file" "RuntimeKeepFree"
        check_log_rotation "$conf_file" "MaxFileSec"
    done < <(find "$conf_dir" -name "*.conf" -print0)
else
    l_output2="$l_output2\n- Directory \"$conf_dir\" not found."
fi

# Check the result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- * Correctly configured * :$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for failure * :$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly configured * :\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
