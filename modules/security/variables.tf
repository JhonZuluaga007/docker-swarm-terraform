# modules/security/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ssh_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach SSH (port 22). No public default — must be set explicitly."
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