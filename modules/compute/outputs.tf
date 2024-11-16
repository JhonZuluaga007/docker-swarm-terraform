# modules/compute/outputs.tf
output "manager_public_ip" {
  description = "Public IP of the manager node"
  value       = aws_instance.manager.public_ip
}

output "manager_private_ip" {
  description = "Private IP of the manager node"
  value       = aws_instance.manager.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of worker nodes"
  value       = aws_instance.workers[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes"
  value       = aws_instance.workers[*].private_ip
}