variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/hotelapp-ec2-key-tf.pub"
}

variable "user_data_file" {
  description = "Path to the userdata script file"
  type        = string
  default     = "~/internship/hotelapp-module/hotelapp-userdata.sh"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0a716d3f3b16d290c"
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to attach"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ASG"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target group ARN for ALB"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "asg_sg_id" {
  description = "Security group ID to attach to EC2 in ASG"
  type        = string
}


variable "asg_max_size" {
  description = "Maximum size for ASG"
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum size for ASG"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
  default     = 1
}
