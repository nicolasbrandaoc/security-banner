#!/bin/bash

BANNER_TEXT="AUTHORIZED USE ONLY

All activities may be monitored and audited.
Personal data may be processed under LGPD (Brazilian Law 13.709/2018).

Unauthorized access is prohibited.
"

echo "Aplicando banner de segurança..."

# Aplicar banner
echo "$BANNER_TEXT" > /etc/issue.net
echo "$BANNER_TEXT" > /etc/issue
echo "$BANNER_TEXT" > /etc/motd

# Permissões
chmod 644 /etc/issue.net
chmod 644 /etc/issue
chmod 644 /etc/motd

# Configurar SSH
SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^Banner" $SSHD_CONFIG; then
    sed -i 's|^Banner.*|Banner /etc/issue.net|' $SSHD_CONFIG
else
    echo "Banner /etc/issue.net" >> $SSHD_CONFIG
fi

# Desativar MOTD dinâmico (Ubuntu e derivados)
if [ -d /etc/update-motd.d ]; then
    chmod -x /etc/update-motd.d/*
fi

# Limpar arquivos extras que mostram info do Ubuntu
> /var/run/motd.dynamic 2>/dev/null
> /etc/legal 2>/dev/null

# Garantir uso do nosso MOTD via PAM
if [ -f /etc/pam.d/sshd ]; then
    sed -i '/pam_motd.so/d' /etc/pam.d/sshd
    echo "session optional pam_motd.so motd=/etc/motd" >> /etc/pam.d/sshd
fi

if [ -f /etc/pam.d/login ]; then
    sed -i '/pam_motd.so/d' /etc/pam.d/login
    echo "session optional pam_motd.so motd=/etc/motd" >> /etc/pam.d/login
fi

# Reiniciar SSH
systemctl restart sshd 2>/dev/null || systemctl restart ssh

echo "Banner aplicado com sucesso em TODOS os acessos!"
echo "Informações padrão do Ubuntu removidas!"
