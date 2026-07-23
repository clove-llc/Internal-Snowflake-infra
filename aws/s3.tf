# Terraform state 用バケット(snowflake/ と aws/ の両方の state を置く)
resource "aws_s3_bucket" "tfstate" {
  bucket = "clove-terraform-state"

  lifecycle {
    prevent_destroy = true # state の入れ物なので誤 destroy を禁止
  }
}

# state 破損時に過去バージョンへ戻せるようにする
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
