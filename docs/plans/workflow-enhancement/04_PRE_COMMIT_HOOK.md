# Phase 4: Pre-commit Hook Enhancement

> Automated quality verification before commit

## Purpose

Automatically perform quality checks at commit time to prevent incomplete
or low-quality code from entering the repository.

## Usage Scenarios

```bash
# Automatically runs on git commit
$ git commit -m "Add login feature"

🔍 Running pre-commit checks...
✅ Checklist validation passed
✅ No TODO comments in staged files
✅ Tests passed
✅ Lint passed

Commit successful!
```

## Check Items

### 1. Checklist Validation

Checks the checklist.md of the feature currently being worked on to verify
that checklist items related to the changes being committed are completed.

```yaml
check: checklist_validation
behavior:
  - Find checklist items related to changed files
  - Verify those items are checked with [x]
  - Warning if incomplete (non-blocking)
```

### 2. TODO/FIXME Check

```yaml
check: todo_comments
patterns:
  - "TODO"
  - "FIXME"
  - "XXX"
  - "HACK"
behavior:
  - Search patterns in staged files
  - Output warning if found (non-blocking)
  - Blocking in --strict mode
```

### 3. Test Execution

```yaml
check: run_tests
behavior:
  - Run only tests related to changed files
  - Block commit on failure
  - Can bypass with --skip-tests
```

### 4. Lint Check

```yaml
check: lint
behavior:
  - Run project linter (eslint, golint, etc.)
  - Block commit on error
  - Output warnings only
```

### 5. Secrets Detection

```yaml
check: secrets_detection
patterns:
  - API keys (AKIA, sk-, pk_)
  - Passwords in config
  - Private keys
behavior:
  - Block commit if found
  - Never bypassable
```

## Output Format

### All Checks Pass

```
🔍 Pre-commit Quality Check
═══════════════════════════

✅ Checklist     Related items are completed
✅ TODO/FIXME    No issues found
✅ Tests         3 tests passed (0.5s)
✅ Lint          No errors
✅ Secrets       No secrets detected

═══════════════════════════
All checks passed! Proceeding with commit.
```

### Some Warnings

```
🔍 Pre-commit Quality Check
═══════════════════════════

⚠️ Checklist     1 related item not checked
   └─ [ ] Add input validation (internal/auth/handler.go)

⚠️ TODO/FIXME    2 comments found
   └─ internal/auth/store.go:45: TODO: add index
   └─ internal/auth/handler.go:78: FIXME: handle edge case

✅ Tests         5 tests passed (1.2s)
✅ Lint          No errors
✅ Secrets       No secrets detected

═══════════════════════════
⚠️ Warnings found, but proceeding with commit.
   Consider addressing these issues.
```

### Blocking Errors

```
🔍 Pre-commit Quality Check
═══════════════════════════

✅ Checklist     OK
✅ TODO/FIXME    OK

❌ Tests         2 tests failed
   └─ TestLogin: expected 200, got 401
   └─ TestSignup: timeout after 5s

❌ Lint          3 errors
   └─ handler.go:12: undefined: UserService
   └─ store.go:8: unused import "fmt"
   └─ types.go:25: missing return

✅ Secrets       OK

═══════════════════════════
❌ Commit blocked. Please fix the errors above.

To skip tests (not recommended):
  git commit --no-verify
```

## File Structure

```
hooks/
├── pre-commit-quality.sh     # Main hook script
├── checks/
│   ├── checklist.sh          # Checklist validation
│   ├── todo.sh               # TODO check
│   ├── tests.sh              # Test execution
│   ├── lint.sh               # Lint check
│   └── secrets.sh            # Secrets detection
└── config/
    └── pre-commit.yaml       # Hook settings
```

## pre-commit.yaml Settings

```yaml
# Pre-commit hook configuration

checks:
  checklist:
    enabled: true
    blocking: false           # Warning only, not blocking
    plans_path: "docs/plans"

  todo:
    enabled: true
    blocking: false
    patterns:
      - "TODO"
      - "FIXME"
    strict_mode: false        # Blocking if true

  tests:
    enabled: true
    blocking: true            # Block on failure
    command: "go test ./..."  # Or npm test, pytest, etc.
    timeout: 60               # seconds

  lint:
    enabled: true
    blocking: true
    command: "golangci-lint run"

  secrets:
    enabled: true
    blocking: true            # Always blocking
    patterns:
      - "AKIA[0-9A-Z]{16}"    # AWS Access Key
      - "sk-[a-zA-Z0-9]{48}"  # OpenAI API Key
      - "password\\s*=\\s*[\"'][^\"']+[\"']"

# File filters
filters:
  include:
    - "*.go"
    - "*.ts"
    - "*.py"
  exclude:
    - "*_test.go"
    - "*.mock.*"
    - "vendor/*"
    - "node_modules/*"
```

## Installation

### Automatic Installation (install.sh extension)

```bash
# Add to install.sh
install_pre_commit_hook() {
  local hook_path=".git/hooks/pre-commit"

  if [ -f "$hook_path" ]; then
    echo "Pre-commit hook already exists. Backup and replace? (y/n)"
    read answer
    if [ "$answer" != "y" ]; then
      return
    fi
    cp "$hook_path" "$hook_path.backup"
  fi

  cp hooks/pre-commit-quality.sh "$hook_path"
  chmod +x "$hook_path"
  echo "✅ Pre-commit hook installed"
}
```

### Manual Installation

```bash
# Copy hook
cp hooks/pre-commit-quality.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Or create symbolic link
ln -s ../../hooks/pre-commit-quality.sh .git/hooks/pre-commit
```

## Hook Script Structure

```bash
#!/bin/bash
# hooks/pre-commit-quality.sh

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Pre-commit Quality Check"
echo "═══════════════════════════"

WARNINGS=0
ERRORS=0

# 1. Checklist validation
source hooks/checks/checklist.sh
if ! check_checklist; then
  ((WARNINGS++))
fi

# 2. TODO check
source hooks/checks/todo.sh
if ! check_todos; then
  ((WARNINGS++))
fi

# 3. Test execution
source hooks/checks/tests.sh
if ! run_tests; then
  ((ERRORS++))
fi

# 4. Lint check
source hooks/checks/lint.sh
if ! run_lint; then
  ((ERRORS++))
fi

# 5. Secrets detection
source hooks/checks/secrets.sh
if ! check_secrets; then
  ((ERRORS++))
fi

echo "═══════════════════════════"

if [ $ERRORS -gt 0 ]; then
  echo -e "${RED}❌ Commit blocked. Please fix the errors above.${NC}"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo -e "${YELLOW}⚠️ Warnings found, but proceeding with commit.${NC}"
  exit 0
else
  echo -e "${GREEN}All checks passed! Proceeding with commit.${NC}"
  exit 0
fi
```

## Claude Code settings.json Integration

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["hooks/pre-commit-quality.sh"]
      }
    ]
  }
}
```

## Extensibility

- **husky Integration**: Integrate with husky for Node.js projects
- **Commit Message Validation**: Check conventional commits format
- **Branch Protection**: Prevent direct commits to specific branches
- **File Size Limit**: Prevent committing large files
