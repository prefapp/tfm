# ... other configuration ...

resource "aws_s3_bucket" "east" {
  bucket = "tf-test-bucket-east-12345"
}

resource "aws_s3_bucket_versioning" "east" {
  bucket = aws_s3_bucket.east.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "west" {
  provider = aws.west
  bucket   = "tf-test-bucket-west-12345"
}

resource "aws_s3_bucket_versioning" "west" {
  provider = aws.west

  bucket = aws_s3_bucket.west.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "east_to_west" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.east]

  role   = aws_iam_role.east_replication.arn
  bucket = aws_s3_bucket.east.id

  rule {
    id = "foobar"

    filter {
      prefix = "foo"
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.west.arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "west_to_east" {
  provider = aws.west
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.west]

  role   = aws_iam_role.west_replication.arn
  bucket = aws_s3_bucket.west.id

  rule {
    id = "foobar"

    filter {
      prefix = "foo"
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.east.arn
      storage_class = "STANDARD"
    }
  }
}