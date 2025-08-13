data "aws_caller_identity" "current" {}

locals {
  main_account_id  = var.main_role.aws_account_id != null && var.main_role.aws_account_id != "" ? var.main_role.aws_account_id : data.aws_caller_identity.current.account_id
  aux_account_id   = var.aux_role.aws_account_id != null && var.aux_role.aws_account_id != "" ? var.aux_role.aws_account_id : data.aws_caller_identity.current.account_id
  aux_role_enabled = var.create_aux_role ? true : false


  aux_role_resource = {
    count = var.generate_cloudformation_role_for_external_account ? 1 : 0

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
                AWS = "arn:aws:iam::${local.aux_account_id}:role/${var.aux_role.name}"
              }
            }
          ]
        }
        ManagedPolicyArns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      }
    }
  }

  main_role_resource = {
    count = var.generate_cloudformation_role_for_external_account ? 1 : 0

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
                AWS = "arn:aws:iam::${local.main_account_id}:role/${var.main_role.name}"
              }
            }
          ]
        }
        ManagedPolicyArns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      }
    }
  }


  cf_template = {
    count = var.generate_cloudformation_role_for_external_account ? 1 : 0

    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Firestartr Admin role"
    Resources = merge(
      local.main_role_resource,
      local.aux_role_enabled ? local.aux_role_resource : tomap({})
    )
    Outputs = merge(
      {
        AdminRoleARN = {
          Description = "ARN of the created admin role"
          Value       = { "Ref" = "AdminRole" }
        }
      },
      local.aux_role_enabled ? {
        ReadOnlyRoleARN = {
          Description = "ARN of the created read-only role"
          Value       = { "Ref" = "ReadOnlyRole" }
        }
      } : {}
    )
  }

  # Then convert to YAML
  cloudformation_template_yaml = var.generate_cloudformation_role_for_external_account ? yamlencode(local.cf_template[0]) : null

  # Only create a S3 object if a bucket is specified and the cloudformation for the roles in the external accounit is generated
  should_upload = var.s3_bucket_cloudformation_role != "" && var.generate_cloudformation_role_for_external_account
}
