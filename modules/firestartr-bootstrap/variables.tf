variable "bucket_name" {
    description = "Name of the S3 Bucket used for storing the Terraform state for the workspaces"
    type = string
}

variable "dynamodb_table_name" {
    description = "Name of the locks DynamoDB table"
    type = string
}

variable "tags" {
    description = "Common tags for all resources"
    type = map(string)
    default = {}
}

variable "force_destroy" {
    description = "Allow destroying the bucket even if it contains state"
    type = bool
    default = false
}

variable "enable_versioning" {
    description = "Enable versioning on the bucket"
    type = bool
    default = true
}
