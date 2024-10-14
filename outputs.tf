
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

output "eip" {
  value = aws_eip.public_ip.public_ip
}

output "security_group_arn" {
  value = aws_security_group.nat_sg.arn
}

output "security_group_id" {
  value = aws_security_group.nat_sg.id
}

output "network_interface_id" {
  value = aws_network_interface.nat_interface.id
}

output "nat_instance_public_ip_address" {
  value = aws_instance.nat_instance.public_ip
}

output "nat_instance_private_ip_address" {
  value = aws_instance.nat_instance.private_ip
}

output "test_ec2_public_ip_address" {
  value = aws_instance.test_ec2.public_ip
}

output "test_ec2_private_ip_address" {
  value = aws_instance.test_ec2.private_ip
}
