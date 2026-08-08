variable "name_prefix" {
  type = string
}

variable "aws_transit_gateway_id" {
  type = string
}

variable "tgw_route_table_id" {
  type = string
}

variable "azure_vpn_public_ip_1" {
  type = string
}

variable "azure_vpn_public_ip_2" {
  type = string
}

variable "azure_vpn_asn" {
  type = number
}

variable "aws_tgw_asn" {
  type = number
}

variable "vpn_shared_key_1" {
  type      = string
  sensitive = true
}

variable "vpn_shared_key_2" {
  type      = string
  sensitive = true
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

variable "common_tags" {
  type = map(string)
}
