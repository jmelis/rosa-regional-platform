#!/bin/bash
set -euo pipefail

# =============================================================================
# Ephemeral resource janitor — purge leaked AWS resources from ephemeral CI accounts.
# =============================================================================
# Fallback cleanup for when terraform destroy does not fully tear down
# resources after ephemeral tests.
#
# AWS credentials are expected via AWS profiles (AWS_CONFIG_FILE must be set).
# In CI, source ci/setup-aws-profiles.sh before running this script.
#
# All three account purges run in parallel to reduce wall-clock time.
# Per-account logs are written to ARTIFACT_DIR for the Prow artifacts UI.
# =============================================================================

DRY_RUN=false

export AWS_PAGER=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PURGE_SCRIPT="${SCRIPT_DIR}/janitor/purge-aws-account.sh"

LOG_DIR="${ARTIFACT_DIR:-/tmp}/janitor-logs"
mkdir -p "${LOG_DIR}"

PURGE_ARGS=()
if [ "${DRY_RUN}" = false ]; then
  PURGE_ARGS+=(--no-dry-run)
fi

# Track background PIDs and their labels for final status reporting.
declare -A PIDS=()
FAILED=0

# purge_regional runs aws-nuke against the regional ephemeral account.
purge_regional() {
  AWS_PROFILE=rrp-rc "${PURGE_SCRIPT}" "${PURGE_ARGS[@]+"${PURGE_ARGS[@]}"}"
}

# purge_management runs aws-nuke against the management ephemeral account.
purge_management() {
  AWS_PROFILE=rrp-mc "${PURGE_SCRIPT}" "${PURGE_ARGS[@]+"${PURGE_ARGS[@]}"}"
}

# purge_central runs aws-nuke against the central ephemeral account.
purge_central() {
  AWS_PROFILE=rrp-central "${PURGE_SCRIPT}" "${PURGE_ARGS[@]+"${PURGE_ARGS[@]}"}"
}

# Launch all three purges in parallel, logging output to artifact files.
echo "Starting parallel account purges (logs in ${LOG_DIR}/)"

purge_regional  &> "${LOG_DIR}/regional.log" &
PIDS["regional"]=$!

purge_management &> "${LOG_DIR}/management.log" &
PIDS["management"]=$!

purge_central &> "${LOG_DIR}/central.log" &
PIDS["central"]=$!

# Wait for all background jobs and report results.
for label in regional management central; do
  if wait "${PIDS[${label}]}"; then
    echo ">> ${label} account purge succeeded"
  else
    mv "${LOG_DIR}/${label}.log" "${LOG_DIR}/${label}.FAILED.log"
    echo ">> ${label} account purge FAILED (see ${LOG_DIR}/${label}.FAILED.log)" >&2
    FAILED=1
  fi
done

echo ""
echo "==== Janitor complete ===="

exit "${FAILED}"
