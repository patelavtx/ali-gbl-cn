# ali-gbl-cn

- Used to test Ali Global to China vpc peered with bgpoipsec


## Architecture

**NOTE** 

- 1st two exports needed for NSG module

#########################################################

export ARM_ENDPOINT=https://management.chinacloudapi.cn
export ARM_ENVIRONMENT=china


export ALICLOUD_ACCESS_KEY="anaccesskey"
export ALICLOUD_SECRET_KEY="asecretkey"
export ALICLOUD_REGION="cn-beijing"

##########################################################



## Validated environment
```
Terraform v1.3.6
on linux_amd64 (WSL) and TFC workspace
+ provider aviatrixsystems/aviatrix v3.0.1

```

## providers.tf

```
provider "aviatrix" {
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
