data "oci_identity_availability_domain" "ad" {
  compartment_id = oci_identity_compartment.compartment.id
  ad_number      = var.availability_domain
}

data "oci_core_images" "ubuntu" {
  compartment_id = data.oci_identity_availability_domain.ad.compartment_id
  display_name   = "Canonical-Ubuntu-24.04-aarch64-2024.09.30-0"
}
