# Task 1: AWS Account Setup Outputs

output "aws_region" {
  value       = var.region
  description = "The AWS region"
}

output "GHA_role_name" {
  description = "GHA Role Name"
  value       = aws_iam_role.terraform_gha_role.name
  sensitive   = false
}

output "GHA_role_arn" {
  description = "GHA Role ARN"
  value       = aws_iam_role.terraform_gha_role.arn
  sensitive   = true
}

# Task 2: Networking Resources Outputs

output "network_interface_id" {
  value = aws_network_interface.nat_interface.id
}

output "eip" {
  value = aws_eip.public_ip.public_ip
}

output "nat_instance_public_ip_address" {
  value = aws_instance.nat_instance.public_ip
}

output "nat_instance_private_ip_address" {
  value = aws_instance.nat_instance.private_ip
}

# Task 3: k3s Setup

output "nat_security_group_arn" {
  value = aws_security_group.nat_sg.arn
}

output "k3s_server_security_group_arn" {
  value = aws_security_group.k3s_server_sg.arn
}

output "k3s_agent_security_group_arn" {
  value = aws_security_group.k3s_agent_sg.arn
}

output "k3s_server_public_ip_address" {
  value = aws_instance.k3s_server.public_ip
}

output "k3s_server_private_ip_address" {
  value = aws_instance.k3s_server.private_ip
}

output "k3s_agent_public_ip_address" {
  value = aws_instance.k3s_agent.public_ip
}

output "k3s_agent_private_ip_address" {
  value = aws_instance.k3s_agent.private_ip
}