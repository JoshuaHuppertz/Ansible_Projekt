#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.5"

# Initialize output variables
l_pkgoutput=""
l_output=""
l_output2=""

# Determine system's package manager
if command -v dpkg-query > /dev/null 2>&1; then
    l_pq="dpkg-query -s"
elif command -v rpm > /dev/null 2>&1; then
    l_pq="rpm -q"
fi

# Check if GDM is installed
l_pcl="gdm gdm3"  # Space-separated list of packages to check
for l_pn in $l_pcl; do
    if $l_pq "$l_pn" > /dev/null 2>&1; then
        l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
    fi
done

# Check configuration (If applicable)
if [ -n "$l_pkgoutput" ]; then
    # Check if the idle-delay is locked
    if grep -Psrilq '^\h*idle-delay\h*=\h*uint32\h+\d+\b' /etc/dconf/db/*/; then
        if grep -Prilq '\/org\/gnome\/desktop\/session\/idle-delay\b' /etc/dconf/db/*/locks; then
            l_output="$l_output\n- \"idle-delay\" is locked"
        else
            l_output2="$l_output2\n- \"idle-delay\" is not locked"
        fi
    else
        l_output2="$l_output2\n- \"idle-delay\" is not set so it cannot be locked"
    fi

    # Check if the lock-delay is locked
    if grep -Psrilq '^\h*lock-delay\h*=\h*uint32\h+\d+\b' /etc/dconf/db/*/; then
        if grep -Prilq '\/org\/gnome\/desktop\/screensaver\/lock-delay\b' /etc/dconf/db/*/locks; then
            l_output="$l_output\n- \"lock-delay\" is locked"
        else
            l_output2="$l_output2\n- \"lock-delay\" is not locked"
        fi
    else
        l_output2="$l_output2\n- \"lock-delay\" is not set so it cannot be locked"
    fi
else
    l_output="$l_output\n- GNOME Desktop Manager package is not installed on the system\n - Recommendation is not applicable"
fi

# Prepare result report
if [ -n "$l_pkgoutput" ]; then
    echo -e "\n$l_pkgoutput"
fi

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