# modules/compute/main.tf
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "manager" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  subnet_id             = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data             = file("${path.module}/templates/user_data.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name        = "${var.project_name}-manager-${var.environment}"
    Environment = var.environment
    Role        = "manager"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "workers" {
  count                  = 2
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  subnet_id             = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data             = file("${path.module}/templates/user_data.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name        = "${var.project_name}-worker-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Role        = "worker"
    ManagedBy   = "terraform"
  }
}