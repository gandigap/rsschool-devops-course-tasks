#!/bin/bash
# Enable selinux
sudo amazon-linux-extras enable selinux-ng
sudo yum install selinux-policy-targeted -y

# Install k3s Agent
curl -sfL https://get.k3s.io | K3S_URL="https://${server_addr}:6443" K3S_TOKEN=${token} sh -s -

# Add user_data param to aws_instance "k3s_agent"
# depends_on = [aws_instance.k3s_server]
# user_data = templatefile("k3s_agent.sh", {
#   token       = var.token,
#   server_addr = aws_instance.k3s_server.private_ip
# })