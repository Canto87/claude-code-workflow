# Status Dashboard Template

Use this template structure when generating status reports.

## Single Feature Template

```markdown
## 📊 Implementation Status: {FEATURE_NAME}

### Overall Progress
{PROGRESS_BAR} {PERCENTAGE}% ({COMPLETED}/{TOTAL} tasks)

### Phase Breakdown

| Phase | Progress | Tasks | Status |
|-------|----------|-------|--------|
{FOR_EACH_PHASE}
| {PHASE_NAME} | {PHASE_BAR} {PHASE_PCT}% | {DONE}/{TOTAL} | {STATUS_ICON} {STATUS} |
{END_FOR}

### Current Focus
{ACTIVE_ICON} **{CURRENT_PHASE}**
{FOR_EACH_TASK_IN_CURRENT}
   - [{CHECK}] {TASK_NAME} {NEXT_MARKER}
{END_FOR}

### Next Actions
{FOR_EACH_NEXT_ACTION}
{INDEX}. {ACTION_DESCRIPTION}
{END_FOR}
```

## All Features Template

```markdown
## 📊 Project Status Overview

### Active Features

| Feature | Progress | Phases | Last Updated |
|---------|----------|--------|--------------|
{FOR_EACH_FEATURE}
| {FEATURE_NAME} | {PROGRESS_BAR} {PCT}% | {DONE_PHASES}/{TOTAL_PHASES} | {LAST_UPDATED} |
{END_FOR}

### Summary
- **Total features**: {TOTAL_FEATURES}
- **In progress**: {IN_PROGRESS_COUNT}
- **Completed**: {COMPLETED_COUNT}
- **Not started**: {NOT_STARTED_COUNT}

### Recommended Next Action
→ {RECOMMENDATION}
```

## Progress Bar Generation

Width: 20 characters

```
percentage = completed / total * 100
filled = round(percentage / 100 * 20)
empty = 20 - filled
bar = "█" * filled + "░" * empty
```

Examples:
| Percentage | Bar |
|------------|-----|
| 0% | `░░░░░░░░░░░░░░░░░░░░` |
| 10% | `██░░░░░░░░░░░░░░░░░░` |
| 25% | `█████░░░░░░░░░░░░░░░` |
| 50% | `██████████░░░░░░░░░░` |
| 75% | `███████████████░░░░░` |
| 100% | `████████████████████` |

## Status Determination

```
if completed == total:
    status = "Done"
    icon = "✅"
elif completed > 0:
    status = "Active"
    icon = "🔄"
else:
    status = "Pending"
    icon = "⏳"
```

## Next Action Logic

1. Find first incomplete task in current active phase
2. If phase nearly complete (>80%), mention next phase
3. If blocked, indicate blocker

## Example Outputs

### Feature with Active Work

```markdown
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
3. After Phase 2, begin Phase 3: Session Management
```

### Completed Feature

```markdown
## 📊 Implementation Status: logging

### Overall Progress
████████████████████ 100% (15/15 tasks)

### Phase Breakdown

| Phase | Progress | Tasks | Status |
|-------|----------|-------|--------|
| Phase 1: Setup | ████████████████████ 100% | 5/5 | ✅ Done |
| Phase 2: Integration | ████████████████████ 100% | 6/6 | ✅ Done |
| Phase 3: Monitoring | ████████████████████ 100% | 4/4 | ✅ Done |

### 🎉 Feature Complete!

All phases have been implemented. Consider:
- Running `/review logging` for quality check
- Running `/generate-docs logging` for documentation
```

### Not Started Feature

```markdown
## 📊 Implementation Status: analytics

### Overall Progress
░░░░░░░░░░░░░░░░░░░░ 0% (0/18 tasks)

### Phase Breakdown

| Phase | Progress | Tasks | Status |
|-------|----------|-------|--------|
| Phase 1: Data Model | ░░░░░░░░░░░░░░░░░░░░ 0% | 0/6 | ⏳ Pending |
| Phase 2: Collection | ░░░░░░░░░░░░░░░░░░░░ 0% | 0/5 | ⏳ Pending |
| Phase 3: Dashboard | ░░░░░░░░░░░░░░░░░░░░ 0% | 0/7 | ⏳ Pending |

### Getting Started
This feature hasn't been started yet.

### Next Actions
1. Begin with Phase 1: Data Model
2. First task: "Define event schema"
```
