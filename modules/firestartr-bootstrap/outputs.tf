output "bootstrap_bucket_arn" {
    description = "Bootstrap S3 bucket's ARN"
    value = module.s3_bucket_bootstrap.s3_bucket_arn
}

output "tfworskpaces_bucket_arn" {
    description = "tfworkspaces bucket's ARN"
    value = module.s3_bucket_tfworkspaces_arn
}

output "locks_dynamodb_table_arn" {
    description = "Locks' DynamoDB table's ARN"
    value = module.locks_dynamodb_table_arn
}

output "locks_dynamodb_table_id" {
    description = "Locks' DynamoDB table's ID"
    value = module.locks_dynamodb_table_id
}