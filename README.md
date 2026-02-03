# Claude Code Workflow

Reusable feature planning and implementation skills for Claude Code.

## Skills Overview

| Skill | Description | Trigger Example |
|-------|-------------|-----------------|
| **plan-feature** | Q&A-based design with codebase analysis and risk assessment | "Design an auth feature" |
| **init-impl** | Generate checklists/commands from design docs + cleanup mode | "Prepare to implement auth" |
| **health-check** | Diagnose project configuration and suggest optimizations | "Check project health" |
| **status** | Display implementation progress dashboard | `/status user-auth` |
| **review** | Review completed phases for quality and consistency | `/review user-auth phase-2` |
| **generate-docs** | Generate API docs, changelog, architecture diagrams | `/generate-docs user-auth` |
| **slack-notify** | Slack notification configuration (built into each skill) | Configure `webhook_url` only |
| **worktree** | Git worktree management for parallel branch development | `/worktree-add feature/auth` |
| **supervisor** | QA pipeline orchestrator (implement → review → validate) | `/supervisor user-auth phase1` |
| **validate** | Artifact and implementation validation | `/validate user-auth phase1` |

## Quick Start

### Installation

**Full Installation (Recommended)**
```bash
# One-liner: Install all skills
curl -fsSL https://raw.githubusercontent.com/Canto87/claude-code-workflow/main/install.sh | bash
```

Options:
- `--skills=X,Y`: Install specific skills only
- `--agents`: Install all agents (advanced feature)
- `--agents=X,Y`: Install specific agents only
- `--with-supervisor`: Install skills + agents + supervisor (full QA pipeline)
- `--interactive`: Interactive selection menu
- `--yes`: Skip confirmation prompt (for CI/CD)

**Examples:**
```bash
# Install specific skills only
curl -fsSL ... | bash -s -- --skills=plan-feature,init-impl

# Install with all agents (advanced)
curl -fsSL ... | bash -s -- --agents

# Install full QA pipeline
curl -fsSL ... | bash -s -- --with-supervisor

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

# Copy agents (optional, for advanced features)
cp -r /tmp/claude-code-workflow/agents .claude/

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
| `review` | Code quality review skill |
| `generate-docs` | Auto documentation generator |
| `slack-notify` | Slack notification configuration |
| `worktree` | Git worktree management |
| `supervisor` | QA pipeline orchestrator |
| `validate` | Artifact and implementation validation |

**Available Agents (Advanced):**
| Agent | Description |
|-------|-------------|
| `code-edit` | Single-task code modification agent |
| `auto-impl` | Phase automation orchestrator |
| `validate` | Dual-mode verification agent |
| `code-analyze` | Read-only codebase analysis |
| `code-review` | Code quality evaluation agent |

### Auto-Configuration (Recommended)

After installation, ask Claude:

```
"Configure claude-code-workflow for this project"
```

Claude will analyze your project structure and update config.yaml files automatically.

## Workflow

### Simple Workflow (Skills Only)

```
[health-check] Verify project setup (optional)
    ↓
Idea
    ↓
[plan-feature] Gather requirements via Q&A
    ↓
📁 docs/plans/{feature}/
├── 00_OVERVIEW.md
├── 01_PHASE1.md
└── ...
    ↓
[init-impl] Parse design documents
    ↓
📁 docs/checklists/{feature}.md      # Checklist
📁 .claude/commands/{feature}/       # Slash commands
    ↓
Implementation with /phase1, /phase2, ...
    ↓
[status] Check progress
    ↓
[review] Quality review per phase
    ↓
[generate-docs] Auto-generate docs
    ↓
Done! 🎉
```

### Advanced Workflow (With Agents)

For larger projects needing automated QA:

```
[plan-feature] Design
    ↓
[init-impl] Setup
    ↓
[supervisor] Automated QA Pipeline
    │
    ├── IMPLEMENT (auto-impl → code-edit)
    │
    ├── REVIEW (code-review)
    │       └── Gate: Score 7+ to pass
    │
    └── VALIDATE (validate)
            └── Gate: Score 7+ to pass
    ↓
Done! 🎉
```

See [docs/AGENTS.md](docs/AGENTS.md) for the full agent system guide.

---

## Advanced: Agent System

Agents provide automated code modification, analysis, and quality assurance.

### Agent Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    SKILL LAYER                              │
│  ┌──────────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ plan-feature │  │ init-impl│  │      supervisor      │  │
│  │   (design)   │  │ (setup)  │  │  (QA orchestrator)   │  │
│  └──────────────┘  └──────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    AGENT LAYER                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────┐    │
│  │ auto-impl  │──│ code-edit  │  │    code-analyze    │    │
│  │(orchestr.) │  │ (worker)   │  │    (read-only)     │    │
│  └────────────┘  └────────────┘  └────────────────────┘    │
│  ┌────────────┐  ┌────────────┐                            │
│  │code-review │  │  validate  │                            │
│  │(evaluator) │  │(validator) │                            │
│  └────────────┘  └────────────┘                            │
└─────────────────────────────────────────────────────────────┘
```

### Supervisor Pipeline

The supervisor skill chains agents with score-based gates:

```
IMPLEMENT → REVIEW → VALIDATE
                │
         Gate: 7+ pass
         5-6: retry
         <5: reject
```

### Delegation Rules

Add to your CLAUDE.md for task routing:

| Task Type | Tool | Reason |
|-----------|------|--------|
| Code modification (3+ files) | `code-edit` agent | Context savings |
| Phase implementation | `auto-impl` agent | Orchestration |
| Documentation | Direct Write/Edit | No overhead |
| Analysis | `code-analyze` agent | Read-only |
| Quality check | `code-review` agent | Evaluation |
| Full QA | `supervisor` skill | Pipeline |

**Rule**: When modifying 3+ code files, always delegate to a subagent.

### Agent Installation

```bash
# All agents
./install.sh --agents

# Specific agents
./install.sh --agents=code-edit,code-review

# Full QA pipeline
./install.sh --with-supervisor
```

See:
- [docs/AGENTS.md](docs/AGENTS.md) - Agent system guide
- [docs/DELEGATION.md](docs/DELEGATION.md) - Task delegation rules
- [examples/advanced-workflow.md](examples/advanced-workflow.md) - Advanced usage

---

## Project Structure

```
.claude/
├── skills/
│   ├── _shared/              # Shared templates
│   ├── plan-feature/         # Design generation
│   ├── init-impl/            # Implementation setup
│   ├── health-check/         # Project diagnostics
│   ├── status/               # Progress dashboard
│   ├── review/               # Quality review
│   ├── generate-docs/        # Documentation generator
│   ├── slack-notify/         # Notifications
│   ├── worktree/             # Git worktree management
│   ├── supervisor/           # QA pipeline (advanced)
│   └── validate/             # Validation skill (advanced)
│
├── agents/                   # (with --agents flag)
│   ├── code-edit.md          # Code modification
│   ├── auto-impl.md          # Phase orchestration
│   ├── validate.md           # Verification
│   ├── code-analyze.md       # Analysis
│   └── code-review.md        # Quality evaluation
│
└── hooks/
    └── pre-commit-quality.sh # Pre-commit checks
```

## Configuration

### Quick Config

**plan-feature/config.yaml:**
```yaml
project:
  name: "my-project"
  language: go

paths:
  source: "internal"
  plans: "docs/plans"
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

**supervisor/config.yaml:** (if using agents)
```yaml
gates:
  review:
    pass_threshold: 7
    max_retries: 2
  validate:
    pass_threshold: 7
    max_retries: 1
```

For detailed configuration: [docs/CONFIGURATION.md](docs/CONFIGURATION.md)

## Documentation

| Document | Description |
|----------|-------------|
| [CONFIGURATION.md](docs/CONFIGURATION.md) | Detailed config options |
| [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) | Customizing skills |
| [HOOKS.md](docs/HOOKS.md) | Pre-commit hooks setup |
| [AGENTS.md](docs/AGENTS.md) | Agent system guide |
| [DELEGATION.md](docs/DELEGATION.md) | Task delegation rules |

## Examples

| Example | Description |
|---------|-------------|
| [settings.json](examples/settings.json) | Permissions template |
| [CLAUDE.md.example](examples/CLAUDE.md.example) | Project config template |
| [advanced-workflow.md](examples/advanced-workflow.md) | Agent workflow guide |
| [supervisor-report.md](examples/sample-output/supervisor-report.md) | Pipeline output example |

## Contributing

PRs welcome!

## License

MIT
