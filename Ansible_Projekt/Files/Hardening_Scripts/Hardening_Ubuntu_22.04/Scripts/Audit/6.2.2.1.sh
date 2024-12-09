#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.2.2.1"

# Initialize result variables
l_output=""
l_output2=""

# Get the minimum UID from the configuration file
l_uidmin="$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"

# Function to check file permissions and ownership
file_test_chk() {
    l_op2=""
    if [ $(( l_mode & perm_mask )) -gt 0 ]; then
        l_op2="$l_op2\n- Mode: \"$l_mode\" should be \"$maxperm\" or more restrictive"
    fi
    if [[ ! "$l_user" =~ $l_auser ]]; then
        l_op2="$l_op2\n- Owner: \"$l_user\" should be \"${l_auser//|/ or }\""
    fi
    if [[ ! "$l_group" =~ $l_agroup ]]; then
        l_op2="$l_op2\n- Group ownership: \"$l_group\" should be \"${l_agroup//|/ or }\""
    fi
    [ -n "$l_op2" ] && l_output2="$l_output2\n- File: \"$l_fname\" has:$l_op2\n"
}

# Reset the array
unset a_file && a_file=() # Reset and initialize the array

# List files in /var/log/ with potential issues, suppressing error messages
while IFS= read -r -d $'\0' l_file; do
    [ -e "$l_file" ] && a_file+=("$(stat -Lc '%n^%#a^%U^%u^%G^%g' "$l_file" 2>/dev/null)")  # Suppress errors here
done < <(find -L /var/log -type f \( -perm /0137 -o ! -user root -o ! -group root \) -print0 2>/dev/null)  # Suppress errors for find

# Check file properties
while IFS="^" read -r l_fname l_mode l_user l_uid l_group l_gid; do
    l_bname="$(basename "$l_fname")"
    case "$l_bname" in
        lastlog | lastlog.* | wtmp | wtmp.* | wtmp-* | btmp | btmp.* | btmp-* | README)
            perm_mask='0113'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="root"
            l_agroup="(root|utmp)"
            file_test_chk
            ;;
        secure | auth.log | syslog | messages)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="(root|syslog)"
            l_agroup="(root|adm)"
            file_test_chk
            ;;
        SSSD | sssd)
            perm_mask='0117'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="(root|SSSD)"
            l_agroup="(root|SSSD)"
            file_test_chk
            ;;
        gdm | gdm3)
            perm_mask='0117'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="root"
            l_agroup="(root|gdm|gdm3)"
            file_test_chk
            ;;
        *.journal | *.journal~)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="root"
            l_agroup="(root|systemd-journal)"
            file_test_chk
            ;;
        *)
            perm_mask='0137'
            maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"
            l_auser="(root|syslog)"
            l_agroup="(root|adm)"
            if [ "$l_uid" -lt "$l_uidmin" ] && [ -z "$(awk -v grp="$l_group" -F: '$1==grp {print $4}' /etc/group)" ]; then
                if [[ ! "$l_user" =~ $l_auser ]]; then
                    l_auser="(root|syslog|$l_user)"
                fi
                if [[ ! "$l_group" =~ $l_agroup ]]; then
                    l_tst=""
                    while l_out3="" read -r l_duid; do
                        [ "$l_duid" -ge "$l_uidmin" ] && l_tst=failed
                    done <<< "$(awk -F: '$4=='"$l_gid"' {print $3}' /etc/passwd)"
                    [ "$l_tst" != "failed" ] && l_agroup="(root|adm|$l_group)"
                fi
            fi
            file_test_chk
            ;;
    esac
done <<< "$(printf '%s\n' "${a_file[@]}")"

# Reset the array
unset a_file # Reset the array

# Check the results and output them
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- All files in \"/var/log/\" have appropriate permissions and ownership\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failing the check:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
