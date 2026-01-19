---
name: slack-notify
description: Slack notification configuration. Notifications are built into each skill - just configure webhook_url.
allowed-tools:
  - Bash
  - Read
---

# Slack Notification System

Provides Slack notifications when workflow skills complete. **Notifications are built into each skill** - no hook configuration needed.

## How It Works

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Skill runs     │────▶│  On completion  │────▶│  Slack webhook  │
│  (plan-feature) │     │  curl to Slack  │     │  notification   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌─────────────────┐
                        │  config.yaml    │
                        │  webhook_url    │
                        └─────────────────┘
```

**No hooks required!** Each skill handles its own notification.

## Quick Setup

### 1. Create Slack Webhook

1. Go to https://api.slack.com/messaging/webhooks
2. Create new webhook for your workspace
3. Select target channel
4. Copy webhook URL

### 2. Configure webhook_url

Edit `skills/slack-notify/config.yaml`:

```yaml
webhook_url: "https://hooks.slack.com/services/YOUR/ACTUAL/URL"
```

**That's it!** Skills will automatically send notifications.

## Integrated Skills

| Skill | Notification |
|-------|-------------|
| `/plan-feature` | 📋 Feature Design Complete |
| `/init-impl` | 🔧 Implementation System Ready |
| `/review` | 🔍 Review Complete |
| `/generate-docs` | 📚 Documentation Generated |

**Not notified** (informational only):
- `/status` - Progress check
- `/health-check` - Diagnostic

## Message Examples

### plan-feature

```
📋 Feature Design Complete

Design documents for user-auth have been generated.

Feature: user-auth
Phases: 4

Next: Run /init-impl to generate implementation system
```

### init-impl

```
🔧 Implementation System Ready

Checklist and commands for user-auth are ready.

Feature: user-auth
Commands: /user-auth-phase1 ~ /user-auth-phase4

Next: Start with /user-auth-phase1
```

### review

```
🔍 Review Complete

user-auth Phase 2 review is complete.

Verdict: ✅ APPROVED
Issues: 0 errors, 2 warnings

Next: Proceed to Phase 3
```

### generate-docs

```
📚 Documentation Generated

Documentation for user-auth has been created.

Files: 5 generated
Types: API, Models, Architecture

Next: Review and commit documentation
```

## Configuration

`config.yaml` settings:

```yaml
# Required: Your Slack webhook URL
webhook_url: "https://hooks.slack.com/services/XXX/YYY/ZZZ"

# Optional: Target channel (informational, set in webhook)
channel: "#claude-notifications"
```

## Disabling Notifications

To disable notifications:

1. **Remove or comment out webhook_url:**
   ```yaml
   # webhook_url: "https://hooks.slack.com/..."
   ```

2. **Or set to placeholder:**
   ```yaml
   webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
   ```

Skills check for "YOUR" in URL and skip notification.

## Manual Testing

Test notification manually:

```bash
curl -s -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "blocks": [
      {"type": "header", "text": {"type": "plain_text", "text": "🧪 Test Notification", "emoji": true}},
      {"type": "section", "text": {"type": "mrkdwn", "text": "Slack notifications are working!"}}
    ]
  }'
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No notifications | Check webhook_url in config.yaml |
| Wrong channel | Webhook URL determines channel - create new webhook for different channel |
| Notification fails silently | By design - failures don't block skill completion |

## Technical Details

Each skill includes this pattern in "On Completion" section:

```bash
# Check webhook configuration
WEBHOOK=$(grep 'webhook_url:' skills/slack-notify/config.yaml 2>/dev/null | sed 's/.*"\(.*\)"/\1/')

# Skip if not configured
if [[ -z "$WEBHOOK" || "$WEBHOOK" == *"YOUR"* ]]; then
    # No notification
    exit 0
fi

# Send notification (silent failure)
curl -s -X POST "$WEBHOOK" ... > /dev/null 2>&1 || true
```

## Extending to Custom Skills

Add notification to your custom skill:

1. Add `Bash` to `allowed-tools` in SKILL.md
2. Add "On Completion" section (copy pattern from plan-feature)
3. Customize message blocks for your skill

See `skills/_shared/notify.md` for templates.
