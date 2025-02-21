# OCI - Compute

This script creates 2 A1 instances in the OCI cloud, each with 2 oCPU, 12GB of RAM and 100GB of block storage. The instances are created in the same VCN and subnet

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