#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.22"

# Initialize output variable
RESULT=""

# Run the command to get the list of services
ss_output=$(ss -plntu)

# Check the output and prepare the result
if [[ -z "$ss_output" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n No services are currently listening.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    RESULT+="\n- The following services are listening on the system:\n"
    RESULT+="$ss_output\n"
    RESULT+="\n- Recommended Actions:\n"
    RESULT+="1. Review the services to ensure they are required and approved by local site policy.\n"
    RESULT+="2. If a service is not required, remove the package or, if necessary, stop and mask the service and/or socket.\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
