output "alb_ingress_rules_formatted" {
  value = [for k, v in var.ingress_rules : "${k}: ${v.ip_protocol} ${v.from_port}-${v.to_port} from ${v.cidr_block}"]
}


output "alb_sg_id" {
  value = aws_security_group.hotelapp-sg-alb-tf.id
}


output "asg_sg_id" {
  value = aws_security_group.hotelapp-sg-asg-tf.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.iam_instance_profile_tf.name
}
