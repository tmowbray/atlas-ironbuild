#!/bin/sh

set -e 

# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

if [ -f /usr/bin/authselect ]; then
    if authselect check; then
        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # Standard profiles delivered with authselect should not be modified.
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"
            # Ensure a backup before changing the profile
            authselect apply-changes -b --backup=before-pwhistory-hardening.backup
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
        fi
        # Include the desired configuration in the custom profile
        CUSTOM_POSTLOGIN="/etc/authselect/$CURRENT_PROFILE/postlogin"
        # The line should be included on the top of postlogin file
        if [ $(grep -c "^\s*session.*required.*pam_lastlog.so\s\+showfailed\s*$" $CUSTOM_POSTLOGIN) -eq 0 ]; then
            sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     required                   pam_lastlog.so showfailed\n&/' $CUSTOM_POSTLOGIN
        fi
        if grep -q "^\s*session.*required.*pam_lastlog.so.*silent.*" $CUSTOM_POSTLOGIN; then
            # remove 'silent' option
            sed -i --follow-symlinks 's/^\(session.*required.*pam_lastlog.so\).*/\1 showfailed/g' $CUSTOM_POSTLOGIN
        fi
        authselect apply-changes -b --backup=after-pwhistory-hardening.backup
    else
        echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because the authselect profile is not intact.
It is not recommended to manually edit the PAM files when authselect is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        false
    fi
else
    
    
    

    if [ $(grep -c "^\s*session.*required.*pam_lastlog.so\s\+showfailed\s*$" /etc/pam.d/postlogin) -eq 0 ]; then
        sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     required                   pam_lastlog.so showfailed\n&/' /etc/pam.d/postlogin
    fi
    if grep -q "^\s*session.*required.*pam_lastlog.so.*silent.*" /etc/pam.d/postlogin; then
        # remove 'silent' option
        sed -i --follow-symlinks 's/^\(session.*required.*pam_lastlog.so\).*/\1 showfailed/g' /etc/pam.d/postlogin
    fi
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi