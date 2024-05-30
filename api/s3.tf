resource "aws_s3_bucket" "public_read_bucket" {
  bucket = "${var.prefix}-public-read-bucket"

  tags = {
    Project = "${var.prefix}"
  }
}

resource "aws_s3_bucket_public_access_block" "example_public_access_block" {
  bucket = aws_s3_bucket.public_read_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  depends_on = [aws_s3_bucket_public_access_block.example_public_access_block]
  bucket = aws_s3_bucket.public_read_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.public_read_bucket.bucket}/*",
        Principal = "*"
      }
    ]
  })
}
