# Configure Aviatrix provider
provider "aviatrix" {
  alias = "china"
  controller_ip           = var.controller_ip
  username                = "admin"
  password                = var.ctrl_password
}

provider "aviatrix" {
  alias = "global"
  controller_ip           = var.gbl_controller_ip
  username                = "admin"
  password                = var.gbl_ctrl_password
}

provider "alicloud" {
  alias = "china"
  region = "cn-beijing"
}

provider "alicloud" {
  alias = "global"
  #region = var.ali_global_region
  region = "eu-central-1"
}

provider azurerm {
    alias = "controller"
    skip_provider_registration = "true"
    #  Error: Error ensuring Resource Providers are registered.;  > API version 2019-XX-XX was not found for Microsoft.Foo
    features {}    
}



