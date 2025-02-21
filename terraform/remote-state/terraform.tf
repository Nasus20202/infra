terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88"
    }
  }

  required_version = ">= 1.10"
}

provider "aws" {
  region = "eu-central-1"
}
