locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project      = var.project_name
    Environment  = var.environment
    ManagedBy    = "Terraform"
    Purpose      = "MIVA Master Project - Secure Multi-Cloud Reference Architecture"
    DataClass    = "Synthetic"
    Architecture = "AWS-Azure-Hub-Spoke-ZeroTrust"
  }
}
