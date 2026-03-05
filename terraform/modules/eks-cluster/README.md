# EKS Cluster Module

Creates private EKS clusters with security-first configuration and standardized naming/tagging.

## Features

- **Deterministic Resource Naming**: Uses `cluster_id` for all resource names (e.g., `regional`, `mc01`)
- **Provider-Level Tagging**: Enforces required organizational tags via AWS provider default_tags
- **Fully Private Clusters**: EKS control plane with private endpoint only
- **EKS Auto Mode**: Uses Auto Mode for simplified node management
- **Security Hardening**: KMS encryption, IMDSv2 enforcement, and network segmentation
- **High Availability**: Multi-AZ NAT Gateways for fault-tolerant egress connectivity

## Naming Convention

All resources are named using the `cluster_id` variable passed to the module (e.g., `regional`, `mc01`, or `xg4y-regional` in CI).

**Examples:**

- EKS Cluster: `mc01`
- VPC: `mc01-vpc`
- IAM Roles: `mc01-cluster-role`
- KMS Alias: `alias/mc01-eks-secrets`

Resource names are deterministic -- no random suffixes. An optional CI prefix (e.g., `xg4y-`) provides isolation when multiple clusters share the same AWS account. Environment and sector are applied as tags, not embedded in resource names.

## Required Provider Configuration

**IMPORTANT**: You must configure the required tags in your AWS provider's `default_tags`:

```hcl
provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      app-code      = "APP001"        # CMDB Application ID (required)
      service-phase = "development"   # development, staging, or production (required)
      cost-center   = "123"          # 3-digit cost center code (required)
    }
  }
}
```

## Usage

### Management Cluster

```hcl
module "management_cluster" {
  source = "./terraform/modules/eks-cluster"

  cluster_id   = var.management_id
  cluster_type = "management-cluster"

  # Optional cluster configuration
  cluster_version         = "1.34"
  node_instance_types     = ["t3.medium", "t3a.medium"]
  node_group_desired_size = 1
  node_group_min_size     = 1
  node_group_max_size     = 2
}
```

### Regional Cluster

```hcl
module "regional_cluster" {
  source = "./terraform/modules/eks-cluster"

  cluster_id   = var.regional_id
  cluster_type = "regional-cluster"

  # Optional cluster configuration
  node_group_desired_size = 2
  node_group_min_size     = 1
  node_group_max_size     = 4
}
```

## Variables

| Name                            | Description                                                                     | Type           | Default                                               | Required |
| ------------------------------- | ------------------------------------------------------------------------------- | -------------- | ----------------------------------------------------- | -------- |
| `cluster_id`                    | Deterministic cluster identifier for resource naming (e.g., `regional`, `mc01`) | `string`       | n/a                                                   | yes      |
| `cluster_type`                  | Type of cluster: `regional-cluster` or `management-cluster`                     | `string`       | n/a                                                   | yes      |
| `cluster_version`               | Kubernetes version                                                              | `string`       | `"1.34"`                                              | no       |
| `vpc_cidr`                      | VPC CIDR block                                                                  | `string`       | `"10.0.0.0/16"`                                       | no       |
| `availability_zones`            | List of availability zones (auto-detected if empty)                             | `list(string)` | `[]`                                                  | no       |
| `private_subnet_cidrs`          | CIDR blocks for private subnets                                                 | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]`       | no       |
| `public_subnet_cidrs`           | CIDR blocks for public subnets                                                  | `list(string)` | `["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]` | no       |
| `node_instance_types`           | EC2 instance types for nodes                                                    | `list(string)` | `["t3.medium", "t3a.medium"]`                         | no       |
| `node_group_desired_size`       | Desired number of nodes                                                         | `number`       | `2`                                                   | no       |
| `node_group_min_size`           | Minimum number of nodes                                                         | `number`       | `1`                                                   | no       |
| `node_group_max_size`           | Maximum number of nodes                                                         | `number`       | `4`                                                   | no       |
| `node_disk_size`                | EBS volume size for nodes (GiB)                                                 | `number`       | `20`                                                  | no       |
| `enable_pod_security_standards` | Enable Pod Security Standards                                                   | `bool`         | `true`                                                | no       |

## Outputs

| Name                                 | Description                                        |
| ------------------------------------ | -------------------------------------------------- |
| `cluster_name`                       | EKS cluster name (same as `cluster_id`)            |
| `cluster_arn`                        | EKS cluster ARN                                    |
| `cluster_endpoint`                   | EKS cluster API endpoint                           |
| `cluster_version`                    | Kubernetes version of the cluster                  |
| `cluster_certificate_authority_data` | Base64 encoded certificate data                    |
| `cluster_security_group_id`          | EKS cluster security group ID                      |
| `node_security_group_id`             | EKS node security group ID (Auto Mode primary SG)  |
| `vpc_id`                             | VPC ID where cluster is deployed                   |
| `private_subnet_ids`                 | Private subnet IDs where worker nodes are deployed |
| `public_subnet_ids`                  | Public subnet IDs (NAT gateways only)              |
| `cluster_iam_role_arn`               | IAM role ARN of the EKS cluster                    |
| `node_iam_role_arn`                  | IAM role ARN of EKS Auto Mode nodes                |
| `kms_key_arn`                        | KMS key ARN for EKS secrets encryption             |

## Bootstrap

This module provisions the EKS cluster infrastructure only. ArgoCD bootstrap is handled separately by the `ecs-bootstrap` module, which runs an ECS Fargate task to install ArgoCD into the private cluster. See [ECS Fargate Bootstrap](../../../docs/design/fully-private-eks-bootstrap.md) for details.

## Requirements

- Terraform >= 1.14.3
- AWS Provider >= 6.0
- Required provider `default_tags` configuration
