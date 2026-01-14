# Claude Skills: Plan & Implement

Reusable feature planning and implementation skills for Claude Code.

## Skills Overview

| Skill | Description | Trigger Example |
|-------|-------------|-----------------|
| **plan-feature** | Q&A-based phase-by-phase design document generation | "Design an auth feature" |
| **init-impl** | Generate checklists and commands from design docs | "Prepare to implement auth" |

## Quick Start

### Installation

```bash
# Git Clone
git clone https://github.com/Canto87/claude-skills.git /tmp/claude-skills
cp -r /tmp/claude-skills/skills/* .claude/skills/
rm -rf /tmp/claude-skills

# Edit each skill's config.yaml for your project
```

### Auto-Configuration (Recommended)

After installation, ask Claude:

```
"Configure claude-skills for this project"
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
Idea
    ↓
[plan-feature] Gather requirements via Q&A
    ↓
📁 docs/plans/{feature}/
├── 00_OVERVIEW.md     # Overall overview
├── 01_PHASE1.md       # Phase 1 details
└── ...
    ↓
[init-impl] Parse design documents
    ↓
📁 docs/checklists/{feature}.md      # Checklist
📁 .claude/commands/{feature}/       # Slash commands
├── status.md    → /status
├── phase1.md    → /phase1
└── ...
    ↓
Start implementation with /phase1!
```

## Independent Skill Structure

Each skill is completely independent:

```
.claude/skills/
├── plan-feature/
│   ├── SKILL.md           # Skill definition
│   ├── config.yaml        # Skill-specific config
│   ├── questions.md       # Q&A template
│   └── templates/
│
└── init-impl/
    ├── SKILL.md           # Skill definition
    ├── config.yaml        # Skill-specific config
    └── templates/
```

- One folder = one complete skill
- Clean skill addition/removal
- No config conflicts

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

For detailed configuration: [docs/CONFIGURATION.md](docs/CONFIGURATION.md)

## Contributing

PRs welcome!

## License

MIT
