# -----ALB-----

resource "aws_lb" "hotelapp-alb-tf" {
  name               = "hotelapp-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnets


  tags = {
    Name = "hotelapp-alb-tf"
  }
}

resource "aws_lb_listener" "hotelapp-alb-listener-tf" {
  load_balancer_arn = aws_lb.hotelapp-alb-tf.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hotelapp-tg-tf.arn
  }
}

# -----TG-----

resource "aws_lb_target_group" "hotelapp-tg-tf" {
  name     = "hotelapp-tg-tf"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}



