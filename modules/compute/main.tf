# ===========================================================
# PRE-STEP (Manual)
# ===========================================================
# Run before terraform apply (once):
# ssh-keygen -t rsa -b 4096 -f ~/.ssh/hotelapp-ec2-key-tf
# sudo chmod 400 ~/.ssh/hotelapp-ec2-key-tf

# ===========================================================
# KEY PAIR
# ===========================================================
resource "aws_key_pair" "hotelapp_ec2_key_tf" {
  key_name   = "hotelapp-ec2-key-tf"
  public_key = file(var.ssh_public_key_path)
}

# ===========================================================
# LAUNCH TEMPLATE
# ===========================================================
resource "aws_launch_template" "hotelapp_lt_tf" {
  name_prefix   = "hotelapp-lt-tf"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.hotelapp_ec2_key_tf.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  metadata_options {
    http_tokens = "required"
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.asg_sg_id]
  }

  user_data = base64encode(file(var.user_data_file))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "hotelapp-asg-ec2-tf"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ===========================================================
# AUTOSCALING GROUP
# ===========================================================
resource "aws_autoscaling_group" "hotelapp_asg_tf" {
  name                      = "hotelapp-asg-tf"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 30
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.hotelapp_lt_tf.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "hotelapp-asg-ec2-tf"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ===========================================================
# OPTIONAL – Wait for ASG to Initialize
# ===========================================================
resource "time_sleep" "wait_for_asg" {
  depends_on      = [aws_autoscaling_group.hotelapp_asg_tf]
  create_duration = "90s"
}

# ===========================================================
# DATA SOURCE – ASG INSTANCE DISCOVERY
# ===========================================================
data "aws_instances" "asg_instances" {
  depends_on = [time_sleep.wait_for_asg]

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.hotelapp_asg_tf.name]
  }
}

locals {
  asg_instance_ids         = data.aws_instances.asg_instances.ids
  asg_instance_private_ips = data.aws_instances.asg_instances.private_ips
  asg_instance_public_ips  = data.aws_instances.asg_instances.public_ips
}

# ===========================================================
# SCALING POLICY
# ===========================================================
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.hotelapp_asg_tf.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}


