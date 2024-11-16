# modules/security/outputs.tf
output "swarm_sg_id" {
  description = "ID of the created security group"
  value       = aws_security_group.swarm.id
}