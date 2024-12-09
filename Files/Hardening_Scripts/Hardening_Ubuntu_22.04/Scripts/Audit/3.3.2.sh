#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="3.3.2"

# Initialize output variables
l_output=""
l_output2=""
a_parlist=("net.ipv4.conf.all.send_redirects=0" "net.ipv4.conf.default.send_redirects=0")

kernel_parameter_chk() {
    l_krp="$(sysctl "$l_kpname" | awk -F= '{print $2}' | xargs)" # Check running configuration
    if [ "$l_krp" = "$l_kpvalue" ]; then
        l_output="$l_output\n- \"$l_kpname\" is correctly set to \"$l_krp\" in the running configuration"
    else
        l_output2="$l_output2\n- \"$l_kpname\" is incorrectly set to \"$l_krp\" in the running configuration and should have a value of: \"$l_kpvalue\""
    fi

    # Check durable setting (files)
    unset A_out; declare -A A_out
    while read -r l_out; do
        if [ -n "$l_out" ]; then
            if [[ $l_out =~ ^\s*# ]]; then
                l_file="${l_out//# /}"
            else
                l_kpar="$(awk -F= '{print $1}' <<< "$l_out" | xargs)"
                [ "$l_kpar" = "$l_kpname" ] && A_out+=(["$l_kpar"]="$l_file")
            fi
        fi
    done < <(/usr/lib/systemd/systemd-sysctl --cat-config | grep -Po '^\h*([^#\n\r]+|#\h*\/[^#\n\r\h]+\.conf\b)')

    if [ -n "$l_ufwscf" ]; then # Account for systems with UFW (Not covered by systemd-sysctl -cat-config)
        l_kpar="$(grep -Po "^\h*$l_kpname\b" "$l_ufwscf" | xargs)"
        l_kpar="${l_kpar//\//.}"
        [ "$l_kpar" = "$l_kpname" ] && A_out+=(["$l_kpar"]="$l_ufwscf")
    fi

    if (( ${#A_out[@]} > 0 )); then
        # Assess output from files and generate output
        while IFS="=" read -r l_fkpname l_fkpvalue; do
            l_fkpname="${l_fkpname// /}"; l_fkpvalue="${l_fkpvalue// /}"
            if [ "$l_fkpvalue" = "$l_kpvalue" ]; then
                l_output="$l_output\n- \"$l_kpname\" is correctly set to \"$l_fkpvalue\" in \"$(printf '%s' "${A_out[@]}")\""
            else
                l_output2="$l_output2\n- \"$l_kpname\" is incorrectly set to \"$l_fkpvalue\" in \"$(printf '%s' "${A_out[@]}")\" and should have a value of: \"$l_kpvalue\""
            fi
        done < <(grep -Po -- "^\h*$l_kpname\h*=\h*\H+" "${A_out[@]}")
    else
        l_output2="$l_output2\n- \"$l_kpname\" is not set in an included file\n ** Note: \"$l_kpname\" May be set in a file that's ignored by load procedure **"
    fi
}

# Read and check parameters
while IFS="=" read -r l_kpname l_kpvalue; do
    l_kpname="${l_kpname// /}"; l_kpvalue="${l_kpvalue// /}"
    # Check if IPv6 is enabled
    if ! grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable && grep -q '^net.ipv6.' <<< "$l_kpname"; then
        l_output="$l_output\n- IPv6 is disabled on the system, \"$l_kpname\" is not applicable"
    else
        kernel_parameter_chk
    fi
done < <(printf '%s\n' "${a_parlist[@]}")

# Prepare the final result
RESULT=""

# Provide output from checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
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
