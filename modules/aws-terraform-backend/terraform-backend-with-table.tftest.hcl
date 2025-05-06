variables {
    bucket_name = "test-bucket-terraform-state-viwumcvfagnr"
    dynamodb_table_name = "test-table-terraform-state-viwumcvfagnr"
}

run "valid_bucket_creation" {    
    # in order to check if the bucket was created, we check its arn
    # we can only check it if it was created, so we need the command to apply
    assert {
      condition = aws_s3_bucket.this.arn != ""
      error_message = "S3 bucket was not created"
    }

    assert {
        condition = aws_s3_bucket.this.id == var.bucket_name
        error_message = "S3 bucket was created but its name does not match the provided name"
    }
}

run "dynamodb_table_created" {
    # in order to check if the table was created, we check its arn
    # we can only check it if it was created, so we need the command to apply
    assert {
      condition = length(aws_dynamodb_table.this) == 1
      error_message = "A DynamoDB table was not created"
    }

    assert {
      condition = aws_dynamodb_table.this[0].name == var.dynamodb_table_name
      error_message = "A DynamoDB table was created but its name does not match"
    }
}