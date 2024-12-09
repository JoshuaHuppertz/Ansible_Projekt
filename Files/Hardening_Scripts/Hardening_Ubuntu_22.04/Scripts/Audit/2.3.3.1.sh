#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.3.3.1"

# Initialize output variables
l_output=""
l_output2=""
a_parlist=("^\h*(server|pool)\h+\H+")  # Patterns to check for server/pool configurations
l_chrony_config_dir="/etc/chrony"     # Chrony configuration directory

# Function to check chrony configuration
config_file_parameter_chk() {
    unset A_out
    declare -A A_out
    if [ ! -d "$l_chrony_config_dir" ]; then
        l_output2="$l_output2\n- Directory $l_chrony_config_dir does not exist"
        return
    fi

    while read -r l_out; do
        if [ -n "$l_out" ]; then
            if [[ $l_out =~ ^\s*# ]]; then
                l_file="${l_out//# /}"  # Remove comment markers
            else
                l_chrony_parameter="$(awk -F= '{print $1}' <<< "$l_out" | xargs)"
                A_out+=(["$l_chrony_parameter"]="$l_file")
            fi
        fi
    done < <(find "$l_chrony_config_dir" -name '*.conf' -exec systemd-analyze cat-config {} + | grep -Pio '^\h*([^#\n\r]+|#\h*\/[^#\n\r\h]+\.conf\b)')
    
    if (( ${#A_out[@]} > 0 )); then
        for l_chrony_parameter in "${!A_out[@]}"; do
            l_file="${A_out[$l_chrony_parameter]}"
            l_output="$l_output\n - \"$l_chrony_parameter\" is set in \"$l_file\"\n"
        done
    else
        l_output2="$l_output2\n- No 'server' or 'pool' settings found in Chrony configuration files\n"
    fi
}

# Check for chrony server/pool configurations
for l_chrony_parameter_regex in "${a_parlist[@]}"; do
    config_file_parameter_chk
done

# Prepare the result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reason(s) for audit failure:\n$l_output2\n"
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
