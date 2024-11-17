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
