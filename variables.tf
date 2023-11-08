
variable "controller_ip" {
  description = "Set controller ip"
  type        = string
}

variable "ctrl_password" {
    type = string
}

variable "account" {
    type = string
}

variable "cloud" {
  description = "Cloud type"
  type        = string

  validation {
    condition     = contains(["aws", "azure", "oci", "ali", "gcp"], lower(var.cloud))
    error_message = "Invalid cloud type. Choose AWS, Azure, GCP, ALI or OCI."
  }
}

variable "cidr" {
  description = "Set vpc cidr"
  type        = string
  default = "10.4.28.0/23"
}
/*
variable "instance_size" {
  description = "Set vpc cidr"
  type        = string
}
*/
variable "region" {
  description = "Set regions"
  type        = string
  default = "acs-cn-beijing (Beijing)"
}


variable "localasn" {
  description = "Set internal BGP ASN"
  type        = string
  default = "65004"
}

variable "bgp_advertise_cidrs" {
  description = "Define a list of CIDRs that should be advertised via BGP."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags to assign to the gateway."
  type        = map(string)
  default     = null
}



#  nsg_management module


variable "gateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
    default = "alitransit4-cn"
}


# nsg
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


# ali_gbl
variable "ali_global_region" {
    type = string
    description = "Alibaba Global Cloud Region Name"
    default = "acs-eu-central-1"
}


variable "gbl_controller_ip" {
  description = "Set controller ip"
  type        = string
}

variable "gbl_ctrl_password" {
    type = string
}

variable "gbl_account" {
    type = string
}

variable "gbl_region" {
    type = string
    description = "Alibaba Global Cloud Region Name"
}

variable "gbl_gw_name" {
    type = string
    description = "Alibaba Global gw"
    default = "alitransit40-ft"
}

variable "gbl_cidr" {
    type = string
    description = "Alibaba Global cidr"
    default = "10.40.28.0/23"
}

variable "gbl_localasn" {
    type = string
    description = "Alibaba Global asn"
    default = "65040"
}

