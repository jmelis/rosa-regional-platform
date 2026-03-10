#!/usr/bin/env bash
#
# setup-apply-preflight.sh - Common pre-flight setup for apply pipelines
#
# This script handles the common pre_build logic for both regional and management cluster
# apply pipelines:
# - Validates required environment variables
# - Initializes account credential helpers
# - Outputs configuration summary
#
# Expected environment variables:
#   TARGET_ACCOUNT_ID - The target AWS account ID
#   TARGET_REGION     - The target AWS region
#   REGIONAL_ID       - Regional cluster identifier (RC pipelines)
#   MANAGEMENT_ID     - Management cluster identifier (MC pipelines)
#   (At least one of REGIONAL_ID or MANAGEMENT_ID must be set)
#
# Exports:
#   CENTRAL_ACCOUNT_ID - Central account ID (via init_account_helpers)
#   CLUSTER_ID         - Cluster identifier (derived from REGIONAL_ID or MANAGEMENT_ID)

set -euo pipefail

echo "=========================================="
echo "Pre-flight Setup"
echo "=========================================="

# Derive CLUSTER_ID from REGIONAL_ID or MANAGEMENT_ID
CLUSTER_ID="${REGIONAL_ID:-${MANAGEMENT_ID:-}}"

# Validate required environment variables
if [[ -z "${TARGET_ACCOUNT_ID:-}" || -z "${TARGET_REGION:-}" || -z "${CLUSTER_ID:-}" ]]; then
    echo "ERROR: Required environment variables not set"
    echo "   TARGET_ACCOUNT_ID: ${TARGET_ACCOUNT_ID:-not set}"
    echo "   TARGET_REGION: ${TARGET_REGION:-not set}"
    echo "   REGIONAL_ID: ${REGIONAL_ID:-not set}"
    echo "   MANAGEMENT_ID: ${MANAGEMENT_ID:-not set}"
    exit 1
fi

# Initialize account credential helpers (captures central creds)
source "$(dirname "${BASH_SOURCE[0]}")/account-helpers.sh"
init_account_helpers

echo "Configuration:"
echo "  Central Account: $CENTRAL_ACCOUNT_ID"
echo "  Target Account: $TARGET_ACCOUNT_ID"
echo "  Target Region: $TARGET_REGION"
echo "  Cluster ID: $CLUSTER_ID"
echo ""
