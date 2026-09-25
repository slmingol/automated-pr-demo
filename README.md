# automated-pr-demo

GitOps deploy branch protection — enforces what can and cannot merge into `deploy`.

## Policy

| Source | Can merge to `deploy`? |
|--------|------------------------|
| `main` | Yes |
| `release/*` | Yes |
| feature branches | No (status check fails) |
| direct push (any human) | No (ruleset blocks) |

## Files

```
.github/
  workflows/
    validate-deploy-source.yml   # blocks PRs from disallowed sources
    deploy.yml                   # runs actual deployment on merge
  CODEOWNERS                     # requires deploy-admins approval
rulesets/
  deploy-branch-ruleset.json     # import via gh api or UI
scripts/
  create-deploy-branch.sh        # one-time repo setup
  apply-ruleset.sh               # applies the ruleset via gh cli
```

## Setup Order

1. Create deploy branch + production environment:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/create-deploy-branch.sh <owner> <repo>
   ```

2. Apply the branch ruleset:
   ```bash
   ./scripts/apply-ruleset.sh <owner> <repo>
   ```

3. In GitHub UI → Settings → Environments → `production`:
   - Add required reviewers (team or individuals)
   - Confirm deployment branch is restricted to `deploy`

4. Copy `.github/` into your target repo. Adjust `CODEOWNERS` team name.

## How It Works

- **Ruleset** (`rulesets/deploy-branch-ruleset.json`): blocks direct pushes to `deploy`, requires PR, requires CODEOWNER review, requires the `check-source` status check to pass.
- **validate-deploy-source.yml**: runs on every PR targeting `deploy`; exits 1 (blocks merge) if source branch is not `main` or `release/*`.
- **deploy.yml**: triggers on push to `deploy` (i.e., after merge); gates on `production` environment so required reviewers must approve before deployment runs.
- **CODEOWNERS**: ensures `deploy-admins` team must approve every PR to `deploy`.
