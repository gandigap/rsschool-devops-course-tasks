
# Task 1: AWS Account Setup Resources

# GHA Role Provision via OIDC
resource "aws_iam_openid_connect_provider" "gha_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

# Prepare OIDC policy
data "aws_iam_policy_document" "oidc_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gha_oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"] # Audience for AWS STS
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:gandigap/rsschool-devops-course-tasks:*"] # Restrict source to course repo
    }
  }
}

# Create Role
resource "aws_iam_role" "terraform_gha_role" {
  name               = var.gha_role
  assume_role_policy = data.aws_iam_policy_document.oidc_policy.json
}

# Attach Policies to the role
resource "aws_iam_role_policy_attachment" "attach_policies" {
  for_each   = toset(var.iam_policies)
  role       = aws_iam_role.terraform_gha_role.name
  policy_arn = each.value
}

# Task 2: Networking Resources

# Create a key pair and load Public Key into environment
resource "aws_key_pair" "ssh_key" {
  key_name   = "bh_key_pair"
  public_key = var.ssh_pk
}

# Deploy IGW for Public Subnet
resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "aws-devops-terraform-igw"
  }
  vpc_id = aws_vpc.main_vpc.id
}

# Deploy ENI for NAT Instance (Note: Create A suitable SG for NAT Instance first)
resource "aws_network_interface" "nat_interface" {
  security_groups   = [aws_security_group.nat_sg.id]
  subnet_id         = aws_subnet.public_subnet_1.id
  source_dest_check = false
  description       = "ENI for NAT instance"
}

resource "aws_eip" "public_ip" {
  domain            = "vpc"
  network_interface = aws_network_interface.nat_interface.id
  tags = {
    Name = "Public IP for NAT Instance"
  }
}

