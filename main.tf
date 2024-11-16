# main.tf
provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"
  
  environment   = var.environment
  project_name  = var.project_name
  vpc_cidr      = "10.0.0.0/16"
}

module "security" {
  source = "./modules/security"
  
  environment  = var.environment
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
}

module "compute" {
  source = "./modules/compute"
  
  environment        = var.environment
  project_name       = var.project_name
  subnet_id          = module.networking.public_subnet_id
  security_group_id  = module.security.swarm_sg_id
  key_name           = var.key_name
  instance_type      = var.instance_type
}