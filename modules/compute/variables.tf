# modules/compute/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where instances will be created"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type. Defaults to a Nitro-based instance (EBS-optimized by default, supports IMDSv2 natively)."
  type        = string
  default     = "t3.micro"
}

variable "aws_region" {
  description = "AWS region used by the AWS CLI inside the instances to exchange the swarm join information via SSM Parameter Store"
  type        = string
}

variable "worker_count" {
  description = "Number of Docker Swarm worker nodes to create"
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count >= 1
    error_message = "worker_count must be at least 1."
  }
}

variable "ami_id" {
  description = "Optional AMI ID override. Defaults to the latest Amazon Linux 2 AMI resolved via SSM Parameter Store."
  type        = string
  default     = null
}