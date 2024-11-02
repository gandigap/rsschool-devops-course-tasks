#!/bin/bash

max_attempts=12
attempt_num=1

# Ожидание активации SSH
while ! systemctl is-active --quiet sshd && [ $attempt_num -le $max_attempts ]; do
    echo "Waiting for SSH service to be active..."
    sleep 10
    attempt_num=$((attempt_num + 1))
done


# Проверка доступности yum и curl
if command -v yum &> /dev/null && command -v curl &> /dev/null; then
    # Включение SELinux и установка необходимого пакета
    sudo amazon-linux-extras enable selinux-ng
    sudo yum install selinux-policy-targeted -y

    # Установка Git
    sudo yum install git -y

    # Установка K3s
    curl -sfL https://get.k3s.io | K3S_TOKEN=${token} sh -s -
    if [ $? -ne 0 ]; then
        echo "K3s installation failed."
        exit 1
    fi
    echo "K3s installation succeeded."

    # Ожидание доступности kubeconfig
    attempt_num=1
    while [ ! -f /etc/rancher/k3s/k3s.yaml ] && [ $attempt_num -le $max_attempts ]; do
        echo "Waiting for kubeconfig to be available..."
        sleep 10
        attempt_num=$((attempt_num + 1))
    done

    if [ -f /etc/rancher/k3s/k3s.yaml ]; then
        echo "Kubeconfig is now available at /etc/rancher/k3s/k3s.yaml."
    else
        echo "Kubeconfig was not found after waiting."
        exit 1
    fi

    # Установка переменной окружения KUBECONFIG
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # Вывод отчета о статусе установки KUBECONFIG
    echo "KUBECONFIG has been set to: $KUBECONFIG"

    # Проверка статуса кластера
    echo "Checking Kubernetes cluster info..."
    kubectl cluster-info
    if [ $? -ne 0 ]; then
        echo "Kubernetes cluster is not reachable."
        exit 1
    fi

    # Создание директории для kubeconfig
    echo "Creating kube directory..."
    mkdir -p ~/.kube  # Создаем директорию, если она не существует

    # Проверка, была ли создана директория
    if [ -d ~/.kube ]; then
        echo "Kube directory created successfully."
        chmod 700 ~/.kube
    else
        echo "Failed to create kube directory." >&2
        exit 1
    fi

    # Вывод содержимого k3s.yaml
    echo "Contents of k3s.yaml:"
    if [ -f /etc/rancher/k3s/k3s.yaml ]; then
        cat /etc/rancher/k3s/k3s.yaml
        echo "Contents of k3s.yaml completed" 
    else
        echo "Файл /etc/rancher/k3s/k3s.yaml не найден." >&2
        exit 1
    fi

    # Копирование kubeconfig
    echo "Copying kubeconfig..."
    if sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config; then
        echo "Kubeconfig copied successfully."
    else
        echo "Failed to copy kubeconfig." >&2
        exit 1
    fi

    # Устанавливаем права на файл конфигурации
    chmod 600 ~/.kube/config
    echo "Permissions set for kubeconfig."

    # Вывод kubeconfig
    sudo /usr/local/bin/k3s kubectl config view --raw > ~/.kube/config
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve kubeconfig."
        exit 1
    fi
    
    sudo chmod 644 /etc/rancher/k3s/k3s.yaml
    sudo systemctl status k3s
    sudo cat /etc/rancher/k3s/k3s.yaml

    # Проверка доступности кластера
    attempt_num=1
    while ! kubectl cluster-info &> /dev/null && [ $attempt_num -le $max_attempts ]; do
        echo "Waiting for Kubernetes cluster to be ready..."
        sleep 10
        attempt_num=$((attempt_num + 1))
    done

    # Установка Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    if ! command -v helm &> /dev/null; then
        echo "Helm installation failed."
        exit 1
    fi

    # Развертывание Nginx с помощью Helm
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install my-nginx bitnami/nginx

    # Проверка успешного развертывания Nginx
    kubectl get pods --namespace default
    helm uninstall my-nginx --namespace default

    # Создание пространства имён для Jenkins
    kubectl create namespace jenkins || echo "Namespace jenkins already exists."

    # Проверка наличия StorageClass
    if ! kubectl get storageclass &> /dev/null; then
        echo "No StorageClass found. Setting up a default StorageClass..."
        cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
EOF
    fi

    # Создание PersistentVolumeClaim для Jenkins
    echo "Creating PersistentVolumeClaim for Jenkins..."
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi  # Укажите размер тома, например, 10Gi
  storageClassName: local-path
EOF

    # Установка Jenkins с использованием PVC для хранения данных
    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    helm install my-jenkins jenkins/jenkins \
      --namespace jenkins \
      --set controller.debug=true \
      --set persistence.existingClaim=jenkins-pvc

    # Ожидание успешного развертывания Jenkins
    echo "Waiting for Jenkins to be ready..."
    attempt_num=1
    while [[ $attempt_num -le $max_attempts ]]; do
        sleep 10
        kubectl get pods -n jenkins | grep my-jenkins | grep -q Running
        if [[ $? -eq 0 ]]; then
            echo "Jenkins is now running."
            break
        fi
        echo "Jenkins is not ready yet. Attempt $attempt_num of $max_attempts."
        attempt_num=$((attempt_num + 1))
    done

    if [[ $attempt_num -gt $max_attempts ]]; then
        echo "Jenkins did not start in the expected time."
        exit 1
    fi

    # Проверка успешного развертывания Jenkins
    kubectl get pods -n jenkins

else
    echo "yum or curl is not available, aborting."
    exit 1
fi
