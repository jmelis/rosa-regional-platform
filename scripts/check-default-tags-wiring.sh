#!/usr/bin/env bash
# Verify that every Terraform variable used in a provider default_tags block
# has a corresponding -var= flag in the provisioning script that applies it.
#
# This catches bugs where default_tags are defined in a Terraform config but
# the shell script never passes the values, causing tags to use placeholder
# defaults and triggering unwanted tag drift.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROVISION_SCRIPT="$REPO_ROOT/scripts/provision-pipelines.sh"
FAILURES=0

# Map terraform config directories to the sections of provision-pipelines.sh
# that build TF_ARGS for them.
declare -A CONFIG_DIRS=(
    ["terraform/config/pipeline-regional-cluster"]="regional"
    ["terraform/config/pipeline-management-cluster"]="management"
)

for config_dir in "${!CONFIG_DIRS[@]}"; do
    config_label="${CONFIG_DIRS[$config_dir]}"
    main_tf="$REPO_ROOT/$config_dir/main.tf"

    [ -f "$main_tf" ] || continue

    # Check if this config has a default_tags block
    if ! grep -q 'default_tags' "$main_tf"; then
        continue
    fi

    # Extract variable names used inside default_tags { tags = { ... } }
    # Looks for patterns like: var.app_code, var.cost_center, etc.
    tag_vars=$(sed -n '/default_tags/,/^  }/p' "$main_tf" \
        | grep -oP 'var\.\K[a-z_]+' \
        | sort -u)

    for var_name in $tag_vars; do
        # target_environment is passed as target_environment, not a tag-specific var
        if [ "$var_name" = "target_environment" ]; then
            continue
        fi

        if ! grep -q "\-var=\"${var_name}=" "$PROVISION_SCRIPT"; then
            echo "❌ $config_dir: default_tags references var.${var_name} but provision-pipelines.sh never passes -var=\"${var_name}=\""
            FAILURES=$((FAILURES + 1))
        fi
    done
done

if [ "$FAILURES" -gt 0 ]; then
    echo ""
    echo "❌ Found $FAILURES default_tags variable(s) not wired through provision-pipelines.sh"
    echo "   Add -var=\"<name>=\${VALUE}\" to the TF_ARGS array for each missing variable."
    exit 1
fi

echo "✅ All default_tags variables are wired through provision-pipelines.sh"
