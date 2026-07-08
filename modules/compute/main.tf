# modules/compute/main.tf
data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}

locals {
  ami_id     = coalesce(var.ami_id, data.aws_ssm_parameter.amazon_linux_2.value)
  ssm_prefix = "/${var.project_name}/${var.environment}/swarm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# IAM role for the manager: only allowed to publish the join info it owns
resource "aws_iam_role" "manager" {
  name_prefix        = "${var.project_name}-swarm-mgr-"
  assume_role_policy = local.assume_role_policy

  tags = {
    Name        = "${var.project_name}-swarm-manager-role-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy" "manager_ssm" {
  name = "swarm-manager-ssm"
  role = aws_iam_role.manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:PutParameter"]
        Resource = "arn:aws:ssm:*:*:parameter${local.ssm_prefix}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Encrypt", "kms:GenerateDataKey"]
        Resource = data.aws_kms_key.ssm.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "manager" {
  name_prefix = "${var.project_name}-swarm-mgr-"
  role        = aws_iam_role.manager.name
}

# IAM role for the workers: read-only access to the join info published by the manager
resource "aws_iam_role" "worker" {
  name_prefix        = "${var.project_name}-swarm-wkr-"
  assume_role_policy = local.assume_role_policy

  tags = {
    Name        = "${var.project_name}-swarm-worker-role-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy" "worker_ssm" {
  name = "swarm-worker-ssm"
  role = aws_iam_role.worker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = "arn:aws:ssm:*:*:parameter${local.ssm_prefix}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = data.aws_kms_key.ssm.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "worker" {
  name_prefix = "${var.project_name}-swarm-wkr-"
  role        = aws_iam_role.worker.name
}

resource "aws_instance" "manager" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.manager.name
  ebs_optimized          = true
  monitoring             = true

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    role       = "manager"
    aws_region = var.aws_region
    ssm_prefix = local.ssm_prefix
  })

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-manager-${var.environment}"
    Environment = var.environment
    Role        = "manager"
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "workers" {
  count                  = var.worker_count
  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.worker.name
  ebs_optimized          = true
  monitoring             = true
  depends_on             = [aws_instance.manager]

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    role       = "worker"
    aws_region = var.aws_region
    ssm_prefix = local.ssm_prefix
  })

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-worker-${count.index + 1}-${var.environment}"
    Environment = var.environment
    Role        = "worker"
    ManagedBy   = "terraform"
  }
}
