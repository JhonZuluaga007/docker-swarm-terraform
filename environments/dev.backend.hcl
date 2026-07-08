# environments/dev.backend.hcl
#
# Usage: terraform init -backend-config=environments/dev.backend.hcl
#
# Replace `bucket` with the name you chose when running the bootstrap/
# stack (see bootstrap/main.tf). `dynamodb_table` must match
# bootstrap's `lock_table_name` (default: docker-swarm-terraform-locks).

bucket         = "REPLACE_WITH_YOUR_STATE_BUCKET_NAME"
key            = "docker-swarm-terraform/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "docker-swarm-terraform-locks"
encrypt        = true
