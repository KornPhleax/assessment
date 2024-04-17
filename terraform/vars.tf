
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
}

variable "zone" {
    type = string
}

variable "region" {
  type = string
}

variable "private_key_file" {
  type = string
  sensitive   = true
}

variable "public_key_file" {
  type = string
  sensitive   = true
}

variable "vm_image" {
  type     = list(string)
  nullable = false
}

variable "vm_flavor" {
  type     = list(string)
  nullable = false
}