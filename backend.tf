# backend.tf
#
# Partial backend configuration — bucket, key, region, and dynamodb_table are
# supplied at `terraform init` time via -backend-config, so the same root
# module can point at a different state file per environment. See the
# environments/*.backend.hcl files and run, e.g.:
#
#   terraform init -backend-config=environments/dev.backend.hcl
#
# The S3 bucket and DynamoDB table referenced here must already exist —
# create them once with the bootstrap/ stack (see bootstrap/main.tf).
#
# Once this block is present, `terraform init` always requires backend
# configuration (either via -backend-config or interactively) — it no
# longer falls back to local state on its own. To develop against local
# state only, run `terraform init -backend=false` instead (this is what
# CI uses for fmt/validate, since it never needs real state).
terraform {
  backend "s3" {}
}
