terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

module "s3_bucket_tfworkspaces" {
    source = "terraform-aws-modules/s3-bucket/aws"
    version = "~> 3.0"

    bucket = var.tfworkspaces_bucket_name
    tags = var.tags

    versioning = {
        enabled = true
    }
}

module "locks_dynamodb_table" {
    source = "terraform-aws-modules/dynamodb-table/aws"
    version = "~> 3.0"

    name = var.locks_dynamodb_table_name
    hash_key = "id"
    tags = var.tags

    attributes = [
        {
            name = "id"
            type = "S"
        }
    ]

    billing_mode = "PROVISIONED"
    read_capacity = 5
    write_capacity = 5
    
}