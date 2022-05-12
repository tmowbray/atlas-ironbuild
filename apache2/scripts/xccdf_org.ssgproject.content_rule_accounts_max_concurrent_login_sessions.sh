#!/bin/sh

set -e

# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

var_accounts_max_concurrent_login_sessions='10'


if grep -q '^[^#]*\<maxlogins\>' /etc/security/limits.d/*.conf; then
	sed -i "/^[^#]*\<maxlogins\>/ s/maxlogins.*/maxlogins $var_accounts_max_concurrent_login_sessions/" /etc/security/limits.d/*.conf
elif grep -q '^[^#]*\<maxlogins\>' /etc/security/limits.conf; then
	sed -i "/^[^#]*\<maxlogins\>/ s/maxlogins.*/maxlogins $var_accounts_max_concurrent_login_sessions/" /etc/security/limits.conf
else
	echo "*	hard	maxlogins	$var_accounts_max_concurrent_login_sessions" >> /etc/security/limits.conf
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi