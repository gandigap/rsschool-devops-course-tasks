variable "aws_region" {
  description = "Default AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "terraform_github_actions_role_name" {
  description = "IAM RSSchool role used by GitHub Actions"
  type        = string
  default     = "GithubActionsRole"
}

variable "terraform_github_actions_IODC_provider_name" {
  description = "The Name of the GitHub Actions IODC provider"
  type        = string
  default     = "GitHub Actions OIDC Provider"
}

variable "required_iam_policies" {
  description = "The List of Required IAM Policies"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
  ]
}