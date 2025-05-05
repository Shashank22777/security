variable "unique_id" {
  description = "Unique identifier for resource naming"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "vnet_space" {
  description = "Virtual Network address space"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name for AKS"
  type        = string
}

variable "subnet_space" {
  description = "Subnet address space for AKS"
  type        = string
}

variable "aks_loadbalancer_ip" {
  description = "Public IP of AKS Load Balancer"
  type        = string
}

variable "fwpip" {
  description = "value"
  type = string
}


variable "application_rules" {
  type = list(object({
    name             = string
    source_addresses = list(string)
    protocols = list(object({
      port = number
      type = string
    }))
    target_fqdns = list(string)
  }))
}

variable "network_rules" {
  type = list(object({
    name                  = string
    source_addresses      = list(string)
    destination_addresses = list(string)
    destination_ports     = list(string)
    protocols             = list(string)
  }))
}

variable "nat_rules" {
  type = list(object({
    name                  = string
    source_addresses      = list(string)
    destination_addresses = list(string)
    destination_ports     = list(string)
    protocols             = list(string)
    translated_address    = string
    translated_port       = string
  }))
}