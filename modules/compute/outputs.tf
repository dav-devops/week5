output "asg_instance_ids" {
  description = "Instance IDs created by the ASG"
  value       = local.asg_instance_ids
}

output "asg_instance_private_ips" {
  description = "Private IPs of EC2 instances in the ASG"
  value       = local.asg_instance_private_ips
}

output "asg_instance_public_ips" {
  description = "Public IPs of EC2 instances in the ASG"
  value       = local.asg_instance_public_ips
}


