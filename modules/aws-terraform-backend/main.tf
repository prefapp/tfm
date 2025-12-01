resource "aws_s3_bucket" "this" {
  bucket        = var.tfstate_bucket_name
  force_destroy = var.tfstate_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.tfstate_enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Only create DynamoDB table if name is provided
resource "aws_dynamodb_table" "this" {
  count = var.locks_table_name == null || var.locks_table_name == "" ? 0 : 1

  name         = var.locks_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}

#
# Upload the rendered CloudFormation template to S3
#
resource "aws_s3_object" "cloudformation_template" {
  count   = local.should_upload ? 1 : 0
  bucket  = var.cloudformation_s3_bucket
  key     = "${var.cloudformation_s3_key}/${var.aws_client_account_id}.yaml"
  content = local.cloudformation_template_yaml
  acl     = "private"

  tags = var.tags
}
