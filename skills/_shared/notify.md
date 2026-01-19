# Shared Notification Guide

This guide defines how skills should send Slack notifications on completion.

## When to Send Notifications

Send a notification when:
- Skill completes successfully
- Webhook URL is configured in `skills/slack-notify/config.yaml`

Do NOT send when:
- Skill fails or is cancelled
- Webhook URL is not configured or is placeholder
- Skill is informational only (status, health-check)

## How to Send Notification

### Step 1: Check Configuration

```bash
# Read webhook URL from config
WEBHOOK_URL=$(grep "webhook_url:" skills/slack-notify/config.yaml | sed 's/.*: *"\(.*\)"/\1/')

# Skip if not configured or placeholder
if [[ -z "$WEBHOOK_URL" || "$WEBHOOK_URL" == *"YOUR"* ]]; then
    echo "Slack notification skipped (webhook not configured)"
    exit 0
fi
```

### Step 2: Format Message

Use this JSON structure for Slack Block Kit:

```json
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "{ICON} {TITLE}",
        "emoji": true
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "{DESCRIPTION}"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Feature:*\n{FEATURE_NAME}"
        },
        {
          "type": "mrkdwn",
          "text": "*Next Step:*\n{NEXT_STEP}"
        }
      ]
    }
  ]
}
```

### Step 3: Send via curl

```bash
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  > /dev/null 2>&1 || true  # Silent failure
```

## Message Templates by Skill

### plan-feature

```
Icon: 📋
Title: Feature Design Complete
Description: Design documents for {feature} have been generated.
Fields:
  - Feature: {feature_name}
  - Phases: {phase_count}
  - Next Step: Run /init-impl
```

### init-impl

```
Icon: 🔧
Title: Implementation System Ready
Description: Checklist and commands for {feature} are ready.
Fields:
  - Feature: {feature_name}
  - Commands: /{feature}-phase1 ~ /{feature}-phaseN
  - Next Step: Start with /{feature}-phase1
```

### review

```
Icon: 🔍
Title: Review Complete
Description: {feature} {phase} review is complete.
Fields:
  - Verdict: ✅ APPROVED / ❌ NEEDS WORK
  - Issues: {error_count} errors, {warning_count} warnings
  - Next Step: {next_action}
```

### generate-docs

```
Icon: 📚
Title: Documentation Generated
Description: Documentation for {feature} has been created.
Fields:
  - Files: {file_count} generated
  - Next Step: Review and commit
```

## Inline Notification Code

For skills to copy-paste:

```markdown
## On Completion (Slack Notification)

After successful completion, send Slack notification if configured:

1. Check if webhook is configured:
   - Read `skills/slack-notify/config.yaml`
   - If `webhook_url` contains "YOUR" or is empty, skip notification

2. If configured, execute:
   ```bash
   curl -s -X POST "$(grep 'webhook_url:' skills/slack-notify/config.yaml | sed 's/.*: *\"\(.*\)\"/\1/')" \
     -H "Content-Type: application/json" \
     -d '{
       "blocks": [
         {"type": "header", "text": {"type": "plain_text", "text": "{ICON} {TITLE}", "emoji": true}},
         {"type": "section", "text": {"type": "mrkdwn", "text": "{DESCRIPTION}"}},
         {"type": "context", "elements": [{"type": "mrkdwn", "text": "Next: {NEXT_STEP}"}]}
       ]
     }' > /dev/null 2>&1 || true
   ```

3. Continue with normal completion output (notification failure should not block)
```

## Configuration Reference

Located at `skills/slack-notify/config.yaml`:

```yaml
webhook_url: "https://hooks.slack.com/services/XXX/YYY/ZZZ"
channel: "#claude-notifications"
```

Users only need to set `webhook_url` - everything else is handled by the skill.
