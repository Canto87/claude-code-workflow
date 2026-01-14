# Hooks Configuration Guide

Claude Code hooks allow automatic triggering of scripts when specific events occur.

## Available Hooks

| Hook | Script | Description |
|------|--------|-------------|
| `slack-notify.sh` | Stop | Sends Slack notifications when session ends (after skills complete) |

## Setup

### 1. Create Slack Incoming Webhook

1. Go to https://api.slack.com/messaging/webhooks
2. Create a new webhook for your workspace
3. Select the target channel
4. Copy the webhook URL

### 2. Configure slack-notify

Edit `.claude/skills/slack-notify/config.yaml`:

```yaml
webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
channel: "#your-channel"

target_skills:
  - "plan-feature"
  - "init-impl"
  - pattern: "*:phase*"
```

### 3. Register Hook

Add to your project's `.claude/settings.local.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/slack-notify.sh"
          }
        ]
      }
    ]
  }
}
```

Or for user-level (all projects), add to `~/.claude/settings.json`.

**Note:** Stop hook triggers when the session ends, so notifications are sent after all skills complete.

## Monitored Skills

The `slack-notify.sh` hook monitors these skills:

| Skill | Message |
|-------|---------|
| `plan-feature` | Feature Design Complete |
| `init-impl` | Implementation System Ready |
| `*:phase*` | Phase N Complete |

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

Next Step: Continue with `/phase{N+1}`
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No notifications | Check webhook_url in config.yaml |
| Wrong channel | Verify channel matches webhook setup |
| Permission denied | Run `chmod +x .claude/hooks/slack-notify.sh` |
| Script not found | Check path in settings.local.json |

## Dependencies

- `jq`: JSON parsing (macOS default, install on Linux)
- `curl`: HTTP requests (default)

## Custom Hooks

To create your own hook:

1. Create script in `.claude/hooks/`
2. Make executable: `chmod +x .claude/hooks/your-script.sh`
3. Register in `settings.local.json`

**Stop hook** scripts receive JSON input via stdin with:
- `transcript_path`: Path to session transcript file
- `cwd`: Current working directory

Example:
```bash
#!/bin/bash
input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path')
# Parse transcript to find executed skills
```

## Debug Logging

The slack-notify.sh script logs to `/tmp/slack-notify-debug.log` for troubleshooting.
