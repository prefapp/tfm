# **AWS Systems Manager Parameter Store Replication Terraform Module**

## Overview

This Terraform module provisions and manages a Lambda function for cross-account and cross-region replication of AWS Systems Manager Parameter Store parameters. It automates the deployment of the Lambda, IAM roles, permissions, and (optionally) EventBridge rules to trigger parameter replication on changes.

The module is designed for secure and automated parameter replication, supporting flexible configuration of destination accounts and regions. It is suitable for organizations that need to synchronize configuration parameters across multiple AWS environments for Disaster Recovery or multi-region scenarios.

## Key Features

- **Parameter Replication**: Automatically replicates parameters to one or more destination AWS accounts and/or regions.
- **Event-Driven**: Uses EventBridge to trigger replication when a parameter is created or updated (optional).
- **Customizable Destinations**: Configure multiple destination accounts and regions, each with its own IAM role and KMS key.
- **IAM Role Management**: Creates all necessary IAM roles and policies for Lambda execution and cross-account access.
- **Environment Variables**: Supports custom environment variables for advanced configuration.
- **Tag Replication**: Optionally replicates tags from the source parameter to the destination (controlled by the `enable_tag_replication` variable).
- **Parameter Type Support**: Handles String, StringList, and SecureString parameter types.

## Parameter Replication Logic

This module deploys a Lambda function that listens for changes in AWS Systems Manager Parameter Store via EventBridge (if enabled). When a parameter is modified, the Lambda replicates it to the configured destinations, assuming roles as needed. The replication supports both parameter value and tags (if enabled).

The Lambda determines:

- the **source parameter** from the EventBridge event (automatic mode),
- from the `parameter_name` parameter (manual mode),
- or from `describe_parameters()` (full sync mode).

The **destination parameter name matches the source parameter name by default**. If `add_region_prefix_to_name = true`, the destination name is prefixed with the source region (for example, `eu-west-1-/my/parameter`).

### Destination Configuration Format

The destinations are configured via the `destinations_json` variable, which must be a JSON string with the following structure:

```json
{
  "DEST_ACCOUNT_ID": {
    "role_arn": "arn:aws:iam::DEST_ACCOUNT_ID:role/ReplicationRole",
    "regions": {
      "us-east-1": {
        "kms_key_arn": "arn:aws:kms:us-east-1:DEST_ACCOUNT_ID:key/xxxx"
      },
      "eu-west-1": {
        "kms_key_arn": "arn:aws:kms:eu-west-1:DEST_ACCOUNT_ID:key/yyyy"
      },
      "eu-north-1": {}
    }
  }
}
```

You can specify as many destination accounts and regions as needed. Each region may optionally specify a KMS key.

### KMS Key Selection

You can optionally specify a custom KMS key for each destination region in the `destinations_json` variable using the `kms_key_arn` field. If the value is ommited, the AWS managed key will be used.

```json
{
  "DEST_ACCOUNT_ID": {
    "role_arn": "arn:aws:iam::DEST_ACCOUNT_ID:role/ReplicationRole",
    "regions": {
      "eu-west-1": {
        "kms_key_arn": "arn:aws:kms:eu-west-1:DEST_ACCOUNT_ID:key/abcd-1234-efgh-5678"
      },
      "us-east-1": {}
    }
  }
}
```

- If `kms_key_arn` is set for a region, the replicated parameter will be encrypted with that KMS key (for SecureString parameters).
- If `kms_key_arn` is omitted for a region, the parameter will be encrypted using the default AWS managed key for Parameter Store in that region.

This allows you to mix and match custom and managed keys as needed for your security requirements.

### Tag Replication

By default, tags from the source parameter are also replicated to the destination. You can control this behavior using the `enable_tag_replication` variable in Terraform. If set to `false`, tags will not be copied.

## Important Note: Permissions

**Important:**
 The Lambda IAM permissions for writing parameters in destination accounts are based on the **source parameter name**, which is reused as the destination parameter name.

The IAM policy must allow:

```
arn:aws:ssm:<region>:<account>:parameter/<parameter_name>
```

This allows the Lambda to manage the parameter across all its versions.

## Basic Usage

### Simple Cross-Region Replication

```hcl
module "parameter_replication" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-parameter-store-replication"

  name   = "my-app-parameters"
  prefix = "myorg"

  destinations_json = jsonencode({
    "123456789012" = {
      "role_arn" = "arn:aws:iam::123456789012:role/ParameterReplicationRole"
      "regions" = {
        "us-east-1" = {}
        "eu-west-1" = {}
      }
    }
  })

  allowed_assume_roles = [
    "arn:aws:iam::123456789012:role/ParameterReplicationRole"
  ]

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Cross-Account Replication with EventBridge

```hcl
module "parameter_replication_eventbridge" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-parameter-store-replication"

  name   = "multi-account-parameters"
  prefix = "corp"

  eventbridge_enabled = true

  destinations_json = jsonencode({
    "111111111111" = {
      "role_arn" = "arn:aws:iam::111111111111:role/ParameterReplicationRole"
      "regions" = {
        "us-east-1" = {
          "kms_key_arn" = "arn:aws:kms:us-east-1:111111111111:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        }
      }
    }
    "222222222222" = {
      "role_arn" = "arn:aws:iam::222222222222:role/ParameterReplicationRole"
      "regions" = {
        "eu-west-1" = {}
      }
    }
  })

  allowed_assume_roles = [
    "arn:aws:iam::111111111111:role/ParameterReplicationRole",
    "arn:aws:iam::222222222222:role/ParameterReplicationRole"
  ]

  tags = {
    Service = "configuration-sync"
  }
}
```
