#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.3.1.1"

# Initialize output variables
l_output=""
l_output2=""

# Function to check if the service is enabled and active
service_not_enabled_chk() {
    l_out2=""
    if systemctl is-enabled "$l_service_name" 2>/dev/null | grep -q 'enabled'; then
        l_out2="$l_out2\n- Daemon: \"$l_service_name\" is enabled on the system"
    fi
    if systemctl is-active "$l_service_name" 2>/dev/null | grep -q '^active'; then
        l_out2="$l_out2\n- Daemon: \"$l_service_name\" is active on the system"
    fi
}

# Check systemd-timesyncd daemon
l_service_name="systemd-timesyncd.service"
service_not_enabled_chk
if [ -n "$l_out2" ]; then
    l_timesyncd="y"
    l_out_tsd="$l_out2"
else
    l_timesyncd="n"
    l_out_tsd="\n- Daemon: \"$l_service_name\" is not enabled and not active on the system"
fi

# Check chrony
l_service_name="chrony.service"
service_not_enabled_chk
if [ -n "$l_out2" ]; then
    l_chrony="y"
    l_out_chrony="$l_out2"
else
    l_chrony="n"
    l_out_chrony="\n- Daemon: \"$l_service_name\" is not enabled and not active on the system"
fi

# Determine the status of time sync daemons
l_status="$l_timesyncd$l_chrony"
case "$l_status" in
    yy)
        l_output2="- More than one time sync daemon is in use on the system$l_out_tsd$l_out_chrony"
        ;;
    nn)
        l_output2="- No time sync daemon is in use on the system$l_out_tsd$l_out_chrony"
        ;;
    yn|ny)
        l_output="- Only one time sync daemon is in use on the system$l_out_tsd$l_out_chrony"
        ;;
    *)
        l_output2="- Unable to determine time sync daemon(s) status"
        ;;
esac

# Prepare the result report
RESULT=""

if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure *:\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"