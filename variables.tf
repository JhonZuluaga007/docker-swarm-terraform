# variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name to be used for tagging"
  type        = string
  default     = "docker-swarm"
}

variable "key_name" {
  description = "Name of the AWS key pair to use for instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances. Defaults to a Nitro-based instance (EBS-optimized by default, supports IMDSv2 natively)."
  type        = string
  default     = "t3.micro"
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

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach SSH (port 22). No public default — must be set explicitly (e.g. [\"<your-ip>/32\"])."
  type        = list(string)
}

variable "allow_ssh_from_anywhere" {
  description = "Explicit opt-in required to allow ssh_allowed_cidr_blocks to include 0.0.0.0/0."
  type        = bool
  default     = false
}

variable "enable_web_ingress" {
  description = "Whether to open ports 80/443 on the security group, e.g. to expose a demo service through the swarm routing mesh."
  type        = bool
  default     = false
}