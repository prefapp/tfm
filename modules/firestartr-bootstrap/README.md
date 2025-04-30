<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [eks](#module\_s3_bucket_) | terraform-aws-modules/s3-bucket/aws | ~> 3.0 |
| <a name="module_dynamodb_table"></a> [eks](#module\_dynamodb_table) | terraform-aws-modules/dynamodb_table/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tfworkspaces_bucket_name | "Name of the S3 Bucket used for storing the Terraform state for the workspaces" | string | "" | Y |
| locks_dynamodb_table_name | "Name of the locks DynamoDB table" | string | "" | Y |
| tags | "Common tags for all resources" | string | "" | Y |


## Outputs

| Name | Description |
|------|-------------|
| tfworskpaces_bucket_arn | "tfworkspaces bucket's ARN" |
| locks_dynamodb_table_arn | "Locks' DynamoDB table's ARN" |
| locks_dynamodb_table_id | "Locks' DynamoDB table's ID" |

<!-- END_TF_DOCS -->

