variable "azure_subscription_id" {
  description = "Azure subscription identifier used to host Terraform remote state."
  type        = string
  sensitive   = true
}

variable "azure_location" {
  description = "Azure region for remote state resources."
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Project identifier."
  type        = string
  default     = "secure-multicloud"
}

variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "lab"
}
