# Rosa Regional Platform - Claude Instructions

## Project Overview

The **ROSA Regional Platform** redesigns ROSA HCP from globally-centralized to regionally-distributed, where each AWS region operates independently. See [docs/README.md](docs/README.md) for architecture details and design documents.

## Development Guidelines

### Agent Usage

- **ALWAYS use the architect agent** for changes to:
  - `docs/architecture/`
  - `docs/design-decisions/`
  - Any architectural decisions or patterns
- **Use code-reviewer agent** for security-sensitive code (IAM, networking, etc.)

### Architecture Patterns

- **GitOps First**: ArgoCD for cluster configuration management, infrastructure via Terraform
- **Private-by-Default**: EKS clusters use fully private architecture with ECS bootstrap
- **Declarative State**: CLM maintains single source of truth for all cluster state
- **Event-Driven**: Maestro handles CLM-to-MC communication for configuration distribution
- **Regional Isolation**: Each region operates independently with minimal cross-region dependencies

### Development Workflow

#### For Infrastructure Changes

1. Update Terraform modules in `terraform/modules/`
2. Use `make terraform-fmt` and lint jobs for sanitization
3. For manual testing: create local `terraform.tfvars` and use `make apply-infra-regional` or `make apply-infra-management`
4. Ensure architect agent reviews any architectural changes

#### For Application Changes

1. Update ArgoCD configurations in `argocd/`
2. Follow GitOps patterns - ArgoCD will sync changes
3. Test in development region first

#### For New Regions

1. Add region config to Git repository
2. Run `make provision-regional` to provision Regional Cluster
3. ArgoCD bootstrap handles core service deployment
4. Management Clusters auto-provision as needed

### Security Guidelines

- **AWS IAM Only**: Use AWS IAM for all authentication/authorization
- **Private Networking**: No public endpoints except regional API Gateway
- **Least Privilege**: Follow AWS IAM best practices for service roles
- **Encryption at Rest**: KMS-encrypted EKS secrets, RDS, and EBS volumes
- **Break-Glass Access**: Use ephemeral containers for emergency access only

### Formatting

- **Markdown**: All markdown files must be formatted with `prettier`. Run `npx prettier --write '**/*.md'` before committing markdown changes.

### Testing and Validation

- **Terraform Validation**: Always run `terraform validate` and `terraform plan`
- **Format Check**: Use `make terraform-fmt` before committing
- **ArgoCD Health**: Verify applications sync successfully
- **Security Review**: Use architect agent for security-sensitive changes

### Important Files and Patterns

- `Makefile` - Standardized provisioning commands
- `bootstrap-argocd.sh` - ECS Fargate bootstrap script
- `argocd/config/shared/argocd/` - ArgoCD self-management Helm chart
- Design decisions follow ADR format in `docs/design/`

Include AGENTS.md
