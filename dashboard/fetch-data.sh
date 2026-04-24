#!/usr/bin/env bash
# Fetches open PRs labelled "review-ready" or "discussion-needed" across all
# ROSA Regional Platform repos and writes dashboard/data.json.
#
# Requires: gh (authenticated), jq
# Usage:    ./dashboard/fetch-data.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="${SCRIPT_DIR}/data.json"

REPOS=(
  openshift-online/rosa-regional-platform
  openshift-online/rosa-regional-platform-api
  openshift-online/rosa-regional-platform-cli
  openshift-online/rosa-regional-platform-internal
)

REPO_FLAGS=""
for r in "${REPOS[@]}"; do
  REPO_FLAGS="$REPO_FLAGS --repo $r"
done

JSON_FIELDS="repository,number,title,author,labels,createdAt,updatedAt,url"

echo "Fetching review-ready PRs..."
gh search prs --state open --label review-ready \
  $REPO_FLAGS --limit 100 --json "$JSON_FIELDS" \
  > /tmp/rr.json 2>/dev/null || echo '[]' > /tmp/rr.json

echo "Fetching help-wanted PRs..."
gh search prs --state open --label "discussion-needed" \
  $REPO_FLAGS --limit 100 --json "$JSON_FIELDS" \
  > /tmp/hw.json 2>/dev/null || echo '[]' > /tmp/hw.json

jq -n \
  --arg updated "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --slurpfile rr /tmp/rr.json \
  --slurpfile hw /tmp/hw.json \
  '{updated: $updated, review_ready: $rr[0], help_wanted: $hw[0]}' \
  > "$OUT"

echo "Wrote $OUT ($(jq '.review_ready | length' "$OUT") review-ready, $(jq '.help_wanted | length' "$OUT") help-wanted)"
