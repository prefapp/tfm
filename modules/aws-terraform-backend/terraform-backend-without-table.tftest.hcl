variables {
  unique_id           = uuid()
  bucket_name         = "test-bucket-tfstate-${setup.random_string}"
  dynamodb_table_name = null
}

run "valid_bucket_creation" {
  variables {
    bucket_name         = "test-bucket-tfstate-${var.unique_id}"
    dynamodb_table_name = null
  }
  # in order to check if the bucket was created, we check its arn
  # we can only check it if it was created, so we need the command to apply
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
  variables {
    bucket_name         = "test-bucket-tfstate-${var.unique_id}"
    dynamodb_table_name = null
  }
  command = plan
  assert {
    condition     = length(aws_dynamodb_table.this) == 0
    error_message = "A DynamoDB table was created but it should have not"
  }
}