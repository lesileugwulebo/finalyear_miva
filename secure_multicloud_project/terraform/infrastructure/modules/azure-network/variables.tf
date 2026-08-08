variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "aws_vpc_cidr" {
  type = string
}

variable "administrator_cidr" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
