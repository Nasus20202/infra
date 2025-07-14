terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }

  required_version = ">= 1.10"

  backend "s3" {
    bucket         = "nasus-tfstate"
    region         = "eu-central-1"
    key            = "infra/terraform/oci/compute/terraform.tfstate"
    use_lockfile   = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "oci" {
  region = "eu-frankfurt-1"
}
