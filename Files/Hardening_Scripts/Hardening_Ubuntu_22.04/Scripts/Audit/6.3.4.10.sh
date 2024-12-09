#!/usr/bin/env bash

# Set the results directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.4.10"

# Initialize result variables
l_output=""
l_output2=""

# Audit tools
a_audit_tools=(
    "/sbin/auditctl"
    "/sbin/aureport"
    "/sbin/ausearch"
    "/sbin/autrace"
    "/sbin/auditd"
    "/sbin/augenrules"
)

# Check if the audit tools belong to the "root" group
for l_audit_tool in "${a_audit_tools[@]}"; do
    if [ -e "$l_audit_tool" ]; then
        l_group="$(sudo stat -Lc '%G' "$l_audit_tool")"
        if [ "$l_group" != "root" ]; then
            l_output2+="\n- Audit tool \"$l_audit_tool\" is owned by group: \"$l_group\" (should be owned by group: \"root\")"
        fi
    else
        l_output2+="\n- Audit tool \"$l_audit_tool\" does not exist."
    fi
done

# Check and output result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- All audit tools are owned by the \"root\" group."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for audit failure:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
