
# (1) setup vpc peering
data "alicloud_account" "accepting" {
  provider = alicloud.china
}

resource "alicloud_vpc" "accepting_vpc" {
  provider   = alicloud.china
  vpc_name   = module.mc-transit-alicn.vpc.name
  cidr_block = var.cidr
}


resource "alicloud_vpc_peer_connection" "default" {
  provider             = alicloud.global
  peer_connection_name = "${module.mc-transit-aligbl.vpc.id}-to-${module.mc-transit-alicn.vpc.id}"
  vpc_id               = module.mc-transit-aligbl.vpc.vpc_id
  accepting_ali_uid    = data.alicloud_account.accepting.id
  accepting_region_id  = "cn-beijing"        #  ali syntax, avtx prepends 'acs'
  accepting_vpc_id     = alicloud_vpc.accepting_vpc.id
  description          = "Conn-2-alicn"
}



# route table entries stuff
# https://www.alibabacloud.com/help/en/vpc/route-table-overview
# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry#VpcPeer

# (2) set up vpc peering routing

#  get initiator vpc route table id
data "alicloud_route_tables" "aliglobal" {
  provider = alicloud.global
  vpc_id = "${module.mc-transit-aligbl.vpc.vpc_id}"
}

output "route_table" {
  value = "${data.alicloud_route_tables.aliglobal.tables}"
}

output "route_table_ids" {
  value = "${data.alicloud_route_tables.aliglobal.ids}"
}

# get acceptor cn RT
data "alicloud_route_tables" "alicn" {
  provider = alicloud.china
  vpc_id = "${module.mc-transit-alicn.vpc.vpc_id}"
}

output "cn_rt" {
  value = "${data.alicloud_route_tables.alicn.tables}"
}

output "cn_rt_ids" {
  value = "${data.alicloud_route_tables.alicn.ids}"
}


#  RT entries

resource "alicloud_route_entry" "toaliglobal" {
  provider = alicloud.china
  #route_table_id        = "vtb-2zend1dejeim43izitlnx"
  route_table_id        = "${alicloud_vpc.accepting_vpc.router_table_id}"
  destination_cidrblock = var.gbl_cidr
  nexthop_type          = "VpcPeer"
  nexthop_id            = "${alicloud_vpc_peer_connection.default.id}"
}


resource "alicloud_route_entry" "alicn" {
  provider = alicloud.global                                 # needed alias ; without didn't find RT
  route_table_id        =  "${data.alicloud_route_tables.aliglobal.tables[0].route_table_id}"
  #route_table_id        = "${alicloud_vpc.accepting_vpc.router_table_id}"
  destination_cidrblock = var.cidr
  nexthop_type          = "VpcPeer"
  nexthop_id            = "${alicloud_vpc_peer_connection.default.id}"
}



# (3)  s2c - BGPoIPSEC
resource "aviatrix_transit_external_device_conn" "to_alicn" {
  provider = aviatrix.global
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit-aligbl.vpc.vpc_id
  connection_name           = "${alicloud_vpc_peer_connection.default.description}"
  gw_name                   = module.mc-transit-aligbl.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = var.gbl_localasn
  bgp_remote_as_num         = var.localasn
  #backup_bgp_remote_as_num  = "65515"
  #ha_enabled                = "true"
  #remote_gateway_ip         = "47.94.146.45"
  remote_gateway_ip = module.mc-transit-alicn.transit_gateway.private_ip
  phase1_local_identifier = "private_ip"
  #backup_remote_gateway_ip  = "20.31.84.218"
  pre_shared_key            = "Aviatrix123#"
  #backup_pre_shared_key     = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "169.254.31.201/30, 169.254.32.201/30"
  remote_tunnel_cidr        = "169.254.31.202/30, 169.254.32.202/30"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
  #depends_on = [ alicloud_vpc_peer_connection.default  ]
}

resource "aviatrix_transit_external_device_conn" "to_aliglobal" {
  provider = aviatrix.china
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit-alicn.vpc.vpc_id
  connection_name           = "${alicloud_vpc_peer_connection.default.description}"
  gw_name                   = module.mc-transit-alicn.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = var.localasn
  bgp_remote_as_num         = var.gbl_localasn
  #backup_bgp_remote_as_num  = "65515"
  #ha_enabled                = "true"
  #remote_gateway_ip         = "47.94.146.45"
  remote_gateway_ip = module.mc-transit-aligbl.transit_gateway.private_ip
  phase1_local_identifier = "private_ip"
  #backup_remote_gateway_ip  = "20.31.84.218"
  pre_shared_key            = "Aviatrix123#"
  #backup_pre_shared_key     = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "169.254.31.202/30, 169.254.32.202/30"
  remote_tunnel_cidr        = "169.254.31.201/30, 169.254.32.201/30"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
  #depends_on = [ alicloud_vpc_peer_connection.default  ]
}



# (4) Security rules to allow basic ICMP