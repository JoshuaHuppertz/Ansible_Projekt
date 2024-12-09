#!/usr/bin/env bash

# Set the results directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.4.8"

# Initialize result variables
l_output=""
l_output2=""

# Permission mask
l_perm_mask="0022"

# Maximum permissions
l_maxperm="$(printf '%o' $(( 0777 & ~$l_perm_mask )))"

# Audit tools
a_audit_tools=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/augenrules"
)

# Check permissions of audit tools
for l_audit_tool in "${a_audit_tools[@]}"; do
    if [ -e "$l_audit_tool" ]; then
        l_mode="$(sudo stat -Lc '%#a' "$l_audit_tool")"
        if [ $(( "$l_mode" & "$l_perm_mask" )) -gt 0 ]; then
            l_output2+="\n- Audit tool \"$l_audit_tool\" is mode: \"$l_mode\" and should be mode: \"$l_maxperm\" or more restrictive"
        else
            l_output+="\n- Audit tool \"$l_audit_tool\" is correctly configured to mode: \"$l_mode\""
        fi
    else
        l_output2+="\n- Audit tool \"$l_audit_tool\" does not exist."
    fi
done

# Check and output result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- * Correctly configured *:$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n - * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
