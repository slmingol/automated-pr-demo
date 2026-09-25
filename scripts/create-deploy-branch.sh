#!/usr/bin/env bash
# Creates the deploy branch from main and sets up the environment protection rule.
# Run once during repo setup.
# Usage: ./scripts/create-deploy-branch.sh <owner> <repo>

set -euo pipefail

OWNER="${1:?Usage: $0 <owner> <repo>}"
REPO="${2:?Usage: $0 <owner> <repo>}"

echo "Creating deploy branch from main..."
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/${OWNER}/${REPO}/git/refs" \
  -f ref="refs/heads/deploy" \
  -f "sha=$(gh api /repos/${OWNER}/${REPO}/git/ref/heads/main --jq '.object.sha')"

echo "Creating production environment with deploy branch restriction..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${OWNER}/${REPO}/environments/production" \
  --input - << 'EOF'
{
  "deployment_branch_policy": {
    "protected_branches": false,
    "custom_branch_policies": true
  }
}
EOF

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/${OWNER}/${REPO}/environments/production/deployment-branch-policies" \
  -f name="deploy" \
  -f type="branch"

echo "Done. Apply the ruleset next: ./scripts/apply-ruleset.sh ${OWNER} ${REPO}"
