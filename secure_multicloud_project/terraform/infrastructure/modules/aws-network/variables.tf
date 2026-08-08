variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "administrator_cidr" {
  type = string
}

variable "azure_vnet_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}
