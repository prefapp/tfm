data "aws_s3_bucket" "this" {
  count  = var.create_bucket ? 0 : 1
  bucket = var.bucket
  region = var.region
}