resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "oci_identity_compartment" "compartment" {
  name        = "${local.prefix}-compartment"
  description = "All general-purpose compute instances"
}
