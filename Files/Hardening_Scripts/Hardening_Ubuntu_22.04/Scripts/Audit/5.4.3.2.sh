#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.3.2"

# Check if TMOUT is configured
output1=""
output2=""
BRC="/etc/bashrc"

# Search through configuration files
for f in "$BRC" /etc/profile /etc/profile.d/*.sh; do
    # Suppress errors and check for the presence of TMOUT configurations
    if sudo grep -Pq '^\s*([^#]+\s+)?TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$f" 2>/dev/null &&
       sudo grep -Pq '^\s*([^#]+;\s*)?readonly\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" 2>/dev/null &&
       sudo grep -Pq '^\s*([^#]+;\s*)?export\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" 2>/dev/null; then
        output1="$f"
    fi
done

# Check for excessively long TMOUT values and suppress errors
sudo grep -Pq '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC" 2>/dev/null &&
output2=$(sudo grep -Ps '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC" 2>/dev/null)

# Check the result and output
RESULT=""
if [ -n "$output1" ] && [ -z "$output2" ]; then
    RESULT="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n *** PASS ***\n- TMOUT is configured in: \"$output1\"\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    [ -z "$output1" ] && RESULT+="- TMOUT is not configured\n"
    [ -n "$output2" ] && RESULT+="- TMOUT is incorrectly configured in: \"$output2\"\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
