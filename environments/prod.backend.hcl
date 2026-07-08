# environments/prod.backend.hcl
#
# Usage: terraform init -backend-config=environments/prod.backend.hcl

bucket         = "REPLACE_WITH_YOUR_STATE_BUCKET_NAME"
key            = "docker-swarm-terraform/prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "docker-swarm-terraform-locks"
encrypt        = true
