variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "aws_instance_type" {
  type = string
}

variable "public_subnet_a_id" {
  type = string
}

variable "public_subnet_b_id" {
  type = string
}

variable "web_subnet_id" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "db_subnet_id" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "web_security_group_id" {
  type = string
}

variable "application_security_group_id" {
  type = string
}

variable "database_security_group_id" {
  type = string
}

variable "azure_resource_group_name" {
  type = string
}

variable "azure_location" {
  type = string
}

variable "azure_service_subnet_id" {
  type = string
}

variable "azure_vm_size" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "common_tags" {
  type = map(string)
}
