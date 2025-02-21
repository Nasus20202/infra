resource "oci_core_vcn" "vcn" {
  cidr_block = var.vcn_cidr
  dns_label  = local.prefix

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-vcn"
  freeform_tags  = local.tags
}

resource "oci_core_subnet" "private_subnet" {
  vcn_id            = oci_core_vcn.vcn.id
  cidr_block        = var.private_subnet_cidr
  dns_label         = "privatesubnet"
  security_list_ids = [oci_core_security_list.private_sl.id]

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-private-subnet"
  freeform_tags  = local.tags
}

resource "oci_core_subnet" "public_subnet" {
  vcn_id            = oci_core_vcn.vcn.id
  cidr_block        = var.public_subnet_cidr
  dns_label         = "publicsubnet"
  security_list_ids = [oci_core_security_list.public_sl.id]

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-public-subnet"
  freeform_tags  = local.tags
}

resource "oci_core_internet_gateway" "ig" {
  vcn_id = oci_core_vcn.vcn.id

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-ig"
  freeform_tags  = local.tags
}

resource "oci_core_route_table" "public_route_table" {
  vcn_id = oci_core_vcn.vcn.id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-public-route-table"
  freeform_tags  = local.tags
}
