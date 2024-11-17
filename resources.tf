# Task 1: AWS Account Setup Resources

# GHA Role Provision via OIDC
resource "aws_iam_openid_connect_provider" "gha_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"] # not required

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


resource "aws_ecr_repository" "js_app_repository" {
  name = "js-app-repository"
}

resource "aws_iam_role" "ecr_role" {
  name = "ecr_push_pull_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

