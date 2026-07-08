Defines the single security group attached to every node in the cluster. SSH only opens to the CIDR blocks you pass in (no public default), the Docker Swarm control-plane and overlay-network ports are restricted to traffic from other members of the same security group, and ports 80/443 stay closed unless `enable_web_ingress` is turned on.

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
| [aws_security_group.swarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_ssh_from_anywhere"></a> [allow\_ssh\_from\_anywhere](#input\_allow\_ssh\_from\_anywhere) | Explicit opt-in required to allow ssh\_allowed\_cidr\_blocks to include 0.0.0.0/0. | `bool` | `false` | no |
| <a name="input_enable_web_ingress"></a> [enable\_web\_ingress](#input\_enable\_web\_ingress) | Whether to open ports 80/443 on the security group, e.g. to expose a demo service through the swarm routing mesh. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | n/a | yes |
| <a name="input_ssh_allowed_cidr_blocks"></a> [ssh\_allowed\_cidr\_blocks](#input\_ssh\_allowed\_cidr\_blocks) | CIDR blocks allowed to reach SSH (port 22). No public default — must be set explicitly. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_swarm_sg_id"></a> [swarm\_sg\_id](#output\_swarm\_sg\_id) | ID of the created security group |
<!-- END_TF_DOCS -->
