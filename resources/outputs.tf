# Outputs for resource ARNs and IDs
output "s3_bucket_id" {
  value = aws_s3_bucket.my_test_bucket_rs.id
}

output "iam_role_arn" {
  value = aws_iam_role.terraform_github_actions_role.arn
}
