#!/bin/bash

max_attempts=12
attempt_num=1

wait_for_condition() {
    local condition="$1"
    local max_attempts=$2
    local attempt_num=1
    while ! eval "$condition" && [ $attempt_num -le $max_attempts ]; do
        echo "Waiting for condition: $condition..."
        sleep 10
        attempt_num=$((attempt_num + 1))
    done
}

if command -v yum &>/dev/null && command -v curl &>/dev/null; then
    sudo amazon-linux-extras enable selinux-ng && \
    sudo yum install -y selinux-policy-targeted git java-17-amazon-corretto-devel

    # Добавлено: установка Docker
    echo "Installing Docker..."
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    if ! docker --version; then
        echo "Docker installation failed."
        exit 1
    fi
    echo "Docker installed successfully."

    # Установка k3s
    if ! curl -sfL https://get.k3s.io | K3S_TOKEN="${token}" sh -s -; then
        echo "K3s installation failed."
        exit 1
    fi
    echo "K3s installation succeeded."

    wait_for_condition "[ -f /etc/rancher/k3s/k3s.yaml ]" $max_attempts
    if [ ! -f /etc/rancher/k3s/k3s.yaml ]; then
        echo "Kubeconfig was not found after waiting."
        exit 1
    fi
    echo "Kubeconfig is now available at /etc/rancher/k3s/k3s.yaml."

    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo "KUBECONFIG has been set to: $KUBECONFIG"

    if ! kubectl cluster-info; then
        echo "Kubernetes cluster is not reachable."
        exit 1
    fi

    mkdir -p ~/.kube && chmod 700 ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && chmod 600 ~/.kube/config

    if [ -f ~/.kube/config ]; then
        echo "Contents of kubeconfig:"
        cat ~/.kube/config
    else
        echo "Failed to locate kubeconfig." >&2
        exit 1
    fi

    sudo chmod 644 /etc/rancher/k3s/k3s.yaml
    sudo systemctl status k3s

    wait_for_condition "kubectl cluster-info &>/dev/null" $max_attempts

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    if ! command -v helm &>/dev/null; then
        echo "Helm installation failed."
        exit 1
    fi

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install my-nginx bitnami/nginx

    kubectl get pods --namespace default
    helm uninstall my-nginx --namespace default

    kubectl create namespace jenkins || echo "Namespace jenkins already exists."

    # Проверка наличия StorageClass и создание по умолчанию
    if ! kubectl get storageclass &>/dev/null; then
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

    echo "Setting up port forwarding to access Jenkins..."
    kubectl port-forward --namespace jenkins svc/my-jenkins 8080:8080 &
    sleep 5  

    JENKINS_PASSWORD=$(kubectl exec -n jenkins svc/my-jenkins -c jenkins -- cat /run/secrets/additional/chart-admin-password)

    if [ -n "$JENKINS_PASSWORD" ]; then
        echo "Jenkins admin password: $JENKINS_PASSWORD"
    else
        echo "Failed to retrieve Jenkins admin password."
        exit 1
    fi

    JENKINS_CLI_JAR=jenkins-cli.jar

    attempt_num=1

    if [ ! -f "$JENKINS_CLI_JAR" ]; then
        echo "Jenkins CLI jar not found. Waiting for Jenkins to be ready..."

        until curl -s http://localhost:8080/ &> /dev/null || [ $attempt_num -gt $max_attempts ]; do
            echo "Waiting for Jenkins to be ready... Attempt $attempt_num of $max_attempts."
            sleep 10
            ((attempt_num++))
        done

        if [ $attempt_num -gt $max_attempts ]; then
            echo "Jenkins did not become ready in the expected time."
            exit 1
        fi

        echo "Downloading Jenkins CLI..."
        if ! curl -L -o "$JENKINS_CLI_JAR" http://localhost:8080/jnlpJars/jenkins-cli.jar; then
            echo "Error: Failed to download Jenkins CLI jar."
            exit 1
        fi

        if ! file "$JENKINS_CLI_JAR" | grep -q "Java archive"; then
            echo "Error: The downloaded file is not a valid jar."
            exit 1
        fi

        echo "Jenkins CLI jar downloaded successfully."
        echo "Contents of jenkins-cli.jar:"
        hexdump -C "$JENKINS_CLI_JAR" | head -n 20  
    fi

    echo "Creating and running freestyle project..."

    cat <<EOF > job-config.xml
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Simple Hello World project</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>echo "Hello world"</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF

    java -jar "$JENKINS_CLI_JAR" -s http://localhost:8080/ -auth admin:$JENKINS_PASSWORD create-job hello-world < job-config.xml
    java -jar "$JENKINS_CLI_JAR" -s http://localhost:8080/ -auth admin:$JENKINS_PASSWORD build hello-world

    echo "Fetching job log..."

else
    echo "yum or curl is not available, aborting."
    exit 1
fi
