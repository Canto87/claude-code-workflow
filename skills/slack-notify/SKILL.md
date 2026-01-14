---
name: slack-notify
description: Send Slack notifications on skill completion. Auto-triggered via PostToolUse hooks.
allowed-tools:
  - Bash
  - Read
---

# Slack Notification Skill

Sends Slack channel notifications when Claude Code skills (plan-feature, init-impl, phase commands) complete.

## When to Use

This skill is primarily **auto-triggered** by PostToolUse hooks:

- When `plan-feature` skill completes
- When `init-impl` skill completes
- When `/phase{N}` commands complete

Can also be used manually for testing or verifying setup.

## Prerequisites

1. **Create Slack Incoming Webhook**
   - Create at https://api.slack.com/messaging/webhooks
   - Select target channel

2. **Configure config.yaml**
   - `webhook_url`: Replace with actual Webhook URL
   - `channel`: Target channel name

3. **Register Hooks**
   - Add PostToolUse hook to `.claude/settings.local.json`

## Configuration

Settings in `config.yaml`:

```yaml
# Webhook URL (required)
webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Target channel
channel: "#claude-notifications"

# Skills to monitor
target_skills:
  - "plan-feature"
  - "init-impl"
  - pattern: "*:phase*"
```

## Monitored Skills

| Skill | Trigger Condition | Notification Content |
|-------|-------------------|---------------------|
| `plan-feature` | Design document generation complete | Generated files list, next step guidance |
| `init-impl` | Implementation system generation complete | Checklist, command list, next step guidance |
| `/phase{N}` | Phase implementation complete | Completed phase number, next phase guidance |

## Message Format

### plan-feature Completion

```
:clipboard: Feature Design Complete

Feature planning is complete.

Generated Files:
- docs/plans/{feature}/00_OVERVIEW.md
- Phase documents

Next Step: Run `init-impl` skill
```

### init-impl Completion

```
:hammer_and_wrench: Implementation System Ready

Implementation system is ready.

Generated Files:
- docs/checklists/{feature}.md
- .claude/commands/{feature}/

Next Step: Start with `/phase1` command
```

### Phase Completion

```
:white_check_mark: Phase {N} Complete

Phase {N} of {feature} is complete.

Checklist: docs/checklists/{feature}.md

Next Step: Continue with `/phase{N+1}`
```

## Setup Verification

To verify setup is correct:

1. Check that `webhook_url` in `config.yaml` is a real URL
2. Verify hooks are registered in `.claude/settings.local.json`
3. Run `plan-feature` or `init-impl` skill to confirm notification receipt

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No notifications | Verify webhook_url is correct |
| Wrong channel | Ensure config.yaml channel matches webhook setup |
| Specific skill not notifying | Check if skill is included in target_skills |
| Script error | Debug with `bash -x .claude/hooks/slack-notify.sh` |

## Dependencies

- `jq`: JSON parsing (included by default on macOS)
- `curl`: HTTP requests (included by default)

## Architecture

```
PostToolUse Hook (matcher: "Skill")
    |
    v
slack-notify.sh
    |
    +-- Check skill name (plan-feature, init-impl, *:phase*)
    |
    +-- Read config.yaml (webhook_url, channel)
    |
    +-- Format message
    |
    v
Slack Webhook API
```

## Related Skills

- `plan-feature`: Generate feature design documents
- `init-impl`: Generate implementation system
- `implement-layer`: Implement Clean Architecture layers
