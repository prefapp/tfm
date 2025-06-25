data "aws_caller_identity" "current" {}

locals {
  cf_template = {
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Allows administrator account to assume admin role in client account"
    Resources = {
      AdminRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = var.cloudformation_admin_role_for_client_account
          AssumeRolePolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                  AWS = "arn:aws:iam::${var.aws_account_id}:role/${var.tfbackend_access_role_name}"
                }
              }
            ]
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
  }

  # Then convert to YAML
  cloudformation_template_yaml = yamlencode(local.cf_template)

  # Only create a S3 object if a bucket is specified
  should_upload = var.s3_bucket_cloudformation_role != ""
}
