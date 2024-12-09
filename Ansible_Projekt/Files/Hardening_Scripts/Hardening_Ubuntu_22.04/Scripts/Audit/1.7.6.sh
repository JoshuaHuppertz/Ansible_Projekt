#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.6"

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
    # Look for existing settings and set variables if they exist
    l_kfile="$(grep -Prils -- '^\h*automount\b' /etc/dconf/db/*.d)"
    l_kfile2="$(grep -Prils -- '^\h*automount-open\b' /etc/dconf/db/*.d)"

    # Set profile name based on dconf db directory ({PROFILE_NAME}.d)
    if [ -f "$l_kfile" ]; then
        l_gpname="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<< "$l_kfile")"
    elif [ -f "$l_kfile2" ]; then
        l_gpname="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<< "$l_kfile2")"
    fi

    # If the profile name exists, continue checks
    if [ -n "$l_gpname" ]; then
        l_gpdir="/etc/dconf/db/$l_gpname.d"
        
        # Check if profile file exists
        if grep -Pq -- "^\h*system-db:$l_gpname\b" /etc/dconf/profile/*; then
            l_output="$l_output\n- dconf database profile file \"$(grep -Pl -- "^\h*system-db:$l_gpname\b" /etc/dconf/profile/*)\" exists"
        else
            l_output2="$l_output2\n- dconf database profile isn't set"
        fi
        
        # Check if the dconf database file exists
        if [ -f "/etc/dconf/db/$l_gpname" ]; then
            l_output="$l_output\n- The dconf database \"$l_gpname\" exists"
        else
            l_output2="$l_output2\n- The dconf database \"$l_gpname\" doesn't exist"
        fi
        
        # Check if the dconf database directory exists
        if [ -d "$l_gpdir" ]; then
            l_output="$l_output\n- The dconf directory \"$l_gpdir\" exists"
        else
            l_output2="$l_output2\n- The dconf directory \"$l_gpdir\" doesn't exist"
        fi

        # Check automount setting
        if grep -Pqrs -- '^\h*automount\h*=\h*false\b' "$l_kfile"; then
            l_output="$l_output\n- \"automount\" is set to false in: \"$l_kfile\""
        else
            l_output2="$l_output2\n- \"automount\" is not set correctly"
        fi

        # Check automount-open setting
        if grep -Pqs -- '^\h*automount-open\h*=\h*false\b' "$l_kfile2"; then
            l_output="$l_output\n- \"automount-open\" is set to false in: \"$l_kfile2\""
        else
            l_output2="$l_output2\n- \"automount-open\" is not set correctly"
        fi
    else
        # Settings don't exist. Nothing further to check
        l_output2="$l_output2\n- neither \"automount\" or \"automount-open\" is set"
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