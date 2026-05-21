
#!/bin/bash

BANNER_TEXT="AUTHORIZED USE ONLY

All activities may be monitored and audited.
Personal data may be processed under LGPD (Brazilian Law 13.709/2018).

Unauthorized access is prohibited.
"

echo "Aplicando banner de segurança..."

echo "$BANNER_TEXT" > /etc/issue.net
echo "$BANNER_TEXT" > /etc/issue

echo "$BANNER_TEXT" > /etc/motd

chmod 644 /etc/issue.net
chmod 644 /etc/issue
chmod 644 /etc/motd

SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^Banner" $SSHD_CONFIG; then
    sed -i 's|^Banner.*|Banner /etc/issue.net|' $SSHD_CONFIG
else
    echo "Banner /etc/issue.net" >> $SSHD_CONFIG
fi


if [ -f /etc/pam.d/sshd ]; then
    grep -q "pam_motd.so" /etc/pam.d/sshd || \
    echo "session optional pam_motd.so motd=/etc/motd" >> /etc/pam.d/sshd
fi

if [ -f /etc/pam.d/login ]; then
    grep -q "pam_motd.so" /etc/pam.d/login || \
    echo "session optional pam_motd.so motd=/etc/motd" >> /etc/pam.d/login
fi

systemctl restart sshd 2>/dev/null || systemctl restart ssh

echo "Banner aplicado mantendo informações do sistema!"
