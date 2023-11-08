terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
      version = "3.1.0"
      #configuration_aliases = [aviatrix.china, aviatrix.global]
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.15.0"
    }
    alicloud = {
      source = "aliyun/alicloud"
      version = "~> 1.203.0"
      configuration_aliases = [alicloud.china, alicloud.global]
    }
  }
}
