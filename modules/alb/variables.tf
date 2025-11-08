variable "vpc_id" {
  description = "The VPC ID where ALB and Target Group are deployed"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security Group ID for ALB"
  type        = string
}
