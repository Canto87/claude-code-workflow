# Phase 2: Status/Progress Skill

> Implementation progress dashboard

## Purpose

Visualize the progress of checklists created by init-impl and provide
an overview of the overall implementation status at a glance.

## Usage Scenarios

```bash
# Check current feature progress
> /status

# Check specific feature status
> /status user-auth

# Get overall project status summary
> /status --all
```

## Data Source

```
docs/plans/{feature_name}/
├── 00_OVERVIEW.md
├── 01_PHASE1.md
├── 02_PHASE2.md
└── checklist.md          ← Progress parsing
```

### checklist.md Parsing Rules

```markdown
## Phase 1: Basic Auth
- [x] Create user model        ← Completed
- [x] Implement signup API     ← Completed
- [ ] Add login endpoint       ← Not completed
- [ ] Write unit tests         ← Not completed

## Phase 2: JWT Management
- [ ] Generate access token    ← Not completed
- [ ] Implement refresh logic  ← Not completed
```

**Parsing Result:**
```yaml
phases:
  - name: "Phase 1: Basic Auth"
    total: 4
    completed: 2
    progress: 50%
  - name: "Phase 2: JWT Management"
    total: 2
    completed: 0
    progress: 0%
overall:
  total: 6
  completed: 2
  progress: 33%
```

## Output Format

### Basic Output

```
## 📊 Implementation Status: user-auth

### Overall Progress
██████████░░░░░░░░░░ 50% (12/24 tasks)

### Phase Breakdown

| Phase | Progress | Tasks | Status |
|-------|----------|-------|--------|
| Phase 1: Basic Auth | ████████████████████ 100% | 6/6 | ✅ Done |
| Phase 2: JWT | ████████████░░░░░░░░ 60% | 3/5 | 🔄 In Progress |
| Phase 3: Session | ████████░░░░░░░░░░░░ 40% | 2/5 | 🔄 In Progress |
| Phase 4: Social | ░░░░░░░░░░░░░░░░░░░░ 0% | 0/8 | ⏳ Pending |

### Current Focus
🔄 **Phase 2: JWT Management**
   - [x] Generate access token
   - [x] Implement refresh logic
   - [x] Token validation
   - [ ] Blacklist expired tokens  ← Next
   - [ ] Add token expiry config

### Blockers
⚠️ No blockers identified

### Time Tracking (Optional)
- Started: 2024-01-15
- Last activity: 2024-01-18
- Estimated remaining: 2 phases
```

### Full Project Summary (`--all`)

```
## 📊 Project Status Overview

### Active Features

| Feature | Progress | Phases | Last Updated |
|---------|----------|--------|--------------|
| user-auth | ██████████░░ 50% | 2/4 | 2 days ago |
| payment | ████░░░░░░░░ 20% | 1/5 | 5 days ago |
| dashboard | ░░░░░░░░░░░░ 0% | 0/3 | - |

### Summary
- Total features: 3
- In progress: 2
- Completed: 0
- Not started: 1

### Recommended Next Action
→ Continue with "user-auth" Phase 2 (60% complete)
```

## File Structure

```
skills/status/
├── SKILL.md              # Skill definition
├── config.yaml           # Settings
└── templates/
    ├── status.md         # Single feature template
    └── overview.md       # Overall summary template
```

## config.yaml Schema

```yaml
# status skill settings
paths:
  plans: "docs/plans"     # Design documents path

parsing:
  checklist_file: "checklist.md"
  checkbox_pattern: "- \\[([ x])\\]"
  phase_pattern: "^## Phase \\d+:"

display:
  progress_bar_width: 20
  show_time_tracking: false
  show_blockers: true
```

## SKILL.md Definition

```yaml
---
name: status
description: Display implementation progress dashboard for features
allowed-tools: Read, Glob
---
```

## Core Logic

### 1. Checklist Parsing

```
Input: checklist.md content
Output:
  {
    phases: [
      { name, total, completed, items: [...] }
    ],
    overall: { total, completed, percentage }
  }
```

### 2. Progress Calculation

```
phase_progress = completed_items / total_items * 100
overall_progress = sum(completed) / sum(total) * 100
```

### 3. Status Determination

```
status =
  if progress == 100%: "✅ Done"
  elif progress > 0%: "🔄 In Progress"
  else: "⏳ Pending"
```

### 4. Finding Current Focus

```
current_focus = first phase where 0% < progress < 100%
next_task = first unchecked item in current_focus
```

## Integration

### Integration with init-impl

```
/init-impl executed → checklist.md created
/status executed → Parse checklist.md and display progress
```

### Integration with plan-feature

```
/plan-feature completed → Phase list exists in 00_OVERVIEW.md
/status → Can reference phase metadata
```

## Extensibility

- **Slack Integration**: Daily automatic progress reports
- **Git Integration**: Auto-match commits with checklist items
- **Burndown Chart**: Progress visualization over time
