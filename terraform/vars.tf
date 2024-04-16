
# VARS:
variable "vm_count" {
  type        = number
  description = "the number of VMs to spin up (2-100)"

  validation {
    condition     = var.vm_count > 1 && var.vm_count < 101
    error_message = "invalid range, must be in 2-100"
  }
}

variable "project_id" {
  type = string
  default = "assessment-420408"
}

variable "zone" {
    type = string
    default = "us-east1-b"
}

variable "region" {
  type = string
  default = "us-east1"
}

variable "private_key_file" {
  type = string
  default = "./terraform"
  sensitive   = true
}

variable "public_key_file" {
  type = string
  default = "./terraform.pub"
  sensitive   = true
}

variable "vm_image" {
  type = string
  default = "debian-cloud/debian-11"
}