data "oci_identity_availability_domain" "ad" {
  compartment_id = oci_identity_compartment.compartment.id
  ad_number      = var.availability_domain
}

data "oci_core_images" "ubuntu" {
  compartment_id           = data.oci_identity_availability_domain.ad.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
  shape                    = "VM.Standard.A1.Flex"
}

data "oci_objectstorage_namespace" "ns" {}

data "cloudflare_zones" "cf_zones" {}
