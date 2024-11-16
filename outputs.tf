# outputs.tf
output "manager_public_ip" {
  description = "Public IP of the Swarm manager node"
  value       = module.compute.manager_public_ip
}

output "worker_public_ips" {
  description = "Public IPs of the Swarm worker nodes"
  value       = module.compute.worker_public_ips
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.networking.vpc_id
}

output "security_group_id" {
  description = "ID of the created security group"
  value       = module.security.swarm_sg_id
}