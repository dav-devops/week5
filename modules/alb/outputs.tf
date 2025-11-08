output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.hotelapp-alb-tf.dns_name
}

output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.hotelapp-tg-tf.arn
}


