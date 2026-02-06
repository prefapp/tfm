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
			}
		}
	}
}
```

You can specify as many destination accounts and regions as needed. Each region must specify the KMS key to use for secret encryption.

### Tag Replication

By default, tags from the source secret are also replicated to the destination. You can control this behavior using the `enable_tag_replication` variable in Terraform. If set to `false`, tags will not be copied.

## Important Note: Permissions

Ensure that the destination roles have the necessary permissions to create and update secrets in the target accounts/regions. The source Lambda role must also have permission to assume these roles and read the source secrets.


## Architecture: Event-Driven Cross-Account Secret Replication

To replicate AWS Secrets Manager secrets between two accounts upon a change or rotation, the architecture must rely on **AWS CloudTrail** as the intermediary, as Secrets Manager does not emit direct state-change events to EventBridge.

### Workflow Overview

1. **Source Action:** A change occurs in the source account (e.g., `RotateSecret`, `PutSecretValue`, or `UpdateSecret`).
2. **CloudTrail Capture:** This API activity is captured by a configured **CloudTrail Trail**.
3. **S3 Storage:** The Trail must be configured to deliver log files to a designated **S3 Bucket**. This ensures persistent storage and reliable delivery of the event data required for the trigger.
4. **EventBridge Trigger:** An Amazon EventBridge rule filters for the specific pattern `AWS API Call via CloudTrail`.
5. **Lambda Execution:** The rule triggers a **Lambda function**, which assumes an IAM role to read the secret from the source and write/update it in the destination account.

> **Important:** You cannot filter by "Secrets Manager" service events directly. You must configure the EventBridge pattern to look for specific API calls logged by CloudTrail.

### Required Resources & Links

- **CloudTrail:** You must ensure a Trail is enabled to log management events.
  - [Logging Secrets Manager events with CloudTrail](https://docs.aws.amazon.com/secretsmanager/latest/userguide/monitoring-cloudtrail.html)
- **S3 Bucket:** Required for storing CloudTrail logs.
  - [Creating a trail for your AWS account](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-and-update-a-trail.html)
- **EventBridge:** Configured to listen to CloudTrail API calls.
  - [Monitoring Secrets Manager with Amazon EventBridge](https://docs.aws.amazon.com/secretsmanager/latest/userguide/monitoring-eventbridge.html)

## Using Pre-Existing CloudTrail and S3 Buckets (Control Tower / Landing Zone)

In AWS Control Tower or Landing Zone environments, CloudTrail trails and S3 buckets for log storage are often provisioned centrally and shared across accounts. This module fully supports integration with these pre-existing resources.

**How to use:**
- Set the `cloudtrail_name` variable to the name of the existing CloudTrail trail.
- Set the `s3_bucket_name` variable to the name of the existing S3 bucket used by that trail.

The module will:
- Reference the existing CloudTrail and S3 bucket instead of creating new ones.
- Not attempt to modify or manage the lifecycle of these resources.
- Optionally, you can disable the S3 bucket policy management with `manage_s3_bucket_policy = false` if bucket policies are managed centrally.

**Important considerations:**
- The S3 bucket policy must allow CloudTrail to write logs (see AWS documentation for required permissions).
- You must provide both variables if using a pre-existing CloudTrail; otherwise, the module cannot determine where logs are stored.
- This approach is recommended for organizations with centralized logging and compliance requirements.

**Example:**
```hcl
module "secrets_replication" {
  # ... other variables ...
  cloudtrail_name         = "centralized-org-trail"
  s3_bucket_name          = "centralized-logs-bucket"
  manage_s3_bucket_policy = false
}
```
