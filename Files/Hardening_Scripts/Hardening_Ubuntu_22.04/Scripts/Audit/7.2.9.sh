#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.9"

# Initialize result variables
l_output=""
l_output2=""
l_heout2=""
l_hoout2=""
l_haout2=""

# Define valid shells
l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

# Initialize array for users and home directories
unset a_uarr && a_uarr=()
while read -r l_epu l_eph; do
    a_uarr+=("$l_epu $l_eph")
done <<< "$(awk -v pat="$l_valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)"

l_asize="${#a_uarr[@]}" # Check the number of users
if [ "$l_asize" -gt "10000" ]; then
    # Keine Konsolenausgabe mehr, wenn mehr als 10000 Benutzer
    :
fi

# Check home directories
while read -r l_user l_home; do
    if [ -d "$l_home" ]; then
        l_mask='0027'
        l_max="$(printf '%o' $((0777 & ~$l_mask)))"
        while read -r l_own l_mode; do
            [ "$l_user" != "$l_own" ] && l_hoout2="$l_hoout2\n - User: \"$l_user\" Home \"$l_home\" is owned by: \"$l_own\""
            if [ $(( l_mode & l_mask )) -gt 0 ]; then
                l_haout2="$l_haout2\n - User: \"$l_user\" Home \"$l_home\" has mode: \"$l_mode\", should be mode: \"$l_max\" or more restrictive"
            fi
        done <<< "$(stat -Lc '%U %#a' "$l_home")"
    else
        l_heout2="$l_heout2\n - User: \"$l_user\" Home \"$l_home\" doesn't exist"
    fi
done <<< "$(printf '%s\n' "${a_uarr[@]}")"

# Summarize the results
[ -z "$l_heout2" ] && l_output="$l_output\n- Home directories exist" || l_output2="$l_output2$l_heout2"
[ -z "$l_hoout2" ] && l_output="$l_output\n- Own their home directory" || l_output2="$l_output2$l_hoout2"
[ -z "$l_haout2" ] && l_output="$l_output\n- Home directories are mode: \"$l_max\" or more restrictive" || l_output2="$l_output2$l_haout2"

# Format the result for output
if [ -n "$l_output" ]; then
    l_output="- All local interactive users:$l_output"
fi

# Define the result message
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- * Correctly configured *:\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure *:\n$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"