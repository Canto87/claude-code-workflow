# Claude Code Workflow

Reusable feature planning and implementation skills for Claude Code.

## Skills Overview

| Skill | Description | Trigger Example |
|-------|-------------|-----------------|
| **plan-feature** | Q&A-based phase-by-phase design document generation | "Design an auth feature" |
| **init-impl** | Generate checklists and commands from design docs | "Prepare to implement auth" |
| **health-check** | Diagnose project configuration and suggest optimizations | "Check project health" |
| **status** | Display implementation progress dashboard | `/status user-auth` |
| **review** | Review completed phases for quality and consistency | `/review user-auth phase-2` |
| **generate-docs** | Generate API docs, changelog, architecture diagrams | `/generate-docs user-auth` |
| **slack-notify** | Slack notification configuration (built into each skill) | Configure `webhook_url` only |
| **worktree** | Git worktree management for parallel branch development | `/worktree-add feature/auth` |

## Quick Start

### Installation

**Full Installation (Recommended)**
```bash
# One-liner: Install all skills
curl -fsSL https://raw.githubusercontent.com/Canto87/claude-code-workflow/main/install.sh | bash
```

**Selective Installation**
```bash
# Install specific skills only
curl -fsSL https://raw.githubusercontent.com/Canto87/claude-code-workflow/main/install.sh | bash -s -- --skills=plan-feature,init-impl

# List available skills
curl -fsSL https://raw.githubusercontent.com/Canto87/claude-code-workflow/main/install.sh | bash -s -- --list

# Interactive selection menu
curl -fsSL https://raw.githubusercontent.com/Canto87/claude-code-workflow/main/install.sh | bash -s -- --interactive
```

**Manual Installation**
```bash
# Git Clone
git clone https://github.com/Canto87/claude-code-workflow.git /tmp/claude-code-workflow

# Copy specific skills (always include _shared)
cp -r /tmp/claude-code-workflow/skills/_shared .claude/skills/
cp -r /tmp/claude-code-workflow/skills/plan-feature .claude/skills/
cp -r /tmp/claude-code-workflow/skills/init-impl .claude/skills/

# Cleanup
rm -rf /tmp/claude-code-workflow
```

**Available Skills:**
| Skill | Description |
|-------|-------------|
| `_shared` | Shared templates (always required) |
| `plan-feature` | Q&A-based design document generation |
| `init-impl` | Generate checklists and commands |
| `health-check` | Diagnose project configuration |
| `status` | Display implementation progress dashboard |
| `review` | Code quality review agent |
| `generate-docs` | Auto documentation generator |
| `slack-notify` | Slack notification configuration |
| `worktree` | Git worktree management |

### Auto-Configuration (Recommended)

After installation, ask Claude:

```
"Configure claude-code-workflow for this project"
```

Claude will analyze your project structure and update config.yaml files automatically.

### Manual Configuration

Edit `config.yaml` in each skill folder for your project:

**plan-feature/config.yaml:**
```yaml
project:
  name: "my-project"
  language: go

paths:
  source: "internal"
  plans: "docs/plans"

integrations:
  - label: "Database"
    path: "internal/database"
```

**init-impl/config.yaml:**
```yaml
paths:
  plans: "docs/plans"
  checklists: "docs/checklists"
  commands: ".claude/commands"

build:
  command: "go build ./..."
  test: "go test ./..."
```

### Usage

Ask Claude:

```
"Design a user authentication feature"
```

→ Creates design documents in `docs/plans/user_auth/`

```
"Prepare to implement user auth"
```

→ Creates `docs/checklists/user-auth.md` + `.claude/commands/user-auth/`

## Workflow

```
[health-check] Verify project setup (optional)
    ↓
Idea
    ↓
[plan-feature] Gather requirements via Q&A
    ↓                              ┌─────────────────┐
📁 docs/plans/{feature}/           │  Slack notify   │
├── 00_OVERVIEW.md                 │  (built-in)     │
├── 01_PHASE1.md                   └─────────────────┘
└── ...
    ↓
[init-impl] Parse design documents
    ↓
📁 docs/checklists/{feature}.md      # Checklist
📁 .claude/commands/{feature}/       # Slash commands
├── phase1.md    → /phase1
└── ...
    ↓
Implementation with /phase1, /phase2, ...
    ↓
[status] Check progress             # /status {feature}
    ↓
[review] Quality review per phase   # /review {feature} phase-N
    ↓
[generate-docs] Auto-generate docs  # /generate-docs {feature}
    ↓
Done! 🎉
```

## Independent Skill Structure

Each skill is completely independent:

```
.claude/skills/
├── _shared/
│   └── notify.md              # Shared notification templates
│
├── plan-feature/
│   ├── SKILL.md               # Skill definition
│   ├── config.yaml            # Skill-specific config
│   ├── questions.md           # Q&A template
│   └── templates/
│
├── init-impl/
│   ├── SKILL.md               # Skill definition
│   ├── config.yaml            # Skill-specific config
│   └── templates/
│
├── health-check/
│   ├── SKILL.md               # Skill definition
│   ├── config.yaml            # Check rules config
│   └── templates/
│
├── status/
│   ├── SKILL.md               # Skill definition
│   ├── config.yaml            # Display settings
│   └── templates/
│
├── review/
│   ├── SKILL.md               # Skill definition
│   ├── config.yaml            # Review categories
│   └── templates/
│
├── generate-docs/
│   ├── SKILL.md               # Skill definition
│   ├── config.yaml            # Generator settings
│   └── templates/
│
├── slack-notify/
│   ├── SKILL.md               # Configuration guide
│   └── config.yaml            # webhook_url only
│
└── worktree/
    ├── SKILL.md               # Skill definition
    ├── config.yaml            # Worktree settings
    └── README.md              # Quick reference

.claude/hooks/
└── pre-commit-quality.sh      # Pre-commit quality checks
```

- One folder = one complete skill
- Clean skill addition/removal
- No config conflicts
- Slack notifications are built into each skill (no hook needed)

## Configuration Options

### plan-feature

| Option | Description | Default |
|--------|-------------|---------|
| `project.language` | Programming language | `other` |
| `paths.source` | Source code path | `src` |
| `paths.plans` | Design docs output path | `docs/plans` |
| `integrations` | Available system integrations | `[]` |
| `storage` | Storage options | SQLite, etc. |

### init-impl

| Option | Description | Default |
|--------|-------------|---------|
| `paths.plans` | Design docs input path | `docs/plans` |
| `paths.checklists` | Checklist output path | `docs/checklists` |
| `paths.commands` | Commands output path | `.claude/commands` |
| `build.command` | Build command | - |
| `build.test` | Test command | - |

### health-check

| Option | Description | Default |
|--------|-------------|---------|
| `checks.required_files` | Required files list with severity | `.claude/settings.json`, etc. |
| `checks.required_dirs` | Required directories list | `.claude/commands`, etc. |
| `checks.settings.validate_json` | Validate JSON syntax | `true` |
| `checks.hooks.executable` | Check hook file permissions | `true` |
| `report.show_passing` | Show passing checks | `true` |

### status

| Option | Description | Default |
|--------|-------------|---------|
| `paths.plans` | Design docs path | `docs/plans` |
| `paths.checklist_file` | Checklist filename | `checklist.md` |
| `display.progress_bar.width` | Progress bar width | `20` |
| `feature_detection.auto_detect` | Auto-detect current feature | `true` |
| `overview.sort_by` | Sort order | `last_updated` |

### review

| Option | Description | Default |
|--------|-------------|---------|
| `categories.*.enabled` | Enable per category | `true` |
| `categories.*.weight` | Score weight (%) | varies |
| `focus_modes` | Focus mode definitions | `quality`, `security`, etc. |
| `report.show_code_snippets` | Show code snippets | `true` |

### generate-docs

| Option | Description | Default |
|--------|-------------|---------|
| `output.base_path` | Documentation output path | `docs` |
| `output.changelog` | Changelog file path | `CHANGELOG.md` |
| `generators.*.enabled` | Enable per generator | `true` |
| `mermaid.theme` | Mermaid diagram theme | `default` |

### slack-notify

| Option | Description | Default |
|--------|-------------|---------|
| `webhook_url` | Slack Incoming Webhook URL | - (required) |
| `channel` | Target Slack channel (informational) | `#claude-notifications` |

> **Note:** Notifications are now built into each skill. Just configure `webhook_url` - no hooks or `target_skills` needed.

### worktree

| Option | Description | Default |
|--------|-------------|---------|
| `worktree.base_dir` | Base directory for new worktrees | `..` |
| `worktree.naming_pattern` | Directory naming pattern | `{branch}` |
| `branch.default_base` | Default base branch for new branches | `main` |
| `safety.confirm_remove` | Require confirmation before removing | `true` |
| `safety.check_uncommitted` | Check for uncommitted changes | `true` |

**Subcommands:**

| Command | Description |
|---------|-------------|
| `/worktree-list` | List all worktrees with status |
| `/worktree-add [branch]` | Create worktree for branch |
| `/worktree-add -b [new]` | Create new branch and worktree |
| `/worktree-remove [path]` | Remove worktree safely |
| `/worktree-info` | Show current worktree info |
| `/worktree-switch [path]` | Switch to another worktree |

**Pre-commit Hook (Optional):**

Add to `.claude/settings.local.json` for quality checks before commits:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-commit-quality.sh \"$TOOL_INPUT\""
          }
        ]
      }
    ]
  }
}
```

For detailed configuration: [docs/CONFIGURATION.md](docs/CONFIGURATION.md)
For hooks setup: [docs/HOOKS.md](docs/HOOKS.md)

## Contributing

PRs welcome!

## License

MIT
