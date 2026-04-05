---
name: sake-ci-release
description: Use when working on CI workflows, GitHub Actions, release process, changelog generation (git-cliff), or dependabot configuration.
---

# Sake CI & Release

## CI Workflows

### checks.yml — Tests & Lint
- **Triggers:** push to main, PRs to main
- **Matrix:** macOS-latest + ubuntu-latest, Swift 6.1 + 6.2.1
- **Steps:** `sake build_tests` → `sake unit_tests --skip-build` → `sake integration_tests --skip-build`
- **Lint job:** `sake lint` (macOS only, Swift 6.2.1)
- **Setup:** custom composite action `.github/actions/setup-environment` (mise + Swift + setup-sake)

### semantic-pr-lint.yml — PR Title Validation
- **Triggers:** PR opened/edited/synchronize/reopened
- **Action:** `amannn/action-semantic-pull-request@v5`
- **Allowed types:** fix, feat, chore, test, perf, refactor, doc, project, revert

### coverage.yml — Code Coverage
- **Triggers:** push to main
- **Runs on:** macOS-15 with Xcode 16.3
- **Steps:** `swift test --enable-code-coverage` → lcov export → Codecov upload

### docs-deploy.yml — Documentation
- **Triggers:** push to main (docs/** or workflow file changes)
- **VitePress** build + deploy to GitHub Pages

## Setup Environment Action

`.github/actions/setup-environment/action.yml` — composite action:
1. `jdx/mise-action@v2` (install only, no auto-install of tools)
2. `swift-actions/setup-swift@v2` with specified Swift version
3. `kattouf/setup-sake@v1` — installs sake + caches prebuilt SakeApp binary

## Dependabot

`.github/dependabot.yml`:
- Swift ecosystem, monthly
- Commit prefix: `chore(deps):`

## Release Notes — git-cliff

Config: `cliff.toml`

### Commit Parsing

```
chore(release): Bump version to X  → skipped
chore(deps): / fix(deps):          → Dependency Updates
feat:                               → Features
fix:                                → Bug Fixes
test:                               → Testing
perf:                               → Performance
refactor:                           → Refactoring
doc:                                → Documentation
project:                            → Project
revert:                             → Revert
anything else                       → Other Changes
```

### Preprocessing
- Issue numbers stripped: `\((\w+\s)?#([0-9]+)\)` → removed
- Commits sorted newest first within groups
- Scoped commits sorted by scope

### Version Tags
- v-prefixed: `v1.0.0`
- Full changelog links generated between versions

## Landing Code in Main

### Direct commit
For small changes. Commit message MUST have conventional commit prefix.

### Pull Request (squash merge only)
For larger changes. PR title MUST have conventional commit prefix (enforced by semantic-pr-lint). Commits inside branch — free format. Only squash merge is allowed (merge commit and rebase disabled).

### Branch Naming
kebab-case, optionally type-prefixed: `feat-`, `fix-`, `doc-`. Not enforced, not used for release notes.
