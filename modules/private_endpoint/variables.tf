variable "resource_group_name" {
  description = "name of the resource group to put the private endpoint in."
  type        = string
}

variable "subnet_id" {
  description = "The subnet id of the subnet to put the private endpoint in."
  type        = string
}

variable "resource_id" {
  description = "resource id of the resource of which to create a private endpoint for, ommit if looking for any 'resource_type'"
  type        = string
}

variable "sub_resource" {
  description = "the sub resource type to create a private endpoint for, ommit if looking for any 'resource_type'"
  type        = string
}

variable "nic_name" {
  description = "network interface name "
  type        = string
}

variable "location" {
  description = "location name"
  type        = string
}

variable "private_endpoint_name" {
  description = "Private endpoint name"
  type        = string
}

variable "private_dns_zone" {
  description = "Private DNS zone name"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID"
  type        = string
}
