#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.4"

# Initialize output variables
l_output=""
l_output2=""

# Check if GNOME is installed
if dpkg-query -l | grep -q "gnome"; then
    # Get current lock-delay and idle-delay values
    lock_delay=$(gsettings get org.gnome.desktop.screensaver lock-delay 2>/dev/null)
    idle_delay=$(gsettings get org.gnome.desktop.session idle-delay 2>/dev/null)

    # Process lock-delay
    if [[ "$lock_delay" =~ ^uint32\ ([0-9]+) ]]; then
        lock_value="${BASH_REMATCH[1]}"
        if [ "$lock_value" -le 5 ]; then
            l_output="$l_output\n- lock-delay is set to $lock_value seconds (which is compliant)"
        else
            l_output2="$l_output2\n- lock-delay is set to $lock_value seconds (which is not compliant, should be 5 seconds or less)"
        fi
    else
        l_output2="$l_output2\n- lock-delay is not set correctly or is disabled"
    fi

    # Process idle-delay
    if [[ "$idle_delay" =~ ^uint32\ ([0-9]+) ]]; then
        idle_value="${BASH_REMATCH[1]}"
        if [ "$idle_value" -le 900 ]; then
            l_output="$l_output\n- idle-delay is set to $idle_value seconds (which is compliant)"
        else
            l_output2="$l_output2\n- idle-delay is set to $idle_value seconds (which is not compliant, should be 900 seconds or less)"
        fi
    else
        l_output2="$l_output2\n- idle-delay is not set correctly or is disabled"
    fi
else
    l_output="\n- GNOME Desktop Manager isn't installed\n- Recommendation is Not Applicable"
fi

# Prepare result report
if [ -z "$l_output2" ]; then
    # PASS: No issues found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    # FAIL: Issues found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
    [ -n "$l_output" ] && RESULT="$RESULT\n- Correctly set:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"