# Hooks Configuration Guide

Claude Code hooks allow automatic triggering of scripts when specific events occur.

## Available Hooks

| Hook | Script | Description |
|------|--------|-------------|
| `pre-commit-quality.sh` | Pre-commit | Quality checks before git commits |

## Pre-commit Quality Hook

The `pre-commit-quality.sh` hook runs quality checks before each commit:

### Checks Performed

| Check | Description |
|-------|-------------|
| Checklist completion | Warns if committing incomplete checklist items |
| TODO/FIXME comments | Warns about TODO comments in code |
| Secrets detection | Blocks commits with potential secrets |
| Large files | Warns about files > 1MB |
| Linter | Runs appropriate linter (golangci-lint, eslint, ruff) |
| Test files | Warns if new code lacks corresponding tests |

### Installation

```bash
# Copy to git hooks directory
cp hooks/pre-commit-quality.sh .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit
```

Or create a symlink:

```bash
ln -s ../../hooks/pre-commit-quality.sh .git/hooks/pre-commit
```

### Output Example

```
🔍 Running pre-commit quality checks...

📋 Checking checklist completion...
  ✓ docs/checklists/user-auth.md - all items complete

📝 Checking for TODO/FIXME comments...
  ✓ No TODO/FIXME comments found

🔐 Checking for potential secrets...
  ✓ No obvious secrets detected

📦 Checking for large files...
  ✓ No large files detected

🧹 Running linter...
  ✓ Go linter passed

🧪 Checking for corresponding tests...
  ✓ Test coverage looks good

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All checks passed!
```

### Behavior

- **Errors (🔴)**: Block commit, must fix
- **Warnings (⚠️)**: Allow commit, recommend fixing

## Slack Notifications

**Note:** Slack notifications are now built into each skill, not using hooks.

See `skills/slack-notify/SKILL.md` for configuration.

Quick setup:
```yaml
# skills/slack-notify/config.yaml
webhook_url: "https://hooks.slack.com/services/YOUR/ACTUAL/URL"
```

## Custom Hooks

To create your own hook:

1. Create script in `hooks/`
2. Make executable: `chmod +x hooks/your-script.sh`
3. Copy or link to `.git/hooks/`

### Hook Types

| Hook | When | Use Case |
|------|------|----------|
| pre-commit | Before commit | Validation, linting |
| commit-msg | After message entered | Message format check |
| pre-push | Before push | Run tests |
| post-commit | After commit | Notifications |

### Claude Code Hooks

Claude Code also supports its own hooks in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...]
  }
}
```

These are separate from git hooks and trigger on Claude Code events.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Hook not running | Check `chmod +x` and correct path |
| Permission denied | Run `chmod +x hooks/*.sh` |
| Hook blocking commits | Check error message, fix issues or use `--no-verify` |
