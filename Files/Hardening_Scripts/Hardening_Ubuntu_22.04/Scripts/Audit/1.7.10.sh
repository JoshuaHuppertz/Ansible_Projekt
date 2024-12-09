#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.10"

# Initialize an output variable to check for any findings
OUTPUT=""

# Search for [xdmcp] sections in GDM configuration files
while IFS= read -r l_file; do
    # Check for Enable=true in the [xdmcp] section
    found=$(awk '/\[xdmcp\]/{ f = 1; next } /\[/{ f = 0 } f {if (/^\s*Enable\s*=\s*true/) print "The file: \"'"$l_file"'\" includes: \"" $0 "\" in the \"[xdmcp]\" block"}' "$l_file")
    
    # Append the findings to OUTPUT
    if [[ -n "$found" ]]; then
        OUTPUT+="\n$found\n"
    fi
done < <(grep -Psil -- '^\h*\[xdmcp\]' /etc/{gdm3,gdm}/{custom,daemon}.conf)

# Prepare result report
if [[ -z "$OUTPUT" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- No issues found in [xdmcp] section.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n\n- $OUTPUT\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"