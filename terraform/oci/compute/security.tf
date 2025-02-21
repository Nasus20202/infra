resource "oci_core_security_list" "private_sl" {
  vcn_id = oci_core_vcn.vcn.id

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = oci_core_vcn.vcn.cidr_block
    source_type = "CIDR_BLOCK"
    protocol    = "1" # ICMP
    description = "Allow ICMP from the VCN"
  }

  ingress_security_rules {
    stateless   = false
    source      = oci_core_vcn.vcn.cidr_block
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      min = 22
      max = 22
    }
    description = "Allow SSH from the VCN"
  }

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-private-sl"
  freeform_tags  = local.tags
}

resource "oci_core_security_list" "public_sl" {
  vcn_id = oci_core_vcn.vcn.id

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "1" # ICMP
    description = "Allow ICMP from the Internet"
  }


  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      min = 22
      max = 22
    }
    description = "Allow SSH from the Internet"
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      min = 80
      max = 80
    }
    description = "Allow HTTP from the Internet"
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      min = 443
      max = 443
    }
    description = "Allow HTTPS from the Internet"
  }

  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "${local.prefix}-public-sl"
  freeform_tags  = local.tags
}
