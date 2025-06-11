locals {
  user_arn = "arn:aws:iam::${var.aws_account_id}:root"
  role_arn = var.aws_account_role != null ? "arn:aws:iam::${var.aws_account_id}:role/${var.aws_account_role}" : null

  # First create the data structure
  cf_template = {
    "AWSTemplateFormatVersion" : "2010-09-09",
    "Description" : "Creates admin role with full AWS permissions",
    "Parameters" : {
      "TrustedAccountId" : {
        "Type" : "String",
        "Description" : "Account ID where trusted entities reside"
      },
      "TrustedIAMUser" : {
        "Type" : "String",
        "Description" : "IAM username allowed to assume this role"
      },
      "TrustedIAMRole" : {
        "Type" : "String",
        "Description" : "IAM role name allowed to assume this role",
        "Default" : ""
      }
    },
    "Resources" : {
      "AdminRole" : {
        "Type" : "AWS::IAM::Role",
        "Properties" : {
          "RoleName" : { "Ref" : "AWS::StackName" },
          "AssumeRolePolicyDocument" : {
            "Version" : "2012-10-17",
            "Statement" : [
              {
                "Effect" : "Allow",
                "Action" : "sts:AssumeRole",
                "Principal" : {
                  "AWS" : { "Fn::Sub" : "arn:aws:iam::${var.aws_account_id}:root" }
                },
                "Condition" : {
                  "ArnLike" : {
                    "aws:PrincipalArn" : [
                      { "Fn::Sub" : "arn:aws:iam::${var.aws_account_id}:user/${var.aws_iam_user}" },
                      { "Fn::If" : [
                        "HasRole",
                        { "Fn::Sub" : "arn:aws:iam::${var.aws_account_id}:role/${var.aws_account_role}" },
                        { "Ref" : "AWS::NoValue" }
                      ] }
                    ]
                  }
                }
              }
            ]
          },
          "ManagedPolicyArns" : [
            "arn:aws:iam::aws:policy/AdministratorAccess"
          ]
        }
      }
    },
    "Outputs" : {
      "RoleARN" : {
        "Description" : "ARN of the created admin role",
        "Value" : { "Ref" : "AdminRole" }
      }
    }
  }

  # Then convert to YAML
  cloudformation_template_yaml = yamlencode(local.cf_template)

  # Only create a S3 object if a bucket is specified
  should_upload = var.s3_bucket_cloudformation_role != ""
}
