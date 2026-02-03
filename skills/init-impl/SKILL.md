---
name: init-impl
description: Analyze design documents to auto-generate checklists and slash commands. Also supports cleanup mode to remove generated files after implementation is complete.
allowed-tools: Read, Write, Glob, Bash, AskUserQuestion
---

# Implementation System Generator

Analyzes design documents (`{plans_path}/{feature}/`) to automatically generate checklists and slash commands.

## When to Use

**Generate mode (default):**
- "Prepare to implement XX"
- "Create implementation system from docs/plans/YY"
- "Let's start implementing ZZ"
- When setup is needed after design documents are ready

**Cleanup mode:**
- "Clean up user-auth implementation"
- "Remove implementation commands for payment"
- "Implementation done, cleanup user-auth"
- After implementation is complete and commands are no longer needed

## Configuration File

Skill settings are managed in `config.yaml` in the same folder.

```yaml
# config.yaml example
paths:
  plans: "docs/plans"              # Design docs path
  checklists: "docs/checklists"    # Checklist output path
  commands: ".claude/commands"     # Commands output path
```

## Execution Flow

```
1. Check Config       → Read config.yaml (use defaults if missing)
       ↓
2. Verify Target      → Check 00_OVERVIEW.md, 0N_*.md exist
       ↓
3. Parse OVERVIEW     → Extract Phase list, difficulty, impact
       ↓
4. Parse Phase Docs   → Extract checklists, test methods
       ↓
5. Generate Files     → Checklist + commands folder
       ↓
6. (Optional) Update CLAUDE.md
```

## Required File Check

```bash
ls {plans_path}/{feature_name}/
# Required: 00_OVERVIEW.md
# Required: 01_*.md ~ 0N_*.md (Phase documents)
```

## Output

```
{checklists_path}/{feature}.md            # Checklist
{commands_path}/{feature}/                # Commands folder
├── {feature}-status.md                   # → /{feature}-status
├── {feature}-phase1.md                   # → /{feature}-phase1
└── ...
```

Templates:
- [templates/checklist.md](templates/checklist.md) - Checklist template
- [templates/status.md](templates/status.md) - status command template
- [templates/phase.md](templates/phase.md) - phase command template

## Naming Rules

| Original Folder | Commands Folder | Command Files | Checklist |
|-----------------|-----------------|---------------|-----------|
| `user_auth` | `user-auth/` | `user-auth-status.md`, `user-auth-phase1.md` | `user-auth.md` |
| `payment_system` | `payment-system/` | `payment-system-status.md`, `payment-system-phase1.md` | `payment-system.md` |

Rules:
- Folder name: underscore (`_`) → hyphen (`-`)
- Command files: `{feature}-status.md`, `{feature}-phase1.md`, ...
- Checklist: use converted name as-is

## CLAUDE.md Update (Optional)

If project has CLAUDE.md, add to slash commands section:

```markdown
### {Feature Name}
- `/{feature}-status` - Check progress
- `/{feature}-phase1` ~ `/{feature}-phaseN` - Implement each Phase

> Checklist: `{checklists_path}/{feature}.md`
> Design docs: `{plans_path}/{feature}/`
```

## Completion Output (Generate)

```
## Implementation System Generated

### Generated Files
- `{checklists_path}/{feature}.md` - Checklist
- `{commands_path}/{feature}/` - Commands folder
  - `{feature}-status.md` → /{feature}-status
  - `{feature}-phase1.md` ~ `{feature}-phaseN.md` → /{feature}-phase1~N

### Usage
- `/{feature}-status` - Check current progress
- `/{feature}-phase1` - Start Phase 1 implementation

### Next Steps
Start Phase 1 implementation with `/{feature}-phase1`!
```

---

## Cleanup Execution Flow

```
1. Identify Target     → Parse feature name from request
       ↓
2. Verify Files Exist  → Check commands folder and checklist exist
       ↓
3. Confirm with User   → List files to be deleted, ask confirmation
       ↓
4. Delete Files        → Remove commands folder and checklist
       ↓
5. (Optional) Update CLAUDE.md → Remove slash command references
```

## Completion Output (Cleanup)

```
## Implementation Cleanup Complete

### Deleted Files
- `{commands_path}/{feature}/` - Commands folder removed
- `{checklists_path}/{feature}.md` - Checklist removed

### Notes
- Design documents in `{plans_path}/{feature}/` preserved
- Re-run init-impl if you need to regenerate commands
```

## On Completion (Slack Notification)

After successful generation, send Slack notification if configured:

1. **Check webhook configuration:**
   ```bash
   WEBHOOK=$(grep 'webhook_url:' skills/slack-notify/config.yaml 2>/dev/null | sed 's/.*"\(.*\)"/\1/')
   ```

2. **If webhook is configured** (not empty and doesn't contain "YOUR"):
   ```bash
   curl -s -X POST "$WEBHOOK" \
     -H "Content-Type: application/json" \
     -d '{
       "blocks": [
         {"type": "header", "text": {"type": "plain_text", "text": "🔧 Implementation System Ready", "emoji": true}},
         {"type": "section", "text": {"type": "mrkdwn", "text": "Checklist and commands for *{feature_name}* are ready."}},
         {"type": "section", "fields": [
           {"type": "mrkdwn", "text": "*Feature:*\n{feature_name}"},
           {"type": "mrkdwn", "text": "*Commands:*\n/{feature}-phase1 ~ /{feature}-phaseN"}
         ]},
         {"type": "context", "elements": [{"type": "mrkdwn", "text": "Next: Start with `/{feature}-phase1`"}]}
       ]
     }' > /dev/null 2>&1 || true
   ```

3. **Continue with normal completion output** (notification failure should not block)

## Related Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `/plan-feature` | Generate design documents | Before init-impl, create the design docs |
| `/status` | Check implementation progress | During implementation to track completion |
| `/review` | Quality review | After completing each phase |
| `/generate-docs` | Auto-generate documentation | After all phases are complete |
| `/health-check` | Project setup verification | If experiencing issues |

---

## Next Steps: Automated Implementation

After init-impl generates checklists and commands, you have two options:

### Option 1: Manual Implementation (Default)
Implement each phase manually using the generated slash commands:
```
/{feature}-phase1  →  /{feature}-phase2  →  ...
```

### Option 2: Automated QA Pipeline (Advanced)
If you have agents installed (`./install.sh --with-supervisor`), use the supervisor skill for automated implementation with quality gates:

```
/supervisor {feature} phase1
```

This runs:
1. **IMPLEMENT** - auto-impl agent executes Phase tasks via code-edit
2. **REVIEW** - code-review agent evaluates code quality (7+ to pass)
3. **VALIDATE** - validate agent checks Acceptance Criteria (7+ to pass)

See [docs/AGENTS.md](../../docs/AGENTS.md) for more information.
