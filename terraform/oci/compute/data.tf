data "oci_identity_availability_domain" "ad" {
  compartment_id = oci_identity_compartment.compartment.id
  ad_number      = var.availability_domain
}

data "oci_core_images" "oracle_linux" {
  compartment_id   = data.oci_identity_availability_domain.ad.compartment_id
  operating_system = "Oracle Linux"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"
}
