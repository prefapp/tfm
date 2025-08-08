data "aws_caller_identity" "current" {}

locals {
  readonly_role_enabled = var.create_aux_role ? true : false

  aux_role_resource = {
    ReadOnlyRole = {
      Type = "AWS::IAM::Role"
      Properties = {
        RoleName = var.external_aux_role
        AssumeRolePolicyDocument = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = "sts:AssumeRole"
              Principal = {
                AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.aux_role_name}"
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
        RoleName = var.external_main_role
        AssumeRolePolicyDocument = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = "sts:AssumeRole"
              Principal = {
                AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.main_role_name}"
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
    Resources                = merge(local.admin_role_resource, local.readonly_role_enabled ? local.aux_role_resource : {})
    Outputs = merge(
      {
        AdminRoleARN = {
          Description = "ARN of the created admin role"
          Value       = { "Ref" = "AdministratorAccess" }
        }
      },
      local.readonly_role_enabled ? {
        ReadOnlyRoleARN = {
          Description = "ARN of the created read-only role"
          Value       = { "Ref" = "ReadOnlyAccess" }
        }
      } : {}
    )
  }

  # Then convert to YAML
  cloudformation_template_yaml = yamlencode(local.cf_template)

  # Only create a S3 object if a bucket is specified
  should_upload = var.s3_bucket_cloudformation_role != ""
}
