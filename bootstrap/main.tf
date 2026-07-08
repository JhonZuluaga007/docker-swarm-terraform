# bootstrap/main.tf
#
# One-time stack that creates the S3 bucket and DynamoDB table used as the
# remote backend for the root module and any other environment. This stack
# intentionally keeps its own local state — it can't store its state in the
# backend it is responsible for creating.
#
# Usage:
#   cd bootstrap
#   terraform init
#   terraform apply -var="state_bucket_name=<your-globally-unique-bucket-name>"
#
# Then update environments/*.backend.hcl with the resulting bucket/table names.

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV2_AWS_62:Event notifications (e.g. SNS/EventBridge on state changes) would need a real subscriber to be useful and add infra disproportionate to this portfolio demo. Documented as a Roadmap item alongside the other observability follow-ups.
  #checkov:skip=CKV_AWS_144:Cross-region replication is a production-DR feature; a single-region bucket is an accepted trade-off for a demo state backend. Documented in the README Roadmap.
  #checkov:skip=CKV_AWS_18:Access logging would require a second bucket purely to hold logs for a low-traffic state bucket. Accepted trade-off for this demo; CloudTrail data events are the recommended production alternative.
  bucket = var.state_bucket_name

  # Protect the state bucket from being destroyed by an accidental
  # `terraform destroy` run against this stack.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = var.state_bucket_name
    ManagedBy = "terraform"
    Purpose   = "terraform-remote-state"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    # Keep a 90-day recovery window for previous state versions, then clean
    # them up instead of retaining every version forever.
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.terraform_state.arn,
        "${aws_s3_bucket.terraform_state.arn}/*"
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })
}

resource "aws_dynamodb_table" "terraform_lock" {
  #checkov:skip=CKV_AWS_119:This table only stores lock metadata (LockID), not the Terraform state content itself (that's in S3, already KMS-encrypted). A dedicated customer-managed CMK for a lock table is disproportionate for this demo; the AWS-owned encryption key is sufficient here.
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name      = var.lock_table_name
    ManagedBy = "terraform"
    Purpose   = "terraform-state-locking"
  }
}
