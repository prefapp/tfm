# AWS S3 bucket to store Terraform state
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

# AWS S3 bucket versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# AWS S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# AWS S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# AWS DynamoDB table to store Terraform locks. 
# Only needed if terraform version is less than 1.11
module "dynamodb_conditional" {
  source       = "./dynamodb_conditional"
  enable       = var.terraform_version < "1.11"
  billing_mode = "PAY_PER_REQUEST"
  table_name   = var.dynamodb_table_name
  hash_key     = "LockID"
  tags         = var.tags
}
