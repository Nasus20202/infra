# OCI - Compute

This script creates VCNs with both public and private subnets and this compute instances:

- 2 `VM.Standard.A1.Flex` instances each with 2 OCPU and 12 GB memory for RKE2 cluster
- Network Load Balancer with 2 backend sets, one for each RKE2 instance
- S3 compatible OCI Object Storage bucket for Longhorn backup
- DNS records for the RKE2 instances and the load balancer
- IAM users for Longhorn backup access and Grafana metrics plugin

## Usage

### Required tools

- Terraform
- OCI CLI
- AWS CLI (for S3 backend)

```bash
aws configure # Configure AWS CLI with your credentials
oci session authenticate # Configure OCI CLI with your credentials

cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars # Configure Cloudflare API key and OCI compartment

terraform init  # Initialize Terraform
terraform plan  # Review the plan
terraform apply # Apply the changes
```

To check the outputs, run:

```bash
terraform output
# or
terraform output -json # to see
```
