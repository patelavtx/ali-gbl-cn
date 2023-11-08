# Aviatrix Controller in Azure China NSG Management for Aviatrix Gateways Deployed in Alibaba Cloud

## Description

### Note:

This Terraform module automates the creation of NSG rules in the NSG attached to an Aviatrix Controller deployed in Azure China to allow communication with Aviatrix Gateways deployed in Alibaba Cloud in China regions. This is needed because Avitrix Controllers deployed in Azure China doesn't support Security Group Management; this makes deploying Aviatrix Gateways through automation using Terraform challenging, requiring users to manually add the public IP addresses of the gateways to the NSG attached to the controller before the gateway creation times out.

This Terraform module:

- Is limited to deployments in Alibaba Cloud in China regions.
- Doesn't create any Aviatrix resources. It is intended to be used in conjunction with [mc-transit](https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest), [mc-spoke](https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest) modules, Aviatrix Transit or Spoke gateway resources.
- Supports Azure controller deployment with only 6.7 and above versions.
- Adds one or two security rules to the existing NSG associated with an Azure Controller deployed in China, depending on whether the Gateways are deployed in HA or not


## Prerequisites

1. [Terraform v0.13+](https://www.terraform.io/downloads.html) - execute terraform files


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.52 |
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | ~> 1.203.0 |


## Procedures for Running This Module

### 1. Authenticating to Azure

Set the environment in Azure CLI to Azure China:

```shell
az cloud set -n AzureChinaCloud
```

Login to the Azure CLI using:

```shell
az login --use-device-code
````
*Note: Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs#authenticating-to-azure-active-directory) for different methods of authentication to Azure, incase above command is not applicable.*

Pick the subscription you want and use it in the command below.

```shell
az account set --subscription <subscription_id>
```

Set environment variables ARM_ENDPOINT and ARM_ENVIRONMENT to use Azure China endpoints:

  ``` shell
  export ARM_ENDPOINT=https://management.chinacloudapi.cn
  export ARM_ENVIRONMENT=china
  ```

If executing this code from a CI/CD pipeline, the following environment variables are required. The service principal used to authenticate the CI/CD tool into Azure must either have subscription owner role or a custom role that has `Microsoft.Authorization/roleAssignments/write` to be able to succesfully create the role assignments required

``` shell
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

### 2. Authenticating to AliCloud

Set environment variables ALICLOUD_ACCESS_KEY, ALICLOUD_SECRET_KEY and ALICLOUD_REGION:

  ``` shell
  export ALICLOUD_ACCESS_KEY="anaccesskey"
  export ALICLOUD_SECRET_KEY="asecretkey"
  export ALICLOUD_REGION="cn-beijing"
  ```


### 3. Applying Terraform configuration

> **IMPORTANT**: Argument `gw_name` in this module **MUST** exactly match argument `gw_name` in the Aviatrix module or Aviatrix resource used to create the gateways; otherwise NSG rule creation will fail. Both modules must run in parallel at the same time; **DO NOT** reference outputs from Aviatrix module or attributes from Aviatrix resource used to create the gateways in this module, otherwise NSG rule creation will fail. HA cannot be added afterwards; if HA is required it must be configured from the beginning. If flag ha_enabled was set to false during intial deployment and HA is required afterwads, terraform destroy must be run first, change the flag to true and redeploy, otherwise the HAGW won't complete provisioning before the controllers times out and rollsback the HAGW deployment, this is because Aviatrix doesn't support pre-assigning EIPs to Gateways deployed in AliCloud and this module uses a sleep timer resource to obtain the value of the IP addresses to add to the Azure Controller NSG

```hcl
provider "alicloud" {
  alias = "china"
  // additional configuration here
}

provider "azurerm" {
  alias = "controller"
  // additional configuration here
}

module "ali-gateway-nsg" {
  providers = {
    alicloud.china     = alicloud.china
    azurerm.controller = azurerm.controller
  }
  source                             = "github.com/jocortems/aviatrix_alicloud_china_gateway_azure_controller_nsg"
  gateway_name                       = "jcortes-gw"                   # Required. Must exactly match argument gw_name in the module below
  controller_nsg_name                = "controllerha-nsg"             # Required. Name of the NSG associated with the Controller
  controller_nsg_resource_group_name = "jcortes-avtx-controller"      # Required. Name of the resource group where the NSG associated with the controller is deployed
  controller_nsg_rule_priority       = 301                            # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Controller
  ha_enabled                         = true/false                     # Optiona. Defaults to true. Must match HA GW deployment in the module below
}

module "mc-transit-ali" {
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "2.3.2"
  name                = "jcortes-avx-transit-vpc"
  account             = "alicloud-account"
  cloud               = "Ali"
  region              = "acs-cn-beijing (Beijing)"
  az_support          = false
  enable_segmentation = true
  gw_name             = "jcortes-gw"
  insane_mode         = false
  cidr                = "172.18.0.0/23"
  ha_gw               = true
}
```

### Execute

```shell
terraform init
terraform apply --var-file=<terraform.tfvars>
````

## **Disclaimer**:

The material embodied in this software/code is provided to you "as-is" and without warranty of any kind, express, implied or otherwise, including without limitation, any warranty of fitness for a particular purpose. In no event shall the Aviatrix Inc. be liable to you or anyone else for any direct, special, incidental, indirect or consequential damages of any kind, or any damages whatsoever, including without limitation, loss of profit, loss of use, savings or revenue, or the claims of third parties, whether or not Aviatrix Inc. has been advised of the possibility of such loss, however caused and on any theory of liability, arising out of or in connection with the possession, use or performance of this software/code.