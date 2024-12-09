#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.2"

# Initialize output variables
l_output=""
l_output2=""
l_pkgoutput=""
l_gdmfile=""
l_gdmprofile=""
l_lsbt=""

# Function to check if GDM is installed and verify the banner message settings
check_gdm_banner() {

    # Check if dpkg-query or rpm is available to query package info
    if command -v dpkg-query &> /dev/null; then
        l_pq="dpkg-query -s"
    elif command -v rpm &> /dev/null; then
        l_pq="rpm -q"
    fi

    # List of packages to check (gdm or gdm3)
    l_pcl="gdm gdm3"

    # Check if GDM is installed
    for l_pn in $l_pcl; do
        $l_pq "$l_pn" &> /dev/null && l_pkgoutput="$l_pkgoutput\n- Package: \"$l_pn\" exists on the system\n - checking configuration"
    done

    if [ -n "$l_pkgoutput" ]; then
        l_output=""  # Reset output for PASS
        l_output2="" # Reset output for FAIL

        # Look for the existing configuration of banner-message-enable
        l_gdmfile="$(grep -Prils '^\h*banner-message-enable\b' /etc/dconf/db/*.d)"

        if [ -n "$l_gdmfile" ]; then
            # Set profile name based on dconf db directory ({PROFILE_NAME}.d)
            l_gdmprofile="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<< "$l_gdmfile")"

            # Check if banner-message-enable is true
            if grep -Pisq '^\h*banner-message-enable=true\b' "$l_gdmfile"; then
                l_output="$l_output\n- The \"banner-message-enable\" option is enabled in \"$l_gdmfile\""
            else
                l_output2="$l_output2\n- The \"banner-message-enable\" option is not enabled"
            fi

            # Check if banner-message-text is set
            l_lsbt="$(grep -Pios '^\h*banner-message-text=.*$' "$l_gdmfile")"
            if [ -n "$l_lsbt" ]; then
                l_output="$l_output\n- The \"banner-message-text\" option is set in \"$l_gdmfile\"\n - banner-message-text is set to:\n - \"$l_lsbt\""
            else
                l_output2="$l_output2\n- The \"banner-message-text\" option is not set"
            fi

            # Check if the profile exists in the dconf profile directory
            if grep -Pq "^\h*system-db:$l_gdmprofile" /etc/dconf/profile/"$l_gdmprofile"; then
                l_output="$l_output\n- The \"$l_gdmprofile\" profile exists"
            else
                l_output2="$l_output2\n- The \"$l_gdmprofile\" profile doesn't exist"
            fi

            # Check if the profile exists in the dconf database
            if [ -f "/etc/dconf/db/$l_gdmprofile" ]; then
                l_output="$l_output\n- The \"$l_gdmprofile\" profile exists in the dconf database"
            else
                l_output2="$l_output2\n- The \"$l_gdmprofile\" profile doesn't exist in the dconf database"
            fi
        else
            l_output2="$l_output2\n- The \"banner-message-enable\" option isn't configured"
        fi
    else
        # If GDM is not installed, skip the check
        l_output="\n- GNOME Desktop Manager isn't installed\n- Recommendation is Not Applicable"
    fi
}

# Run the GDM banner check
check_gdm_banner

# Prepare the result message
if [ -z "$l_output2" ]; then
    # PASS: If no issues were found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    # FAIL: If there were issues
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file (no output to console)
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
