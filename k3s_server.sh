#!/bin/bash

while ! systemctl is-active --quiet sshd; do
    echo "Waiting for SSH service to be active..."
    sleep 10
done

if command -v yum &> /dev/null && command -v curl &> /dev/null; then
    sudo amazon-linux-extras enable selinux-ng
    sudo yum install selinux-policy-targeted -y

    # Установка K3s
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s -

    # Ожидание доступности kubeconfig
    while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
        echo "Waiting for kubeconfig to be available..."
        sleep 10
    done

    # Вывод kubeconfig
    sudo chmod 644 /etc/rancher/k3s/k3s.yaml
    sudo systemctl status k3s
    sudo cat /etc/rancher/k3s/k3s.yaml
    # export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    
    # Установка Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Проверка установки Helm
    helm version

    # Развертывание Nginx с помощью Helm
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install my-nginx bitnami/nginx

    # Проверка успешного развертывания
    kubectl get pods

    # Удаление Nginx
    helm uninstall my-nginx

    # Создание пространства имён для Jenkins
    kubectl create namespace jenkins

    # Установка Jenkins с использованием Helm
    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    helm install my-jenkins jenkins/jenkins --namespace jenkins --set controller.debug=true

    # Ожидание запуска Jenkins
    kubectl rollout status deployment/my-jenkins -n jenkins

    # Проверка успешного развертывания Jenkins
    kubectl get pods -n jenkins

else
    echo "yum or curl is not available, aborting."
fi

#!/bin/bash

while ! systemctl is-active --quiet sshd; do
    echo "Waiting for SSH service to be active..."
    sleep 10
done

if command -v yum &> /dev/null && command -v curl &> /dev/null; then
    sudo amazon-linux-extras enable selinux-ng
    sudo yum install selinux-policy-targeted -y

    # Установка K3s
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s -

    # Ожидание доступности kubeconfig
    while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
        echo "Waiting for kubeconfig to be available..."
        sleep 10
    done

    # Вывод kubeconfig
    sudo cat /etc/rancher/k3s/k3s.yaml

    # Установка Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Установка Jenkins
    helm repo add jenkins https://charts.jenkins.io
    helm install my-jenkins jenkins/jenkins --namespace jenkins --create-namespace

    # Проверка установки Jenkins
    kubectl get pods -n jenkins

else
    echo "yum or curl is not available, aborting."
fi