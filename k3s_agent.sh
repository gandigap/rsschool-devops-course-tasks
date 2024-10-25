#!/bin/bash

# Ожидание завершения загрузки сервера
while ! systemctl is-active --quiet sshd; do
    echo "Waiting for SSH service to be active..."
    sleep 10
done

# Убедитесь, что yum и curl доступны
if command -v yum &> /dev/null && command -v curl &> /dev/null; then
    sudo amazon-linux-extras enable selinux-ng
    sudo yum install selinux-policy-targeted -y

    # Установка и подключение k3s Agent
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} K3S_URL="https://${server_addr}:6443" sh -s -

    # Ожидание завершения установки
    while ! systemctl is-active --quiet k3s-agent; do
        echo "Waiting for k3s-agent service to be active..."
        sleep 10
    done

    echo "k3s Agent setup completed."
else
    echo "yum or curl is not available, aborting."
fi