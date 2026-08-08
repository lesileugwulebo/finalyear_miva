variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "azure_resource_group_name" {
  type = string
}

variable "azure_location" {
  type = string
}

variable "azure_vpn_gateway_id" {
  type = string
}

variable "aws_vpn_connection_1_id" {
  type = string
}

variable "enable_guardduty" {
  type = bool
}

variable "enable_defender" {
  type = bool
}

variable "common_tags" {
  type = map(string)
}
