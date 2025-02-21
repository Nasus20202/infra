terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88"
    }

    oci = {
      source  = "oracle/oci"
      version = "~> 6.27"
    }
  }

  required_version = ">= 1.10"

  backend "s3" {
    bucket         = "nasus-tfstate"
    region         = "eu-central-1"
    key            = "infra/terraform/oci/terraform.tfstate"
    dynamodb_table = "nasus-tfstate-lock"
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "oci" {
  region = "eu-frankfurt-1"
}

