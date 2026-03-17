# CI Known Issues

This file is the self-learning knowledge base for the ci-troubleshoot agent. Each entry represents a confirmed failure pattern that has been validated by a human reviewer.

When diagnosing a new failure, check these patterns first for a quick match before doing deep investigation.

## Format

Each entry follows this structure:

```
### <Short Title>
- **Pattern**: <What to look for in logs/artifacts>
- **Root Cause**: <Why it happens>
- **Fix**: <How to resolve>
- **Files**: <Relevant source files>
- **First Seen**: <Date and PR/job link>
```

---

### RC/MC Pipeline Race Condition — Platform API Not Ready

- **Pattern**: `API Gateway /live did not return 200 after N attempts` or HTTP 503 from API Gateway during MC `register` step
- **Root Cause**: RC and MC CodePipelines run in parallel. The MC pipeline's `Register` stage calls the Platform API via the RC's API Gateway, but the Platform API pod hasn't been deployed yet because the RC pipeline's ArgoCD bootstrap hasn't completed (or ArgoCD hasn't finished syncing the Platform API app). The ALB target group at port 8080 has no healthy targets.
- **Fix**: Increase `MAX_RETRIES` in `scripts/buildspec/register.sh` (e.g., from 10 to 30 for ~15 min patience), or add an ArgoCD sync-wait to the RC bootstrap script, or add pipeline ordering in `ci/ephemerallib/ephemeral.py`.
- **Files**: `scripts/buildspec/register.sh` (health check retry logic), `ci/ephemerallib/ephemeral.py` (`_wait_for_provision` runs RC/MC in parallel), `terraform/config/pipeline-management-cluster/main.tf` (MC pipeline stages)
- **First Seen**: 2026-03-17, PR #191 `on-demand-e2e` [job link](https://prow.ci.openshift.org/view/gs/test-platform-results/pr-logs/pull/openshift-online_rosa-regional-platform/191/pull-ci-openshift-online-rosa-regional-platform-main-on-demand-e2e/2033939688007405568)
