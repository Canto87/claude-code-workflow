---
name: init-impl
description: Analyze design documents to auto-generate checklists and slash commands. Use for implementation system initialization, preparation, or "prepare to implement" requests.
---

# Implementation System Generator

Analyzes design documents (`{plans_path}/{feature}/`) to automatically generate checklists and slash commands.

## When to Use

- "Prepare to implement XX"
- "Create implementation system from docs/plans/YY"
- "Let's start implementing ZZ"
- When setup is needed after design documents are ready

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
├── status.md                             # → /status (project:{feature})
├── phase1.md                             # → /phase1 (project:{feature})
└── ...
```

Templates:
- [templates/checklist.md](templates/checklist.md) - Checklist template
- [templates/status.md](templates/status.md) - status command template
- [templates/phase.md](templates/phase.md) - phase command template

## Naming Rules

| Original Folder | Commands Folder | Checklist |
|-----------------|-----------------|-----------|
| `user_auth` | `user-auth/` | `user-auth.md` |
| `payment_system` | `payment-system/` | `payment-system.md` |

Rules:
- Folder name: underscore (`_`) → hyphen (`-`)
- Checklist: use converted name as-is

## CLAUDE.md Update (Optional)

If project has CLAUDE.md, add to slash commands section:

```markdown
### {Feature Name} (project:{feature})
- `/status` - Check progress
- `/phase1` ~ `/phaseN` - Implement each Phase

> Checklist: `{checklists_path}/{feature}.md`
> Design docs: `{plans_path}/{feature}/`
```

## Completion Output

```
## Implementation System Generated

### Generated Files
- `{checklists_path}/{feature}.md` - Checklist
- `{commands_path}/{feature}/` - Commands folder
  - `status.md` → /status (project:{feature})
  - `phase1.md` ~ `phaseN.md` → /phase1~N (project:{feature})

### Usage
- `/status` (project:{feature}) - Check current progress
- `/phase1` (project:{feature}) - Start Phase 1 implementation

### Next Steps
Start Phase 1 implementation with `/phase1`!
```
