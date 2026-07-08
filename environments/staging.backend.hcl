# environments/staging.backend.hcl
#
# Usage: terraform init -backend-config=environments/staging.backend.hcl

bucket         = "REPLACE_WITH_YOUR_STATE_BUCKET_NAME"
key            = "docker-swarm-terraform/staging/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "docker-swarm-terraform-locks"
encrypt        = true
