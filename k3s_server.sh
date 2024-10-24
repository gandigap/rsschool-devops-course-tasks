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

    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s -

    # Ожидание создания файла конфигурации k3s
    while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
        echo "Waiting for kubeconfig to be available..."
        sleep 10
    done

    sudo cat /etc/rancher/k3s/k3s.yaml
else
    echo "yum or curl is not available, aborting."
fi