data "aws_caller_identity" "current" {}

locals {
  # Account IDs with fallback to current account
  admin_account_id     = var.roles.admin.aws_account_id != null && var.roles.admin.aws_account_id != "" ? var.roles.admin.aws_account_id : data.aws_caller_identity.current.account_id
  readwrite_account_id = var.roles.readwrite != null && var.roles.readwrite.aws_account_id != null && var.roles.readwrite.aws_account_id != "" ? var.roles.readwrite.aws_account_id : data.aws_caller_identity.current.account_id

  # Determine if readwrite role is enabled
  readwrite_enabled = var.roles.readwrite != null

  # CloudFormation resource for Admin role
  admin_role_resource = {
    AdminRole = {
      Type = "AWS::IAM::Role"
      Properties = {
        RoleName = var.roles.admin.external_role_name
        AssumeRolePolicyDocument = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = "sts:AssumeRole"
              Principal = {
                AWS = "arn:aws:iam::${local.admin_account_id}:role/${var.roles.admin.name}"
              }
            }
          ]
        }
        ManagedPolicyArns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
        Tags = [
          for key, value in var.tags : {
            Key   = key
            Value = value
          }
        ]
      }
    }
  }

  # CloudFormation inline policy for ReadWrite S3 access
  readwrite_s3_policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BackendBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.this.arn
      },
      {
        Sid    = "S3BackendObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  }

  # CloudFormation resource for ReadWrite role
  readwrite_role_resource = local.readwrite_enabled ? {
    ReadWriteRole = {
      Type = "AWS::IAM::Role"
      Properties = {
        RoleName = var.roles.readwrite.external_role_name
        AssumeRolePolicyDocument = {
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = "sts:AssumeRole"
              Principal = {
                AWS = "arn:aws:iam::${local.readwrite_account_id}:role/${var.roles.readwrite.name}"
              }
            }
          ]
        }
        Policies = [
          {
            PolicyName     = "TerraformBackendReadWrite"
            PolicyDocument = local.readwrite_s3_policy
          }
        ]
        Tags = [
          for key, value in var.tags : {
            Key   = key
            Value = value
          }
        ]
      }
    }
  } : {}

  # Complete CloudFormation template
  cf_template = {
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Terraform Backend IAM Roles - Admin and ReadWrite access"

    Resources = merge(
      local.admin_role_resource,
      local.readwrite_role_resource
    )

    Outputs = merge(
      {
        AdminRoleARN = {
          Description = "ARN of the admin role with full administrative access"
          Value       = { "Ref" = "AdminRole" }
          Export = {
            Name = "${var.roles.admin.external_role_name}-ARN"
          }
        }
      },
      local.readwrite_enabled ? {
        ReadWriteRoleARN = {
          Description = "ARN of the read-write role with S3 backend access"
          Value       = { "Ref" = "ReadWriteRole" }
          Export = {
            Name = "${var.roles.readwrite.external_role_name}-ARN"
          }
        }
      } : {}
    )
  }

  # Convert to YAML
  cloudformation_template_yaml = var.generate_cloudformation_roles ? yamlencode(local.cf_template) : null

  # Determine if template should be uploaded to S3
  should_upload = var.cloudformation_s3_bucket != "" && var.upload_cloudformation_template && var.generate_cloudformation_roles
}
