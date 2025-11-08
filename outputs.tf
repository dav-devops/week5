output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "asg_instance_private_ips" {
  description = "Private IPs of running EC2 instances created by ASG (from compute module)"
  value       = length(module.compute.asg_instance_private_ips) > 0 ? module.compute.asg_instance_private_ips : ["No running instances"]
}

output "asg_instance_public_ips" {
  description = "Public IPs of running EC2 instances created by ASG (from compute module)"
  value       = length(module.compute.asg_instance_public_ips) > 0 ? module.compute.asg_instance_public_ips : ["No running instances"]
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "availability_zones_used" {
  value = module.network.availability_zones_used
}