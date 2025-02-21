locals {
  prefix = "compute"

  tags = merge(
    var.tags,
    {
      "project" = "infra/terraform/oci/compute"
    }
  )
}
