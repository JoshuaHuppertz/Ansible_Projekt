#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.3"

# Initialize output variables
l_output=""
l_output2=""
l_pkgoutput=""
l_gdmfile=""
l_gdmprofile=""

# Function to check if GDM is installed and verify the disable-user-list setting
check_disable_user_list() {

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
        $l_pq "$l_pn" &> /dev/null && l_pkgoutput="$l_pkgoutput\n- Package: \"$l_pn\" exists on the system\n- Checking configuration"
    done

    if [ -n "$l_pkgoutput" ]; then
        l_output=""  # Reset output for PASS
        l_output2="" # Reset output for FAIL

        # Look for the existing configuration of disable-user-list
        l_gdmfile="$(grep -Pril '^\h*disable-user-list\h*=\h*true\b' /etc/dconf/db)"

        if [ -n "$l_gdmfile" ]; then
            l_output="$l_output\n- The \"disable-user-list\" option is enabled in \"$l_gdmfile\""
            
            # Set profile name based on dconf db directory ({PROFILE_NAME}.d)
            l_gdmprofile="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<< "$l_gdmfile")"

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
            l_output2="$l_output2\n- The \"disable-user-list\" option is not enabled"
        fi
    else
        # If GDM is not installed, skip the check
        l_output="\n- GNOME Desktop Manager isn't installed\n- Recommendation is Not Applicable\n"
    fi
}

# Run the GDM disable-user-list check
check_disable_user_list

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
