# Task 1: AWS Account variables

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "gha_role" {
  description = "IAM role used by GitHub Actions"
  type        = string
  default     = "GithubActionsRole"
}

variable "iam_policies" {
  description = "List of Required IAM Policies"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
}

# Task 2: networking variables

variable "vpc_cidr" {
  description = "CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}


# Task 2: EC2 variables

variable "ec2_amazon_linux_ami" {
  description = "EC2 Instance Image for Bastion Host and Testing"
  default     = "ami-070fe338fb2265e00"

}

variable "ssh_pk" {
  description = "SSH Public Key to connect to Bastion Host"
  type        = string
}

variable "ssh_inbound_ip" {
  description = "Specify CIDR block to limit inbound ssh traffic to the NAT Instance/Bastion Host"
  default     = ["0.0.0.0/0"]
}


# Task 3: k3s Setup

variable "token" {
  description = "k3s Server token for k3s Agents"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t3.medium"
}
