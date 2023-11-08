/*
resource "time_sleep" "avx_gw" {
  create_duration   = "5m"
}

resource "time_sleep" "avx_gwha" {
  count = var.ha_enabled ? 1 : 0
  create_duration   = "13m"
}

data "alicloud_eip_addresses" "avx_gw" {
  provider = alicloud.china
  depends_on = [
    time_sleep.avx_gw
  ]
  status = "InUse"
  name_regex = "${var.gateway_name}-eip"
}

data "alicloud_eip_addresses" "avx_gwha" {
  provider = alicloud.china
  count = var.ha_enabled ? 1 : 0
  depends_on = [
    time_sleep.avx_gwha
  ]
  status = "InUse"
  name_regex = "${var.gateway_name}-ha"
}
*/


resource "azurerm_network_security_rule" "avx_controller_allow_gw" {
  provider                    = azurerm.controller
  name                        = format("ali-avx-%s-gw", var.gateway_name)
  resource_group_name         = var.controller_nsg_resource_group_name
  network_security_group_name = var.controller_nsg_name
  access                      = "Allow"  
  direction                   = "Inbound"
  priority                    = var.controller_nsg_rule_priority  
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  #source_address_prefixes     = local.gateway_address
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  description                 = "Allow access to AliCloud Avaitrix Gateway ${var.gateway_name}"
}

resource "azurerm_network_security_rule" "avx_controller_allow_gwha" {
  count                       = var.ha_enabled ? 1 : 0
  provider                    = azurerm.controller
  name                        = format("ali-avx-%s-gwha", var.gateway_name)
  resource_group_name         = var.controller_nsg_resource_group_name
  network_security_group_name = var.controller_nsg_name
  access                      = "Allow"  
  direction                   = "Inbound"
  priority                    = var.controller_nsg_rule_priority + 1
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  #source_address_prefixes     = local.gatewayha_address
  source_address_prefix     = "*"
  destination_address_prefix  = "*"
  description                 = "Allow access to AliCloud Avaitrix Gateway ${var.gateway_name}-hagw"
}