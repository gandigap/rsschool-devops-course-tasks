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
    helm install my-jenkins jenkins/jenkins \
        --namespace jenkins \
        --set persistence.enabled=true \
        --set persistence.existingClaim=jenkins-pvc \
        --set controller.debug=true

    echo "Waiting for Jenkins to be ready..."
    wait_for_condition "kubectl get pod my-jenkins-0 -n jenkins -o jsonpath='{.status.containerStatuses[*].ready}' | grep -q 'true true'" $max_attempts

    kubectl get pods -n jenkins
    kubectl port-forward --namespace jenkins svc/my-jenkins 8080:8080 &
    sleep 5

    JENKINS_PASSWORD=$(kubectl exec -n jenkins svc/my-jenkins -c jenkins -- cat /run/secrets/additional/chart-admin-password)
    [ -n "$JENKINS_PASSWORD" ] && echo "Jenkins admin password: $JENKINS_PASSWORD" || { echo "Failed to retrieve Jenkins admin password."; exit 1; }

    # Ожидаем доступность Jenkins CLI
    JENKINS_CLI_JAR=jenkins-cli.jar
    if [ ! -f "$JENKINS_CLI_JAR" ]; then
        echo "Jenkins CLI jar not found. Waiting for Jenkins to be ready..."

        until curl -s http://localhost:8080/ &> /dev/null || [ $attempt_num -gt $max_attempts ]; do
            echo "Waiting for Jenkins to be ready... Attempt $attempt_num of $max_attempts."
            sleep 10
            ((attempt_num++))
        done

        [ $attempt_num -gt $max_attempts ] && { echo "Jenkins did not become ready in the expected time."; exit 1; }

        echo "Downloading Jenkins CLI..."
        curl -L -o "$JENKINS_CLI_JAR" http://localhost:8080/jnlpJars/jenkins-cli.jar || { echo "Error: Failed to download Jenkins CLI jar."; exit 1; }
        file "$JENKINS_CLI_JAR" | grep -q "Java archive" || { echo "Error: The downloaded file is not a valid jar."; exit 1; }

        echo "Jenkins CLI jar downloaded successfully."
        hexdump -C "$JENKINS_CLI_JAR" | head -n 20
    fi

    echo "Fetching job log..."
else
    echo "yum or curl is not available, aborting."
    exit 1
fi
