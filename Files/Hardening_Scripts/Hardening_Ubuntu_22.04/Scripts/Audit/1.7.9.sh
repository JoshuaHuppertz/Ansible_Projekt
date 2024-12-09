#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.9"

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
        l_pkgoutput="$l_pkgoutput\n- Package: \"$l_pn\" exists on the system\n - Checking configuration"
    fi
done

# Search for [org/gnome/desktop/media-handling] settings in /etc/dconf/db/
l_desktop_media_handling=$(grep -Psir -- '^\h*\[org/gnome/desktop/media-handling\]' /etc/dconf/db/*)
if [[ -n "$l_desktop_media_handling" ]]; then
    l_output="" 
    l_output2=""

    l_autorun_setting=$(grep -Psir -- '^\h*autorun-never=true\b' /etc/dconf/db/local.d/*)

    # Check for auto-run setting
    if [[ -n "$l_autorun_setting" ]]; then
        l_output="$l_output\n- \"autorun-never\" setting found"
    else
        l_output2="$l_output2\n- \"autorun-never\" setting not found"
    fi
else
    l_output="$l_output\n- [org/gnome/desktop/media-handling] setting not found in /etc/dconf/db/*"
fi

# Prepare result report
if [ -n "$l_pkgoutput" ]; then
    echo -e "\n$l_pkgoutput"
fi

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