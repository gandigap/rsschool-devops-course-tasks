#!/bin/bash

# Enable selinux
sudo amazon-linux-extras enable selinux-ng
sudo yum install selinux-policy-targeted -y

# Install k3s Server
curl -sfL https://get.k3s.io | K3S_TOKEN = ${token} sh -s -

# Configure kubeconfig for non-root access
sudo ln -s /usr/local/bin/k3s /usr/bin/k3s
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chmod 600 ~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc

# Add user_data param to aws_instance "k3s_server"
#  user_data = templatefile("k3s_server.sh", {
#    token = var.token
#  })