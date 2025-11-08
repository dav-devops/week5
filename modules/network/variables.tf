variable "cidr_block_route_table_public" {
  description = "CIDR block for route table public route (usually 0.0.0.0/0)"
  type        = string
  default     = "0.0.0.0/0"

}


variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
  default     = "hotelapp-vpc-tf"
}

variable "cidr_block_vpc" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "map_public_ip" {
  description = "Whether to map public IPs on launch"
  type        = bool
  default     = true
}
