locals {
  # user_arn = "arn:aws:iam::${var.aws_account_id}:root"
  # role_arn = var.aws_account_role != null ? "arn:aws:iam::${var.aws_account_id}:role/${var.aws_admin_role}" : null

  cf_template = {
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Allows administrator account to assume admin role in client account"
    Resources = {
      AdminRole = {
        Type = "AWS::IAM::Role"
        Properties = {
          RoleName = var.aws_account_role
          AssumeRolePolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                  # The principal must be root of the aws_account_id
                  # It can not be a role in that account, it is not allowed directly
                  # Here, AWS expects, as a principal, either an IAM user, an account root or a service principal
                  AWS = "arn:aws:iam::${var.aws_account_id}:root"
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
