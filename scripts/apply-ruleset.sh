#!/usr/bin/env bash
# Usage: ./scripts/apply-ruleset.sh <owner> <repo>
# Requires: gh cli authenticated with admin scope

set -euo pipefail

OWNER="${1:?Usage: $0 <owner> <repo>}"
REPO="${2:?Usage: $0 <owner> <repo>}"
RULESET_FILE="rulesets/deploy-branch-ruleset.json"

echo "Applying deploy branch ruleset to ${OWNER}/${REPO}..."

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/${OWNER}/${REPO}/rulesets" \
  --input "${RULESET_FILE}"

echo "Ruleset applied."
