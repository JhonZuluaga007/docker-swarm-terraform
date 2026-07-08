# modules/security/main.tf
resource "aws_security_group" "swarm" {
  name_prefix = "${var.project_name}-swarm-${var.environment}"
  description = "Security group for Docker Swarm cluster"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr_blocks
    description = "SSH access"
  }

  # Docker Swarm ports
  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    self        = true
    description = "Docker Swarm cluster management"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
    description = "Docker Swarm node communication TCP"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
    description = "Docker Swarm node communication UDP"
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
    description = "Docker Swarm overlay network"
  }

  # HTTP/HTTPS — only opened when enable_web_ingress = true
  dynamic "ingress" {
    for_each = var.enable_web_ingress ? [80, 443] : []
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Web access (port ${ingress.value})"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-swarm-sg-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.allow_ssh_from_anywhere || !contains(var.ssh_allowed_cidr_blocks, "0.0.0.0/0")
      error_message = "ssh_allowed_cidr_blocks must not include 0.0.0.0/0 unless allow_ssh_from_anywhere is explicitly set to true."
    }
  }
}