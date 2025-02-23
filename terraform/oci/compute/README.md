# OCI - Compute

This script creates VCNs with both public and private subnets and this compute instances:

- 2 `VM.Standard.A1.Flex` instances each with 2 OCPU and 12 GB memory for RKE2 cluster

## Usage

### Required tools

- Terraform
- OCI CLI
- AWS CLI (for S3 backend)

```bash
aws configure
oci session authenticate
terraform init
terraform apply
```
