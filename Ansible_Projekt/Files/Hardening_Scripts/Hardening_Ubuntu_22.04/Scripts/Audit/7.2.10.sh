#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.10"

# Initialize result variables
l_output=""
l_output2=""
l_output3=""
l_bf=""
l_df=""
l_nf=""
l_hf=""
l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"

# Initialize array for users and home directories
unset a_uarr && a_uarr=()
while read -r l_epu l_eph; do
    [[ -n "$l_epu" && -n "$l_eph" ]] && a_uarr+=("$l_epu $l_eph")
done <<< "$(awk -v pat="$l_valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)"

l_asize="${#a_uarr[@]}"  # Check the number of users
l_maxsize="1000"  # Maximum number of interactive users before a warning (default 1000)
if [ "$l_asize" -gt "$l_maxsize" ]; then
    echo -e "\n ** INFO **\n- \"$l_asize\" Local interactive users found on the system\n - This may take a long time to check\n"
fi

file_access_chk() {
    l_facout2=""
    l_max="$(printf '%o' $((0777 & ~$l_mask)))"
    
    if [ $(( l_mode & l_mask )) -gt 0 ]; then
        l_facout2="$l_facout2\n- File: \"$l_hdfile\" is mode: \"$l_mode\" and should be mode: \"$l_max\" or more restrictive"
    fi
    
    if [[ ! "$l_owner" =~ ($l_user) ]]; then
        l_facout2="$l_facout2\n- File: \"$l_hdfile\" owned by: \"$l_owner\" and should be owned by \"${l_user//|/ or }\""
    fi
    
    if [[ ! "$l_gowner" =~ ($l_group) ]]; then
        l_facout2="$l_facout2\n- File: \"$l_hdfile\" group owned by: \"$l_gowner\" and should be group owned by \"${l_group//|/ or }\""
    fi
}

# Check home directories
while read -r l_user l_home; do
    l_fe="" l_nout2="" l_nout3="" l_dfout2="" l_hdout2="" l_bhout2=""
    
    if [ -d "$l_home" ]; then
        l_group="$(id -gn "$l_user" | xargs)"
        l_group="${l_group// /|}"
        
        while IFS= read -r -d $'\0' l_hdfile; do
            while read -r l_mode l_owner l_gowner; do
                case "$(basename "$l_hdfile")" in
                    .forward | .rhost )
                        l_fe="Y" && l_bf="Y"
                        l_dfout2="$l_dfout2\n - File: \"$l_hdfile\" exists" ;;
                    .netrc )
                        l_mask='0177'
                        file_access_chk
                        if [ -n "$l_facout2" ]; then
                            l_fe="Y" && l_nf="Y"
                            l_nout2="$l_facout2"
                        else
                            l_nout3=" - File: \"$l_hdfile\" exists"
                        fi ;;
                    .bash_history )
                        l_mask='0177'
                        file_access_chk
                        if [ -n "$l_facout2" ]; then
                            l_fe="Y" && l_hf="Y"
                            l_bhout2="$l_facout2"
                        fi ;;
                    * )
                        l_mask='0133'
                        file_access_chk
                        if [ -n "$l_facout2" ]; then
                            l_fe="Y" && l_df="Y"
                            l_hdout2="$l_facout2"
                        fi ;;
                esac
            done <<< "$(stat -Lc '%#a %U %G' "$l_hdfile" 2>/dev/null)"  # Suppress permission denied errors here
        done < <(find "$l_home" -xdev -type f -name '.*' -print0 2>/dev/null)  # Suppress permission denied errors for find
    fi
    
    if [ "$l_fe" = "Y" ]; then
        l_output2="$l_output2\n- User: \"$l_user\" Home Directory: \"$l_home\""
        [ -n "$l_dfout2" ] && l_output2="$l_output2$l_dfout2"
        [ -n "$l_nout2" ] && l_output2="$l_output2$l_nout2"
        [ -n "$l_bhout2" ] && l_output2="$l_output2$l_bhout2"
        [ -n "$l_hdout2" ] && l_output2="$l_output2$l_hdout2"
    fi
    
    [ -n "$l_nout3" ] && l_output3="$l_output3\n- User: \"$l_user\" Home Directory: \"$l_home\"\n$l_nout3"
done <<< "$(printf '%s\n' "${a_uarr[@]}")"

unset a_uarr  # Clear the array

# Summarize results
[ -n "$l_output3" ] && l_output3=" - ** Warning **\n- \".netrc\" files should be removed unless deemed necessary\n and in accordance with local site policy:$l_output3"
[ -z "$l_bf" ] && l_output="$l_output\n- \".forward\" or \".rhost\" files"
[ -z "$l_nf" ] && l_output="$l_output\n- \".netrc\" files with incorrect access configured"
[ -z "$l_hf" ] && l_output="$l_output\n- \".bash_history\" files with incorrect access configured"
[ -z "$l_df" ] && l_output="$l_output\n- \"dot\" files with incorrect access configured"
[ -n "$l_output" ] && l_output=" - No local interactive users home directories contain:$l_output"

# Output audit results
if [ -z "$l_output2" ]; then  # If l_output2 is empty, we passed
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Results:\n ** PASS **\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Results:\n ** FAIL **\n- * Reasons for audit failure *:\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
