resource "aws_s3_bucket" "tfstate" {
  bucket        = var.tfstate_bucket_name
  force_destroy = var.tfstate_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = var.tfstate_enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.tfstate.id

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

resource "aws_iam_role" "this" {
  name = var.tfbackend_access_role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          AWS = "arn:aws:iam::${var.aws_account_id}:role/${var.tfbackend_access_role_name}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "this" {
  name        = var.tfbackend_policy_name
  description = "Access to Terraform S3 state and DynamoDB lock table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.tfstate_bucket_name}/${var.tfstate_object_prefix}"
        ],
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.tfstate_bucket_name}/${var.tfstate_object_prefix}.tflock"
        ],
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.tfstate_bucket_name}"
        ],
        Condition = {
          StringEquals = {
            "s3:prefix" = "${var.tfstate_bucket_name}/${var.tfstate_object_prefix}"
          }
        }
      },
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.locks_table_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

# Only upload the rendered cloudformation template if a bucket name is provided
resource "aws_s3_object" "this" {
  count   = local.should_upload ? 1 : 0
  bucket  = var.s3_bucket_cloudformation_role
  key     = var.s3_bucket_cloudformation_role_key
  content = local.rendered_template
  acl     = "private"
  etag    = filemd5("${path.module}/template.yaml")
}
