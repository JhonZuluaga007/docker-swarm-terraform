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
    cidr_blocks = ["0.0.0.0/0"]
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

  # HTTP/HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
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
  }
}