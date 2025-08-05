variable "region" {
  description = "The OCI region to deploy resources in"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "tenancy_ocid" {
  description = "The OCID of the OCI tenancy"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaax4ivut4i4qu5mn5r2oz33obu6fazwbr24w323xhrg7ojebtk7kta"
}

variable "vcn_cidr" {
  description = "The CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "availability_domain" {
  description = "The availability domain to create the instance in"
  type        = number
  default     = 3
}
