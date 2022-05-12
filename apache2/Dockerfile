ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/ubi/ubi8-minimal
ARG BASE_TAG=8.6

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

RUN microdnf -y upgrade && \
    microdnf -y install httpd-2.4.37 && \
    microdnf -y install mod_ssl && \
    microdnf -y clean all

COPY --chown=apache:apache scripts/httpd-foreground /etc/httpd/httpd-foreground

COPY scripts /scripts

RUN chown -R apache:apache /etc/httpd/ && \
    chmod 0755 /etc/httpd/httpd-foreground && \
    chmod 0770 /run/httpd/ && \
    chown -R apache:apache /var/log/httpd && \
    chmod +x /scripts/*.sh && \
    sed -i 's/Listen\ 80/#Listen\ 80/' /etc/httpd/conf/httpd.conf && \
    echo 'ServerName localhost' >> /etc/httpd/conf.d/ssl.conf && \
    sed -i 's/^#SSLProtocol/SSLProtocol/' /etc/httpd/conf.d/ssl.conf && \
    sed -i 's/\-SSLv3/\+TLSv1.2/' /etc/httpd/conf.d/ssl.conf && \
    sed -i 's/^#SSLProxyProtocol/SSLProxyProtocol/' /etc/httpd/conf.d/ssl.conf && \
    sed -i 's/443/8443/' /etc/httpd/conf.d/ssl.conf && \
    echo "SSLFIPS on" >> /etc/httpd/conf.d/ssl.conf && \
    fips-mode-setup --enable && \
    update-crypto-policies --set FIPS && \
    sed -ri \
		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
		-e 's!^(\s*TransferLog)\s+\S+!\1 /proc/self/fd/1!g' \
		"/etc/httpd/conf/httpd.conf" \
		"/etc/httpd/conf.d/ssl.conf" && \
    /scripts/xccdf_org.ssgproject.content_rule_account_disable_post_pw_expiration.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_maximum_age_login_defs.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_minimum_age_login_defs.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_minlen_login_defs.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_dcredit.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_difok.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_lcredit.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_minlen.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_ocredit.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_ucredit.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_deny_root.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_interval.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_passwords_pam_faillock_unlock_time.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_display_login_attempts.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_max_concurrent_login_sessions.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxclassrepeat.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_disable_users_coredumps.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_minclass.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_maxrepeat.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_umask_etc_login_defs.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_password_auth.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_pwhistory_remember_system_auth.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_logon_fail_delay.sh && \
    /scripts/xccdf_org.ssgproject.content_rule_accounts_password_pam_dictcheck.sh && \
    # /scripts/xccdf_org.ssgproject.content_rule_file_groupownership_system_commands_dirs.sh && \
    # CCE-86519-6
    chown root:root \
        /usr/bin/write \
        /sbin/suexec \
        /usr/sbin/suexec && \
    rm -rf /scripts

EXPOSE 8443

HEALTHCHECK --interval=5m --timeout=30s --start-period=1m --retries=3 CMD [ "curl -f https://localhost:8443" || exit 1 ]

STOPSIGNAL SIGWINCH

USER apache

ENTRYPOINT ["/etc/httpd/httpd-foreground"]
