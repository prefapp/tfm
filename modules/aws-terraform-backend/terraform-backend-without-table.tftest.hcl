mock_provider "aws" {
  alias = "mock"

  mock_resource "aws_s3_bucket" {
    defaults = {
      id = "test-bucket-tfstate-MOCK"
    }
  }
}

run "valid_bucket_creation" {
  providers = {
    aws = aws.mock
  }
  variables {
    bucket_name         = "test-bucket-tfstate-MOCK"
    dynamodb_table_name = null
  }
  # in order to check if the bucket was created, we check its arn
  # we can only check it if it was created, so we need the command to apply
  command = apply
  assert {
    condition     = aws_s3_bucket.this.arn != ""
    error_message = "S3 bucket was not created"
  }

  assert {
    condition     = aws_s3_bucket.this.id == var.bucket_name
    error_message = "S3 bucket was created but its name does not match the provided name"
  }
}

run "dynamodb_table_not_created" {
  providers = {
    aws = aws.mock
  }

  variables {
    bucket_name         = "test-bucket-tfstate-MOCK"
    dynamodb_table_name = null
  }

  # in order to check if the bucket was created, we check its arn
  # we can only check it if it was created, so we need the command to apply
  command = apply
  assert {
    condition     = length(aws_dynamodb_table.this) == 0
    error_message = "A DynamoDB table was created but it should have not"
  }
}
