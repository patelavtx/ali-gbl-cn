variable "gateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
}

variable "controller_nsg_name" {
    type = string
    description = "Name of the Network Security Group attached to the Aviatrix Controller Network Interface"  
}

variable "controller_nsg_resource_group_name" {
    type = string
    description = "Name of the Resource Group where the Network Security Group attached to the Aviatrix Controller Network Interface is deployed"  
}

variable "controller_nsg_rule_priority" {
    type = number
    description = "Priority of the rule that will be created in the existing Network Security Group attached to the Aviatrix Controller Network Interface. This number must be unique. Valid values are 100-4096"
    
    validation {
      condition = var.controller_nsg_rule_priority >= 100 && var.controller_nsg_rule_priority <= 4096
      error_message = "Priority must be a number between 100 and 4096"
    }
}

variable "ha_enabled" {
    type = bool
    description = "Whether HAGW will be deployed. Defaults to true"
    default = true
}
/*
locals {  
  gateway_address = [for eip in data.alicloud_eip_addresses.avx_gw.addresses : eip.ip_address]
  gatewayha_address = var.ha_enabled ? [for eip in data.alicloud_eip_addresses.avx_gwha[0].addresses : eip.ip_address] : null
}
*/