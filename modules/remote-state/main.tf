provider "aws" {
  region = var.region
}

# --- S3 Bucket for Terraform State ---
resource "aws_s3_bucket" "terraform_state" {
  bucket              = var.bucket_name
  object_lock_enabled = var.enable_object_lock
  force_destroy       = var.force_destroy

  tags = merge({
    Name        = var.bucket_name
    Environment = var.environment
  }, var.tags)
}

# --- Enable versioning ---
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- Enable server-side encryption ---
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_algorithm
      kms_master_key_id = var.kms_key_id
    }
  }
}

# --- Enable Object Lock (optional) ---
resource "aws_s3_bucket_object_lock_configuration" "lock" {
  count  = var.enable_object_lock ? 1 : 0
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    default_retention {
      mode = var.object_lock_mode
      days = var.object_lock_days
    }
  }
}
