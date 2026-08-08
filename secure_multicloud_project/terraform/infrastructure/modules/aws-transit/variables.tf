variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "transit_subnet_ids" {
  type = list(string)
}

variable "tgw_asn" {
  type = number
}

variable "azure_vnet_cidr" {
  type = string
}

variable "application_route_table_id" {
  type = string
}

variable "management_route_table_id" {
  type = string
}
