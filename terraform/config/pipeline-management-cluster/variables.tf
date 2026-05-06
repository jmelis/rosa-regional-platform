variable "github_repository" {
  type        = string
  description = "GitHub Repository in owner/name format (e.g., 'octocat/hello-world')"
  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must be in 'owner/name' format"
  }
}

variable "github_branch" {
  type        = string
  description = "GitHub Branch to track"
  default     = "main"
}

variable "github_connection_arn" {
  type        = string
  description = "ARN of the shared GitHub CodeStar connection"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

# Optional variables for manual/single-target deployment
variable "target_account_id" {
  type        = string
  description = "Target AWS Account ID (Optional override)"
  default     = ""
}

variable "target_region" {
  type        = string
  description = "Target AWS Region (Optional override)"
  default     = ""
}

variable "target_environment" {
  type        = string
  description = "Target environment (integration, staging, prod)"
  default     = "integration"
}

variable "repository_url" {
  type        = string
  description = "Git repository URL for cluster configuration"
}

variable "repository_branch" {
  type        = string
  description = "Git branch to use for cluster configuration"
  default     = "main"
}

variable "management_id" {
  type        = string
  description = "Management cluster identifier for resource naming (e.g., 'mc01')"
}

variable "codebuild_image" {
  type        = string
  description = "ECR image URI for CodeBuild projects (platform image with pre-installed tools)"
}

# =============================================================================
# Tagging Configuration
# =============================================================================

variable "app_code" {
  description = "Application code for cost tagging (CMDB Application ID)"
  type        = string
  default     = "infra"
}

variable "service_phase" {
  description = "Service deployment phase (e.g., dev, stage, production)"
  type        = string
  default     = "dev"
}

variable "cost_center" {
  description = "Cost center code for billing"
  type        = string
  default     = "000"
}

variable "owner" {
  description = "Resource owner team identifier"
  type        = string
  default     = "placeholder"
}

variable "organization" {
  description = "Organization name for cost attribution"
  type        = string
  default     = "placeholder"
}

variable "app" {
  description = "Application identifier for resource tagging"
  type        = string
  default     = "rosa-regionality"
}

# =============================================================================
# Notifications Configuration
# =============================================================================

variable "slack_webhook_ssm_param" {
  type        = string
  description = "SSM Parameter Store path containing the Slack webhook URL (only required for staging, production, integration environments)"
  default     = "/rosa-regional/slack/webhook-url"
}
