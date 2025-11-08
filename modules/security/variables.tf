variable "ingress_rules" {
  description = "A list of ports and protocols for ingress"
  type = map(object({
    cidr_block  = string
    from_port   = number
    to_port     = number
    ip_protocol = string
  }))
  default = {
    http = {
      cidr_block  = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
    },
    https = {
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
    },
    ssh = {
      cidr_block  = "0.0.0.0/0"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
    }
  }
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

