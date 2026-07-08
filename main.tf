# main.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

module "networking" {
  source = "./modules/networking"

  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"
}

module "security" {
  source = "./modules/security"

  environment             = var.environment
  project_name            = var.project_name
  vpc_id                  = module.networking.vpc_id
  ssh_allowed_cidr_blocks = var.ssh_allowed_cidr_blocks
  allow_ssh_from_anywhere = var.allow_ssh_from_anywhere
  enable_web_ingress      = var.enable_web_ingress
}

module "compute" {
  source = "./modules/compute"

  environment       = var.environment
  project_name      = var.project_name
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.security.swarm_sg_id
  key_name          = var.key_name
  instance_type     = var.instance_type
  aws_region        = var.aws_region
  worker_count      = var.worker_count
}