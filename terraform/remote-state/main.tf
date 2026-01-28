resource "aws_s3_bucket" "terraform_state" {
  bucket = "nasus-tfstate"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "${aws_s3_bucket.terraform_state.bucket}-lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = 7
      newer_noncurrent_versions = 10
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}
