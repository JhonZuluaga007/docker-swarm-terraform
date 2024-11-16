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
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}