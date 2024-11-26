#!/bin/bash

max_attempts=12
attempt_num=1

# Функция ожидания условия
wait_for_condition() {
    local condition="$1"
    local max_attempts=$2
    local attempt_num=1
    while ! eval "$condition" && [ $attempt_num -le $max_attempts ]; do
        echo "Waiting for condition: $condition..."
        sleep 10
        ((attempt_num++))
    done
}

# Функция установки пакетов
install_package() {
    local package=$1
    if ! command -v "$package" &>/dev/null; then
        echo "Installing $package..."
        sudo yum install -y "$package" || { echo "$package installation failed."; exit 1; }
    else
        echo "$package is already installed."
    fi
}

# Устанавливаем необходимые пакеты
if command -v yum &>/dev/null && command -v curl &>/dev/null; then
    sudo amazon-linux-extras enable selinux-ng docker
    install_package "selinux-policy-targeted"
    install_package "git"
    install_package "java-17-amazon-corretto-devel"
    install_package "docker"

    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    docker --version || { echo "Docker installation failed."; exit 1; }
    echo "Docker installed successfully."

    # Установка k3s
    curl -sfL https://get.k3s.io | K3S_TOKEN="${token}" sh -s - || { echo "K3s installation failed."; exit 1; }
    echo "K3s installation succeeded."

    # Ожидаем доступность kubeconfig
    wait_for_condition "[ -f /etc/rancher/k3s/k3s.yaml ]" $max_attempts
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo "KUBECONFIG has been set to: $KUBECONFIG"

    kubectl cluster-info || { echo "Kubernetes cluster is not reachable."; exit 1; }

    mkdir -p ~/.kube && chmod 700 ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && chmod 600 ~/.kube/config
    sudo chmod 644 /etc/rancher/k3s/k3s.yaml
    sudo systemctl status k3s

    wait_for_condition "kubectl cluster-info &>/dev/null" $max_attempts
  
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    command -v helm &>/dev/null || { echo "Helm installation failed."; exit 1; }

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install my-nginx bitnami/nginx
    kubectl get pods --namespace default
    helm uninstall my-nginx --namespace default

    kubectl create namespace jenkins || echo "Namespace jenkins already exists."

    # Проверка StorageClass и создание по умолчанию
    kubectl get storageclass &>/dev/null || {
        echo "No StorageClass found. Setting up a default StorageClass..."
        cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
EOF
    }

    # Создание PersistentVolumeClaim
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
      storage: 10Gi
  storageClassName: local-path
EOF

    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    helm search repo jenkins
    echo "Start jenkins install"
    helm install my-jenkins jenkins/jenkins \
        --namespace jenkins \
        --set persistence.enabled=true \
        --set persistence.existingClaim=jenkins-pvc \
        --set controller.debug=true \
        --set service.type=LoadBalancer \
        --set controller.containerSecurityContext.readOnlyRootFilesystem=false

    echo "Waiting for Jenkins to be ready..."
    wait_for_condition "kubectl get pod my-jenkins-0 -n jenkins -o jsonpath='{.status.containerStatuses[*].ready}' | grep -q 'true true'" $max_attempts

    kubectl get pods -n jenkins

    # Получаем внешний IP и порт
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    echo "Public IP: $PUBLIC_IP"
    kubectl patch svc my-jenkins -n jenkins -p '{"spec": {"type": "LoadBalancer"}}'

    kubectl get svc -n jenkins
    echo "Jenkins is accessible at http://$PUBLIC_IP:8080"

    # Получение пароля администратора
    JENKINS_PASSWORD=$(kubectl exec -n jenkins svc/my-jenkins -c jenkins -- cat /run/secrets/additional/chart-admin-password)
    [ -n "$JENKINS_PASSWORD" ] && echo "Jenkins admin password: $JENKINS_PASSWORD" || { echo "Failed to retrieve Jenkins admin password."; exit 1; }

    echo "Fetching job log..."

    # Установка Prometheus
    echo "Installing Prometheus using Bitnami Helm chart..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    # Создаем namespace для Prometheus
    kubectl create namespace monitoring || echo "Namespace monitoring already exists."

    # Установка Prometheus с ограничением внешнего доступа
    helm install prometheus prometheus-community/prometheus \
        --namespace monitoring \
        --set server.service.type=ClusterIP \
        --set alertmanager.service.type=ClusterIP \
        --set pushgateway.service.type=ClusterIP

    echo "Waiting for Prometheus to be ready..."
    wait_for_condition "kubectl get pods -n monitoring -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep -q 'true true'" $max_attempts

    kubectl get pods -n monitoring

    # Настройка port-forward для доступа к интерфейсу Prometheus
    PROMETHEUS_POD=$(kubectl get pods -n monitoring -l app.kubernetes.io/component=server -o jsonpath='{.items[0].metadata.name}')
    echo "To access Prometheus web interface, run:"
    echo "kubectl port-forward -n monitoring $PROMETHEUS_POD 9090:9090"

else
    echo "yum or curl is not available, aborting."
    exit 1
fi
