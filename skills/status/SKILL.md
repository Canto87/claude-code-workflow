---
name: status
description: Display implementation progress dashboard for features. Use to track checklist completion and phase progress.
allowed-tools: Read, Glob
---

# Status Skill

Displays implementation progress by parsing checklist.md files and visualizing completion status.

## When to Use

- Check progress on current feature implementation
- Get overview of all active features
- Find what task to work on next
- Report progress to team

## Usage

```bash
# Current feature status (auto-detect from current directory)
> /status

# Specific feature status
> /status user-auth

# All features overview
> /status --all
```

## Configuration File

Skill settings are managed in `config.yaml` in the same folder.

## Execution Flow

```
1. Load Config           → Read config.yaml for paths
       ↓
2. Find Checklists       → Glob for checklist.md files
       ↓
3. Parse Checkboxes      → Extract [ ] and [x] items
       ↓
4. Calculate Progress    → Compute percentages per phase
       ↓
5. Identify Current      → Find in-progress phase
       ↓
6. Generate Dashboard    → Output formatted status
```

## Data Source

### checklist.md Format

```markdown
## Phase 1: Basic Auth
- [x] Create user model
- [x] Implement signup API
- [ ] Add login endpoint
- [ ] Write unit tests

## Phase 2: JWT Management
- [ ] Generate access token
- [ ] Implement refresh logic
```

### Parsing Rules

| Pattern | Meaning |
|---------|---------|
| `## Phase N:` | Phase header |
| `- [x]` | Completed task |
| `- [ ]` | Pending task |
| `### Subtask` | Nested section (counts toward parent) |

## Output Format

### Single Feature Status

```
## 📊 Implementation Status: user-auth

### Overall Progress
████████████░░░░░░░░ 60% (12/20 tasks)

### Phase Breakdown

| Phase | Progress | Tasks | Status |
|-------|----------|-------|--------|
| Phase 1: Basic Auth | ████████████████████ 100% | 6/6 | ✅ Done |
| Phase 2: JWT | ████████████░░░░░░░░ 60% | 3/5 | 🔄 Active |
| Phase 3: Session | ░░░░░░░░░░░░░░░░░░░░ 0% | 0/5 | ⏳ Pending |
| Phase 4: Social | ░░░░░░░░░░░░░░░░░░░░ 0% | 0/4 | ⏳ Pending |

### Current Focus
🔄 **Phase 2: JWT Management**
   - [x] Generate access token
   - [x] Implement refresh logic
   - [x] Token validation
   - [ ] Blacklist expired tokens  ← Next
   - [ ] Add token expiry config

### Next Actions
1. Complete "Blacklist expired tokens" in Phase 2
2. Then proceed to "Add token expiry config"
```

### All Features Overview (`--all`)

```
## 📊 Project Status Overview

### Active Features

| Feature | Progress | Phases | Last Updated |
|---------|----------|--------|--------------|
| user-auth | ████████████░░ 60% | 2/4 | 2 days ago |
| payment | ████░░░░░░░░░░ 20% | 1/5 | 5 days ago |
| dashboard | ░░░░░░░░░░░░░░ 0% | 0/3 | Not started |

### Summary
- **Total features**: 3
- **In progress**: 2
- **Completed**: 0
- **Not started**: 1

### Recommended Next Action
→ Continue with "user-auth" Phase 2: JWT Management (60% complete)
```

## Status Icons

| Icon | Meaning | Condition |
|------|---------|-----------|
| ✅ | Done | progress = 100% |
| 🔄 | Active | 0% < progress < 100% |
| ⏳ | Pending | progress = 0% |

## Progress Bar

20-character width progress bar:
- `█` = completed portion
- `░` = remaining portion

```
0%:   ░░░░░░░░░░░░░░░░░░░░
25%:  █████░░░░░░░░░░░░░░░
50%:  ██████████░░░░░░░░░░
75%:  ███████████████░░░░░
100%: ████████████████████
```

## Related Skills

- `/init-impl` → Creates the checklist.md that this skill reads
- `/plan-feature` → Creates the phase structure
- `/review` → Review completed phases
