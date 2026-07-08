Standalone stack that creates the S3 bucket and DynamoDB table used as the remote backend for the root module. It's not a module the root config calls — it's a separate root module you run once, by hand, before the first `terraform init -backend-config=...` anywhere else in this repo.

It keeps its own local state deliberately: a backend can't bootstrap itself.

```
cd bootstrap
terraform init
terraform apply -var="state_bucket_name=<a-globally-unique-name>"
```

Take the `state_bucket_name` and `lock_table_name` outputs and drop them into `environments/*.backend.hcl` back at the repo root.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for the Terraform state bucket and lock table | `string` | `"us-east-1"` | no |
| <a name="input_lock_table_name"></a> [lock\_table\_name](#input\_lock\_table\_name) | DynamoDB table name used for Terraform state locking | `string` | `"docker-swarm-terraform-locks"` | no |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | Globally-unique S3 bucket name to store Terraform remote state. Must be set explicitly (S3 bucket names are unique across all of AWS). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lock_table_name"></a> [lock\_table\_name](#output\_lock\_table\_name) | Name of the DynamoDB table created for Terraform state locking |
| <a name="output_state_bucket_name"></a> [state\_bucket\_name](#output\_state\_bucket\_name) | Name of the S3 bucket created for Terraform remote state |
<!-- END_TF_DOCS -->
