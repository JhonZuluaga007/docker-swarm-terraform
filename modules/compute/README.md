Creates the manager and worker EC2 instances and everything they need to actually form a swarm on boot: separate IAM roles for the manager and workers (least-privilege access to a single SSM Parameter Store path), IMDSv2 enforcement, encrypted root volumes, and a `templatefile`-rendered `user_data` script that branches on instance role.

The manager runs `docker swarm init`, then publishes its IP and the worker join token to SSM. Each worker polls those parameters until they exist, then joins. See `templates/user_data.sh.tpl` for the actual bootstrap logic.

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
| [aws_iam_instance_profile.manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.manager_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.worker_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_kms_key.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_ssm_parameter.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Optional AMI ID override. Defaults to the latest Amazon Linux 2 AMI resolved via SSM Parameter Store. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region used by the AWS CLI inside the instances to exchange the swarm join information via SSM Parameter Store | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type. Defaults to a Nitro-based instance (EBS-optimized by default, supports IMDSv2 natively). | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of the SSH key pair | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | ID of the security group | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet where instances will be created | `string` | n/a | yes |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of Docker Swarm worker nodes to create | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_manager_private_ip"></a> [manager\_private\_ip](#output\_manager\_private\_ip) | Private IP of the manager node |
| <a name="output_manager_public_ip"></a> [manager\_public\_ip](#output\_manager\_public\_ip) | Public IP of the manager node |
| <a name="output_worker_private_ips"></a> [worker\_private\_ips](#output\_worker\_private\_ips) | Private IPs of worker nodes |
| <a name="output_worker_public_ips"></a> [worker\_public\_ips](#output\_worker\_public\_ips) | Public IPs of worker nodes |
<!-- END_TF_DOCS -->
