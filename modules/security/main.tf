# ----------------------------
# IAM Role for EC2
# ----------------------------
locals {
  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]
}

resource "aws_iam_role" "ec2_iam_role_tf" {
  name        = "hotelapp-ec2-role-tf"
  description = "IAM role for EC2 instances of HotelApp with ECR, SSM, and CloudWatch access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "hotelapp-ec2-role-tf"
    Environment = var.environment
    Project     = "HotelApp"
  }
}

resource "aws_iam_instance_profile" "iam_instance_profile_tf" {
  name = "hotelapp-instance-profile-tf"
  role = aws_iam_role.ec2_iam_role_tf.name
}

resource "aws_iam_role_policy_attachment" "ec2_iam_role_policies" {
  for_each   = toset(local.iam_policy_arns)
  role       = aws_iam_role.ec2_iam_role_tf.name
  policy_arn = each.key
}


# -----SG-----

# SG for ALB
resource "aws_security_group" "hotelapp-sg-alb-tf" {
  name        = "hotelapp-sg-alb-tf"
  description = "Allow HTTP/HTTPS/SSH traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "hotelapp-sg-alb-tf"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sg-alb-ingress" {
  for_each = var.ingress_rules

  security_group_id = aws_security_group.hotelapp-sg-alb-tf.id

  cidr_ipv4   = each.value.cidr_block
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  description = "Allow ${each.key} traffic from ${each.value.cidr_block}"
}


resource "aws_vpc_security_group_egress_rule" "hotelapp-sg-alb-egress-tf" {
  security_group_id = aws_security_group.hotelapp-sg-alb-tf.id

  ip_protocol = "-1"             # All protocols
  cidr_ipv4   = "0.0.0.0/0"
}


# SG for ASG
resource "aws_security_group" "hotelapp-sg-asg-tf" {
  name        = "hotelapp-sg-asg-tf"
  description = "Allow traffic from ALB SG only"
  vpc_id      = var.vpc_id
  tags = {
    Name = "hotelapp-sg-asg-tf"
  }
}

resource "aws_vpc_security_group_ingress_rule" "hotelapp-sg-asg-ingress-tf" {
  security_group_id            = aws_security_group.hotelapp-sg-asg-tf.id
  referenced_security_group_id = aws_security_group.hotelapp-sg-alb-tf.id
  ip_protocol                  = "-1"  # All protocols
}


resource "aws_vpc_security_group_egress_rule" "hotelapp-sg-asg-egress-tf" {
  security_group_id = aws_security_group.hotelapp-sg-asg-tf.id

  ip_protocol = "-1"             # All protocols
  cidr_ipv4   = "0.0.0.0/0"
}






