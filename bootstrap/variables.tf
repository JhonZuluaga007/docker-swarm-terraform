# bootstrap/variables.tf
variable "aws_region" {
  description = "AWS region for the Terraform state bucket and lock table"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally-unique S3 bucket name to store Terraform remote state. Must be set explicitly (S3 bucket names are unique across all of AWS)."
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "docker-swarm-terraform-locks"
}
