variable "bootstrap_bucket_name" {
    description = "Name of the S3 Bucket used for storing the Terraform state for the bootstrap process"
    type = string
}

variable "tfworkspaces_bucket_name" {
    description = "Name of the S3 Bucket used for storing the Terraform state for the workspaces"
    type = string
}

variable "locks_dynamodb_table_name" {
    description = "Name of the locks DynamoDB table"
    type = string
}

variable "tags" {
    description = "Common tags for all resources"
    type = map(string)
    default = {}
}