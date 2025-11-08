variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "hotelapp-vpc-tf"
}

variable "cidr_block_vpc" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

}

variable "map_public_ip" {
  description = "Whether to assign public IPs in subnets"
  type        = bool
  default     = true
}

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

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}


variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}
