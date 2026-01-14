# status Command Template

Template for `{commands_path}/{feature}/status.md` file.

---

```markdown
Check {Feature Name} progress

## Tasks

1. Read `{checklists_path}/{feature}.md` and summarize current progress
2. Show current Phase, completion rate, next tasks

## Output Format

```
## {Feature Name} Progress

### Current Status
- **Phase**: {current Phase number and name}
- **Status**: {In Progress/Waiting/Completed}
- **Completion**: {completed items}/{total items} ({percent}%)

### Overall Progress
| Phase | Name | Status |
|-------|------|--------|
| 1 | {Phase 1 name} | {status} |
| 2 | {Phase 2 name} | {status} |
| ... | ... | ... |

### Next Task
{Specific next task to work on}

### Related Commands
- `/phase{N}` (project:{feature}) - Start Phase N implementation

## Session Notes Check

Also check "Session Notes" section of each Phase for last progress updates

## Reference
```
- Checklist: `{checklists_path}/{feature}.md`
- Phase documents: `{plans_path}/{feature}/`
```
