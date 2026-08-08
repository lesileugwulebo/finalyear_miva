variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "gateway_subnet_id" {
  type = string
}

variable "azure_vpn_asn" {
  type = number
}

variable "common_tags" {
  type = map(string)
}
