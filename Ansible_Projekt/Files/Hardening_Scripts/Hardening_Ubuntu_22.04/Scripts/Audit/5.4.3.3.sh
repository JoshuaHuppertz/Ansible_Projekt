#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.3.3"

# Initialize result variables
l_output=""
l_output2=""

# Function to check umask in a file
file_umask_chk() {
    if grep -Psiq -- '^\h*umask\h+(0?[0-7][2-7]7|u(=[rwx]{0,3}),g=([rx]{0,2}),o=)(\h*#.*)?$' "$l_file"; then
        l_output="$l_output\n- umask is correctly set in \"$l_file\""
    elif grep -Psiq -- '^\h*umask\h+(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b|[0-7][0-7][0-6]\b)|(u=[rwx]{1,3},)?(((g=[rx]?[rx]?w[rx]?[rx]?\b)(,o=[rwx]{1,3})?)|((g=[wrx]{1,3},)?o=[wrx]{1,3}\b)))' "$l_file"; then
        l_output2="$l_output2\n- umask is incorrectly set in \"$l_file\""
    fi
}

# Check the umask in scripts in /etc/profile.d/
while IFS= read -r -d $'\0' l_file; do
    file_umask_chk
done < <(find /etc/profile.d/ -type f -name '*.sh' -print0)

# Check additional files
[ -z "$l_output" ] && l_file="/etc/profile" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/bashrc" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/bash.bashrc" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/pam.d/postlogin"

if [ -z "$l_output" ]; then
    if grep -Psiq -- '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(0?[0-7][2-7]7)\b' "$l_file"; then
        l_output="$l_output\n- umask is correctly set in \"$l_file\""
    elif grep -Psiq '^\h*session\h+[^#\n\r]+\h+pam_umask\.so\h+([^#\n\r]+\h+)?umask=(([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b)|([0-7][01][0-7]\b))' "$l_file"; then
        l_output2="$l_output2\n- umask is incorrectly set in \"$l_file\""
    fi
fi

[ -z "$l_output" ] && l_file="/etc/login.defs" && file_umask_chk
[ -z "$l_output" ] && l_file="/etc/default/login" && file_umask_chk

[[ -z "$l_output" && -z "$l_output2" ]] && l_output2="$l_output2\n- umask is not set"

# Check result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n *** PASS ***\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for failure * :\n$l_output2"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
