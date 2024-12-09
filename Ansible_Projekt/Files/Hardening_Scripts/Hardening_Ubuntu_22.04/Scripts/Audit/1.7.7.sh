#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.7"

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
        l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - Checking configuration"
    fi
done

# Check for GDM configuration (If applicable)
if [ -n "$l_pkgoutput" ]; then
    # Initialize output for audit results
    l_output=""
    l_output2=""

    # Search /etc/dconf/db/local.d/ for automount settings
    l_automount_setting=$(grep -Psir -- '^\h*automount=false\b' /etc/dconf/db/local.d/*)
    l_automount_open_setting=$(grep -Psir -- '^\h*automount-open=false\b' /etc/dconf/db/local.d/*)

    # Check for automount setting
    if [[ -n "$l_automount_setting" ]]; then
        l_output="$l_output\n- \"automount\" setting found"
    else
        l_output2="$l_output2\n- \"automount\" setting not found"
    fi

    # Check for automount-open setting
    if [[ -n "$l_automount_open_setting" ]]; then
        l_output="$l_output\n- \"automount-open\" setting found"
    else
        l_output2="$l_output2\n- \"automount-open\" setting not found"
    fi
else
    l_output="$l_output\n- GNOME Desktop Manager package is not installed on the system\n- Recommendation is not applicable"
fi

# Prepare result report
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"