locals {
  user_arn = "arn:aws:iam::${var.aws_account_id}:user/${var.aws_iam_user}"
  role_arn = var.aws_account_role != null ? "arn:aws:iam::${var.aws_account_id}:role/${var.aws_account_role}" : null

  # CloudFormation template
  cloudformation_template = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Creates admin role with full AWS permissions"
    Resources = {
      AdminRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = var.aws_account_role
          AssumeRolePolicyDocument = {
            Version = "2012-10-17"
            Statement = [{
              Effect = "Allow"
              Action = "sts:AssumeRole"
              Principal = {
                AWS = compact([local.user_arn, local.role_arn])
              }
            }]
          }
          ManagedPolicyArns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
        }
      }
    }
    Outputs = {
      RoleARN = {
        Description = "ARN of the created admin role"
        Value       = { "Ref" = "AdminRole" }
      }
    }
  })

  # Only create a S3 object if a bucket is specified
  should_upload = var.s3_bucket_cloudformation_role != ""
}
