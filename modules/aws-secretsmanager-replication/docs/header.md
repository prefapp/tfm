# **AWS Secrets Manager Replication Terraform Module**

## Overview

This Terraform module provisions and manages a Lambda function for cross-account and cross-region replication of AWS Secrets Manager secrets. It automates the deployment of the Lambda, IAM roles, permissions, and (optionally) EventBridge rules to trigger secret replication on changes.

The module is designed for secure and automated secret replication, supporting flexible configuration of destination accounts and regions. It is suitable for organizations that need to synchronize secrets across multiple AWS environments for Disaster Recovery or multi-region scenarios.

## Key Features

- **Secrets Replication**: Automatically replicates secrets to one or more destination AWS accounts and/or regions.
- **Event-Driven**: Uses EventBridge to trigger replication when a secret is created or updated (optional).
- **Customizable Destinations**: Configure multiple destination accounts and regions, each with its own IAM role and KMS key.
- **IAM Role Management**: Creates all necessary IAM roles and policies for Lambda execution and cross-account access.
- **Environment Variables**: Supports custom environment variables for advanced configuration.
- **Tag Replication**: Optionally replicates tags from the source secret to the destination (controlled by the `enable_tag_replication` variable).

## Secret Replication Logic

This module deploys a Lambda function that listens for changes in AWS Secrets Manager via EventBridge (if enabled). When a secret is modified, the Lambda replicates it to the configured destinations, assuming roles as needed. The replication supports both secret value and tags (if enabled).

The Lambda determines:

- the **source secret** from the EventBridge event (automatic mode),
- from the `secret_id` parameter (manual mode),
- or from `list_secrets()` (full sync mode).

The **destination secret name is always the same as the source secret name**, simplifying configuration and IAM permissions.

### Destination Configuration Format

The destinations are configured via the `destinations_json` variable, which must be a JSON string with the following structure.
 **Each region now only requires the key `kms_key_arn`.**
 The module no longer uses `source_secret_arn`, `destination_secret_name`, or `destination_secret_arn`.

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
      }
    }
  }
}
```

You can specify as many destination accounts and regions as needed.
 Each region must specify the KMS key to use for encryption in that region.

### Tag Replication

By default, tags from the source secret are also replicated to the destination. You can control this behavior using the `enable_tag_replication` variable in Terraform. If set to `false`, tags will not be copied.

## Important Note: Permissions

**Important:**
 The Lambda IAM permissions for writing secrets in destination accounts are based on the **source secret name**, which is reused as the destination secret name.

The IAM policy must allow:

```
arn:aws:secretsmanager:<region>:<account>:secret:<secret_name>*
```

This wildcard allows the Lambda to manage all ARNs generated for a given secret name, regardless of AWS-generated suffixes.

The required schema for each region is now:

- `kms_key_arn`: ARN of the KMS key to use for encryption in the destination region.

All other fields previously required (`source_secret_arn`, `destination_secret_name`, `destination_secret_arn`) have been removed from the module and are no longer used.

## Architecture: Event-Driven Cross-Account Secret Replication

To replicate AWS Secrets Manager secrets between two accounts upon a change or rotation, the architecture relies on **AWS CloudTrail** as the intermediary, since Secrets Manager does not emit direct state-change events to EventBridge.

### Workflow Overview

1. **Source Action:** A change occurs in the source account via a Secrets Manager API call such as `CreateSecret` or `PutSecretValue`.
    Secret rotations are also handled because they invoke `PutSecretValue`.
2. **CloudTrail Capture:** This API activity is captured by a configured **CloudTrail Trail**.
3. **S3 Storage:** The Trail must be configured to deliver log files to a designated **S3 Bucket**.
4. **EventBridge Trigger:** An Amazon EventBridge rule filters for the pattern `AWS API Call via CloudTrail`, matching `CreateSecret` and `PutSecretValue` events.
5. **Lambda Execution:** The rule triggers a Lambda function, which assumes an IAM role to read the secret from the source and write/update it in the destination account.

### Required Resources & Links

- **CloudTrail:** Must be enabled to log management events.
  - Logging Secrets Manager events with CloudTrail [docs.aws.amazon.com](https://docs.aws.amazon.com/secretsmanager/latest/userguide/monitoring-cloudtrail.html)
- **S3 Bucket:** Required for storing CloudTrail logs.
  - Creating a trail for your AWS account [docs.aws.amazon.com](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-and-update-a-trail.html)
- **EventBridge:** Configured to listen to CloudTrail API calls.
  - Monitoring Secrets Manager with Amazon EventBridge [docs.aws.amazon.com](https://docs.aws.amazon.com/secretsmanager/latest/userguide/monitoring-eventbridge.html)

## Using Pre-Existing CloudTrail and S3 Buckets (Control Tower / Landing Zone)

In AWS Control Tower or Landing Zone environments, CloudTrail trails and S3 buckets for log storage are often provisioned centrally and shared across accounts. This module fully supports integration with these pre-existing resources.

**How to use:**

- Set `cloudtrail_name` to the name of the existing CloudTrail trail.
- Set `s3_bucket_name` to the name of the existing S3 bucket used by that trail.

The module will:

- Reference the existing CloudTrail and S3 bucket instead of creating new ones.
- Not attempt to modify or manage the lifecycle of these resources.
- Allow disabling S3 bucket policy management via `manage_s3_bucket_policy = false`.

**Important considerations:**

- The S3 bucket policy must allow CloudTrail to write logs.
- Both variables must be provided when using a pre-existing CloudTrail.
- This approach is recommended for centralized logging environments.

**Example:**

```hcl
module "secrets_replication" {
  # ... other variables ...
  cloudtrail_name         = "centralized-org-trail"
  s3_bucket_name          = "centralized-logs-bucket"
  manage_s3_bucket_policy = false
}
```

## EventBridge Rule Pattern (Secrets Manager)

The EventBridge rule should match Secrets Manager API calls via CloudTrail. Example pattern:

```json
{
  "source": ["aws.secretsmanager"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventName": ["PutSecretValue", "CreateSecret"]
  }
}
```

This ensures the rule triggers on all relevant Secrets Manager API calls recorded by CloudTrail.

## Required IAM Role in Destination Account

The destination account must have an IAM role that the replication Lambda can assume. This role should be specified in `destinations_json` as `role_arn` for each destination account.

### Minimum Policy for Secrets Manager Replication

```jsonc
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:CreateSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecret",
        "secretsmanager:DescribeSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UntagResource",
        "secretsmanager:UpdateSecretVersionStage",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "arn:aws:secretsmanager:<region>:<account>:secret:<secret_name>*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ],
      "Resource": [
        "<kms_key_arn>"
      ]
    }
  ]
}
```

- Replace `<region>`, `<account>`, `<secret_name>`, and `<kms_key_arn>` with the actual values for your setup.
- The role must be assumable by the Lambda's source account. Example trust policy:

```jsonc
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::<source_account_id>:root" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

> You may need to further restrict or expand permissions depending on your organization's security requirements.

------
