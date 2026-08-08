variable "project_name" {
  description = "Project identifier used in resource names."
  type        = string
  default     = "secure-multicloud"
}

variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "lab"

  validation {
    condition     = contains(["lab", "test", "prod"], var.environment)
    error_message = "Environment must be lab, test, or prod."
  }
}

variable "aws_region" {
  description = "AWS Region for primary resources."
  type        = string
  default     = "eu-west-1"
}

variable "azure_location" {
  description = "Azure Region for secondary resources."
  type        = string
  default     = "westeurope"
}

variable "azure_subscription_id" {
  description = "Azure subscription identifier."
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Microsoft Entra tenant identifier."
  type        = string
  sensitive   = true
}

variable "aws_vpc_cidr" {
  description = "AWS VPC address space."
  type        = string
  default     = "10.10.0.0/16"
}

variable "azure_vnet_cidr" {
  description = "Azure VNet address space."
  type        = string
  default     = "10.20.0.0/16"
}

variable "administrator_cidr" {
  description = "Approved public administrator IP in CIDR notation."
  type        = string
  sensitive   = true
}

variable "aws_instance_type" {
  description = "EC2 instance size for workload nodes."
  type        = string
  default     = "t3.micro"
}

variable "azure_vm_size" {
  description = "Azure VM size for supporting service node."
  type        = string
  default     = "Standard_B1s"
}

variable "database_name" {
  description = "Application database name."
  type        = string
  default     = "enterprise_lab"
}

variable "database_username" {
  description = "Database application account username."
  type        = string
  default     = "app_user"
}

variable "database_password" {
  description = "Database application password."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.database_password) >= 16
    error_message = "The database password must contain at least 16 characters."
  }
}

variable "vpn_shared_key_1" {
  description = "Pre-shared key for primary AWS-Azure IPsec tunnel."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.vpn_shared_key_1) >= 16
    error_message = "VPN pre-shared key 1 must contain at least 16 characters."
  }
}

variable "vpn_shared_key_2" {
  description = "Pre-shared key for secondary AWS-Azure IPsec tunnel."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.vpn_shared_key_2) >= 16
    error_message = "VPN pre-shared key 2 must contain at least 16 characters."
  }
}

variable "aws_tgw_asn" {
  description = "Private Autonomous System Number (ASN) for AWS Transit Gateway."
  type        = number
  default     = 64512
}

variable "azure_vpn_asn" {
  description = "Private Autonomous System Number (ASN) for Azure VPN Gateway."
  type        = number
  default     = 65515
}

variable "enable_guardduty" {
  description = "Enable Amazon GuardDuty threat detector."
  type        = bool
  default     = true
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for Cloud plans."
  type        = bool
  default     = true
}
