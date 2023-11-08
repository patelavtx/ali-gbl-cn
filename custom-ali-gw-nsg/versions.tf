terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.52.0"
      configuration_aliases = [azurerm.controller]
    }
    alicloud = {
      source = "aliyun/alicloud"
      version = ">= 1.200.0"
      configuration_aliases = [alicloud.china]
    }
}
}