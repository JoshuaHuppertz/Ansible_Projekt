#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.2.5"

# Permission mask and expected maximum permissions
l_output2=""
l_pmask="0022"
l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"

# Get the root PATH
l_root_path="$(sudo -Hiu root env | grep '^PATH' | cut -d= -f2)"

# Split the PATH into an array
unset a_path_loc && IFS=":" read -ra a_path_loc <<< "$l_root_path"

# Checks for specific PATH errors
grep -q "::" <<< "$l_root_path" && l_output2="$l_output2\n - root's PATH contains an empty directory (::)"
grep -Pq ":\h*$" <<< "$l_root_path" && l_output2="$l_output2\n - root's PATH has a trailing colon (:)"
grep -Pq '(\h+|:)\.(:|\h*$)' <<< "$l_root_path" && l_output2="$l_output2\n - root's PATH contains the current directory (.)"

# Check each directory in the PATH
while read -r l_path; do
    if [ -d "$l_path" ]; then
        # Check the file permissions and owner of the directory
        while read -r l_fmode l_fown; do
            [ "$l_fown" != "root" ] && l_output2="$l_output2\n - Directory: \"$l_path\" is owned by \"$l_fown\", but it should be owned by root"
            [ $(( $l_fmode & $l_pmask )) -gt 0 ] && l_output2="$l_output2\n - Directory: \"$l_path\" has mode: \"$l_fmode\", it should be \"$l_maxperm\" or more restrictive"
        done <<< "$(stat -Lc '%#a %U' "$l_path")"
    else
        l_output2="$l_output2\n - \"$l_path\" is not a directory"
    fi
done <<< "$(printf "%s\n" "${a_path_loc[@]}")"

# Prepare the result based on the checks
RESULT=""
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n *** PASS ***\n- Root's PATH is correctly configured.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for failure * :\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
