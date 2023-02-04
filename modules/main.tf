resource "aws_s3_bucket" "a" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "policy" {
  bucket = aws_s3_bucket.a.id
  acl    = "private"
}

