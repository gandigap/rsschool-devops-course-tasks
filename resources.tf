resource "aws_s3_bucket" "my-test-bucket-rs" {}

resource "aws_iam_openid_connect_provider" "github_actions_IODC_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]

  tags = {
    Name = var.terraform_github_actions_IODC_provider_name
  }
}


data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions_IODC_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:gandigap/rsschool-devops-course-tasks:*"]
    }
  }
}

# Create role
resource "aws_iam_role" "terraform_github_actions_role" {
  name               = var.terraform_github_actions_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json

  tags = {
    Name = var.terraform_github_actions_role_name
  }
}


# Attach policies
resource "aws_iam_role_policy_attachment" "attach_policies" {
  for_each   = toset(var.required_iam_policies)
  role       = aws_iam_role.terraform_github_actions_role.name
  policy_arn = each.value
}
