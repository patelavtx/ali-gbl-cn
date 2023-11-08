

# 1b. Create the gateways

module "ali-gateway-nsg" {
  providers = {
    alicloud.china     = alicloud.china
    azurerm.controller = azurerm.controller
  }
  #source                             = "github.com/jocortems/aviatrix_alicloud_china_gateway_azure_controller_nsg"
  source                             = "./custom-ali-gw-nsg"              #  overcome issues with ali data eip not being provided
  gateway_name                       = var.gateway_name                   # Required. Must exactly match argument gw_name in the module below
  controller_nsg_name                = var.controller_nsg_name             # Required. Name of the NSG associated with the Controller
  controller_nsg_resource_group_name = var.controller_nsg_resource_group_name      # Required. Name of the resource group where the NSG associated with the controller is deployed
  controller_nsg_rule_priority       = var.controller_nsg_rule_priority                            # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Controller
  ha_enabled                         = true                     # Optiona. Defaults to true. Must match HA GW deployment in the module below
}


module "mc-transit-alicn" {
  providers = { aviatrix = aviatrix.china}
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "2.5.1"
  name                = var.gateway_name
  account             = var.account
  cloud               = var.cloud
  region              = var.region
  local_as_number     = var.localasn
  allocate_new_eip    = true
  az_support          = false
  enable_segmentation = true
  gw_name             = var.gateway_name
  insane_mode         = false
  cidr                = var.cidr
  ha_gw               = true
}


#   fine tune later; used for direct bgpoipsec between ali-global and ali-cn (no vpc peering and also after vpc peering)
#Nov 6th >>    extconn.s2c.tf  >> use of Bgpoipsec and also after vpc peering for  private ip (phase1_local_identified).  
/*
#Note/.  Issue with accessing vpc peering on ALI, need to chase G.Lam.
resource "aviatrix_transit_external_device_conn" "to_aliglobal" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit-ali.vpc.vpc_id
  connection_name           = "2aliglobal"
  gw_name                   = var.gateway_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = "65004"
  bgp_remote_as_num         = "65040"
  #backup_bgp_remote_as_num  = "65515"
  #ha_enabled                = "true"
  #remote_gateway_ip         = "47.91.91.120"
  remote_gateway_ip          = "10.40.28.4"
  phase1_local_identifier    = "private_ip"
  #backup_remote_gateway_ip  = "20.31.84.218"
  pre_shared_key            = "Aviatrix123#"
  #backup_pre_shared_key     = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "169.254.31.202/30, 169.254.32.202/30"
  remote_tunnel_cidr        = "169.254.31.201/30, 169.254.32.201/30"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
}
*/


# test out the ali data resource block for getting eips as this is failing during deployment

data "alicloud_eip_addresses" "avx_gw" {
  provider = alicloud.china
  #depends_on = [
    #time_sleep.avx_gw
  #]
  status = "InUse"
  name_regex = "${var.gateway_name}-eip"
  depends_on = [ module.mc-transit-alicn ]
}

data "alicloud_eip_addresses" "avx_gwha" {
  provider = alicloud.china
  #count = var.ha_enabled ? 1 : 0
  #depends_on = [
    #time_sleep.avx_gwha
  #]
  status = "InUse"
  name_regex = "${var.gateway_name}-ha"
  depends_on = [ module.mc-transit-alicn ]
}


### result of above :     ###

/*
> data.alicloud_eip_addresses.avx_gw.eips[0]
{
  "bandwidth" = "200"
  "creation_time" = "2023-11-05T16:07:32Z"
  "deletion_protection" = false
  "id" = "eip-2ze6awe4ka0xjec660oxx"
  "instance_id" = "i-2ze00kkxxwd5tpyph7yc"
  "instance_type" = "EcsInstance"
  "internet_charge_type" = "PayByTraffic"
  "ip_address" = "39.105.118.70"
  "status" = "InUse"
}
> data.alicloud_eip_addresses.avx_gw.eips[0].ip_address
"39.105.118.70"
>
*/



#  ALI Global

module "mc-transit-aligbl" {
  providers = { aviatrix = aviatrix.global }
  source              = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version             = "2.5.1"
  name                = var.gbl_gw_name
  account             = var.gbl_account
  cloud               = var.cloud
  region              = var.gbl_region
  local_as_number     = var.gbl_localasn
  allocate_new_eip    = true
  az_support          = false
  enable_segmentation = true
  gw_name             = var.gbl_gw_name
  insane_mode         = false
  cidr                = var.gbl_cidr
  ha_gw               = true
}