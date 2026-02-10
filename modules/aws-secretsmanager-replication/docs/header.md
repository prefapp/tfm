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
> **Note:** For the first replication, you must specify the expected `destination_secret_name` for each region in `destinations_json`. This ensures the Lambda creates and manages the correct secret, and the IAM policy can safely use a wildcard pattern to allow all ARNs generated for that name.

The destinations are configured via the `destinations_json` variable, which must be a JSON string with the following structure. **Each region must now include the keys `kms_key_arn`, `source_secret_arn`, and `destination_secret_name` (all required for correct IAM permissions). `destination_secret_arn` is optional and only for documentation/reference:**

```json
{
	"DEST_ACCOUNT_ID": {
		"role_arn": "arn:aws:iam::DEST_ACCOUNT_ID:role/ReplicationRole",
		"regions": {
			"us-east-1": {
				"kms_key_arn": "arn:aws:kms:us-east-1:DEST_ACCOUNT_ID:key/xxxx",
				"source_secret_arn": "arn:aws:secretsmanager:us-east-1:SOURCE_ACCOUNT_ID:secret:my-secret-xxxxxx",
				"destination_secret_name": "my-secret-copy",
				"destination_secret_arn": "arn:aws:secretsmanager:us-east-1:DEST_ACCOUNT_ID:secret:my-secret-copy-xxxxxx" // optional, for reference only
			},
			"eu-west-1": {
				"kms_key_arn": "arn:aws:kms:eu-west-1:DEST_ACCOUNT_ID:key/yyyy",
				"source_secret_arn": "arn:aws:secretsmanager:eu-west-1:SOURCE_ACCOUNT_ID:secret:my-secret-xxxxxx",
				"destination_secret_name": "my-secret-copy",
				"destination_secret_arn": "arn:aws:secretsmanager:eu-west-1:DEST_ACCOUNT_ID:secret:my-secret-copy-yyyyyy" // optional
			}
		}
	}
}
```

You can specify as many destination accounts and regions as needed. Each region must specify the KMS key, the source secret ARN, and the destination secret name. The destination ARN is optional and only for documentation.

### Tag Replication

By default, tags from the source secret are also replicated to the destination. You can control this behavior using the `enable_tag_replication` variable in Terraform. If set to `false`, tags will not be copied.

## Important Note: Permissions



**Important:**
The Lambda IAM permissions for reading and writing secrets are determined by the `source_secret_arns` and a wildcard-based ARN for each `destination_secret_name`, e.g.:

```
arn:aws:secretsmanager:<region>:<account>:secret:<destination_secret_name>*
```

This allows the Lambda to manage all ARNs generated for a given secret name, regardless of AWS-generated suffixes. The required schema for each region is:

- `kms_key_arn`: ARN of the KMS key to use for encryption in the destination region.
- `source_secret_arn`: ARN of the source secret to replicate.
- `destination_secret_name`: Name of the secret to create or update in the destination region/account.
- `destination_secret_arn`: (Optional) Example ARN for documentation/reference only.

All fields except `destination_secret_arn` are required for each region. If any are missing, the module will fail validation and the Lambda will not have permissions to read or write the intended secrets, resulting in AccessDenied errors. Ensure your `destinations_json` includes all required fields for every region.


## Architecture: Event-Driven Cross-Account Secret Replication


To replicate AWS Secrets Manager secrets between two accounts upon a change or rotation, the architecture relies on **AWS CloudTrail** as the intermediary, since Secrets Manager does not emit direct state-change events to EventBridge.

### Workflow Overview

1. **Source Action:** A change occurs in the source account via a Secrets Manager API call such as `CreateSecret` or `PutSecretValue`. **Note:** Secret rotations are handled by the `PutSecretValue` API, so the EventBridge rule triggers on both manual updates and automatic rotations.
2. **CloudTrail Capture:** This API activity is captured by a configured **CloudTrail Trail**.
3. **S3 Storage:** The Trail must be configured to deliver log files to a designated **S3 Bucket**. This ensures persistent storage and reliable delivery of the event data required for the trigger.
4. **EventBridge Trigger:** An Amazon EventBridge rule filters for the specific pattern `AWS API Call via CloudTrail`, matching `CreateSecret` and `PutSecretValue` events.
5. **Lambda Execution:** The rule triggers a **Lambda function**, which assumes an IAM role to read the secret from the source and write/update it in the destination account.

> **Important:** You cannot filter by "Secrets Manager" service events directly. You must configure the EventBridge pattern to look for specific API calls logged by CloudTrail. Rotations are fully supported because they invoke `PutSecretValue`.

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
