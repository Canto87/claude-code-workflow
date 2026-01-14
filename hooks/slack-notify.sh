#!/bin/bash
# slack-notify.sh - Send Slack notification on skill completion
# Triggered by PostToolUse hook when Skill tool is used

set -euo pipefail

# Read hook input from stdin
input=$(cat)

# Extract skill name from tool_input
skill_name=$(echo "$input" | jq -r '.tool_input.skill // empty')

# Exit silently if no skill name
if [[ -z "$skill_name" ]]; then
    exit 0
fi

# Target skills to notify (direct match or pattern)
# - plan-feature: Feature design completion
# - init-impl: Implementation system generation
# - *:phase*: Phase command completion (e.g., scratch-pack-system:phase1)
is_target_skill=false

case "$skill_name" in
    "plan-feature"|"init-impl")
        is_target_skill=true
        ;;
    *:phase*)
        is_target_skill=true
        ;;
esac

if [[ "$is_target_skill" != "true" ]]; then
    exit 0
fi

# Load config from skill directory
CONFIG_FILE="$(pwd)/.claude/skills/slack-notify/config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    # Fallback to user-level config
    CONFIG_FILE="$HOME/.claude/skills/slack-notify/config.yaml"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    exit 0
fi

# Parse config (simple grep-based parsing for portability)
WEBHOOK_URL=$(grep -E '^webhook_url:' "$CONFIG_FILE" | sed 's/^webhook_url:[[:space:]]*//' | tr -d '"' | tr -d "'")
CHANNEL=$(grep -E '^channel:' "$CONFIG_FILE" | sed 's/^channel:[[:space:]]*//' | tr -d '"' | tr -d "'")

# Exit if no webhook URL configured
if [[ -z "$WEBHOOK_URL" || "$WEBHOOK_URL" == "https://hooks.slack.com/services/YOUR/WEBHOOK/URL" ]]; then
    exit 0
fi

# Extract context from hook input
cwd=$(echo "$input" | jq -r '.cwd // empty')
tool_output=$(echo "$input" | jq -r '.tool_output // empty' | head -c 1000)
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
project_name=$(basename "$cwd")

# Determine message format based on skill
case "$skill_name" in
    "plan-feature")
        title="Feature Design Complete"
        icon=":clipboard:"
        color="#36a64f"

        # Try to extract feature name from output
        feature_name=$(echo "$tool_output" | grep -oE 'docs/plans/[^/]+' | head -1 | sed 's|docs/plans/||' || echo "unknown")

        body="Feature planning is complete.\n\n*Generated Files:*\n- \`docs/plans/${feature_name}/00_OVERVIEW.md\`\n- Phase documents\n\n*Next Step:* Run \`init-impl\` skill"
        ;;

    "init-impl")
        title="Implementation System Ready"
        icon=":hammer_and_wrench:"
        color="#4a90d9"

        # Try to extract feature name from output
        feature_name=$(echo "$tool_output" | grep -oE 'docs/checklists/[^.]+' | head -1 | sed 's|docs/checklists/||' || echo "unknown")

        body="Implementation system is ready.\n\n*Generated Files:*\n- \`docs/checklists/${feature_name}.md\`\n- \`.claude/commands/${feature_name}/\`\n\n*Next Step:* Start with \`/phase1\` command"
        ;;

    *:phase*)
        # Extract phase number and feature name
        phase_num=$(echo "$skill_name" | grep -oE 'phase[0-9]+' | grep -oE '[0-9]+')
        feature_name=$(echo "$skill_name" | sed 's/:phase.*//')
        next_phase=$((phase_num + 1))

        title="Phase ${phase_num} Complete"
        icon=":white_check_mark:"
        color="#2eb886"

        body="Phase ${phase_num} of *${feature_name}* is complete.\n\n*Checklist:* \`docs/checklists/${feature_name}.md\`\n\n*Next Step:* Continue with \`/phase${next_phase}\`"
        ;;

    *)
        exit 0
        ;;
esac

# Build Slack payload
payload=$(jq -n \
    --arg channel "$CHANNEL" \
    --arg icon "$icon" \
    --arg title "$title" \
    --arg skill "$skill_name" \
    --arg time "$timestamp" \
    --arg project "$project_name" \
    --arg body "$body" \
    --arg color "$color" \
    '{
        channel: $channel,
        username: "Claude Code",
        icon_emoji: $icon,
        attachments: [
            {
                color: $color,
                title: $title,
                text: $body,
                fields: [
                    {title: "Skill", value: $skill, short: true},
                    {title: "Project", value: $project, short: true},
                    {title: "Time", value: $time, short: true}
                ],
                footer: "Claude Code Notification",
                mrkdwn_in: ["text", "fields"]
            }
        ]
    }')

# Send to Slack (silent failure to not disrupt Claude Code)
curl -s -X POST -H 'Content-type: application/json' \
    --data "$payload" \
    "$WEBHOOK_URL" > /dev/null 2>&1 || true

exit 0
