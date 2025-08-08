data "aws_caller_identity" "current" {}

locals {
  readonly_role_enabled = var.create_readonly_role ? true : false

  readonly_role_resource = {
    ReadOnlyRole = {
      Type = "AWS::IAM::Role"
      Properties = {
        RoleName = var.cloudformation_readonly_role_for_client_account
        AssumeRolePolicyDocument = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = "sts:AssumeRole"
              Principal = {
                AWS = "arn:aws:iam::${var.aws_client_account_id}:role/${var.readonly_tfstate_access_role_name}"
              }
            }
          ]
        }
        ManagedPolicyArns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      }
    }
  }

  admin_role_resource = {
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
                AWS = "arn:aws:iam::${var.aws_client_account_id}:role/${var.tfbackend_access_role_name}"
              }
            }
          ]
        }
        ManagedPolicyArns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      }
    }
  }


  cf_template = {
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Allows administrator account to assume admin role in client account"
    Resources                = merge(local.admin_role_resource, local.readonly_role_enabled ? local.readonly_role_resource : {})
    Outputs = merge(
      {
        AdminRoleARN = {
          Description = "ARN of the created admin role"
          Value       = { "Ref" = "AdminRole" }
        }
      },
      local.readonly_role_enabled ? {
        ReadOnlyRoleARN = {
          Description = "ARN of the created read-only role"
          Value       = { "Ref" = "ReadOnlyRole" }
        }
      } : {}
    )
  }

  # Then convert to YAML
  cloudformation_template_yaml = yamlencode(local.cf_template)

  # Only create a S3 object if a bucket is specified
  should_upload = var.s3_bucket_cloudformation_role != ""
}
