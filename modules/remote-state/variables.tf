variable "bucket_name" {
  description = "Name of the S3 bucket for remote Terraform state"
  type        = string
  default     = "hotelapp-terraform-remote-state"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Environment label (e.g., dev, prod)"
  type        = string
  default     = "global"
}

variable "force_destroy" {
  description = "Allow Terraform to delete bucket even if not empty"
  type        = bool
  default     = false
}

variable "enable_object_lock" {
  description = "Enable S3 Object Lock for state file safety"
  type        = bool
  default     = true
}

variable "object_lock_mode" {
  description = "Object lock mode (GOVERNANCE or COMPLIANCE)"
  type        = string
  default     = "GOVERNANCE"
}

variable "object_lock_days" {
  description = "Default retention period in days for object lock"
  type        = number
  default     = 1
}

variable "encryption_algorithm" {
  description = "SSE algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "Optional KMS key ID for encryption (used if aws:kms)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for the S3 bucket"
  type        = map(string)
  default     = {}
}

# --- Conditional force_destroy logic ---
locals {
  force_destroy_flag = contains(["dev", "test", "sandbox"], var.environment)
}
