# Checklist Template

Template for `{checklists_path}/{feature}.md` file.

---

```markdown
# {Feature Name} Checklist

> {One-line description}

## Current Progress

- **Current Phase**: Phase 1 ({Phase 1 Name})
- **Last Update**: {date}
- **Next Task**: {first item}
- **Overall Progress**: 0/{N} Phases completed

---

## Phase 1: {Phase 1 Name}

**Document**: `{plans_path}/{feature}/01_*.md`
**Status**: ⏳ Waiting
**Difficulty**: {difficulty} | **Impact**: {impact}

### Goal
{Phase 1 goal - extracted from 00_OVERVIEW.md}

### Checklist
{Checklist extracted from 01_*.md}
- [ ] Item 1
- [ ] Item 2
- [ ] ...

### Testing
```bash
{test commands}
```

### Session Notes
<!-- Record progress from each session -->

---

## Phase 2: {Phase 2 Name}
...

---

## Completion Criteria

Each Phase completion requirements:
1. **Checklist 100% complete**
2. **Tests passing**
3. **No regression in previous Phase features**

## Related Commands

| Command | Description |
|---------|-------------|
| `/status` (project:{feature}) | Check current progress |
| `/phase1` ~ `/phaseN` (project:{feature}) | Implement each Phase |
```

---

## Extraction Rules

### Phase Info (from 00_OVERVIEW.md)
```markdown
## Implementation Phases
| Rank | Phase | Feature | Difficulty | Impact | Status |
|------|-------|---------|------------|--------|--------|
| 1 | Phase 1 | {feature} | {difficulty} | {impact} | Not implemented |
```

### Checklist Items (from 0N_*.md)
```markdown
## Checklist
- [ ] Item 1
- [ ] Item 2
```

### Test Commands (from 0N_*.md)
```markdown
## Testing
\`\`\`bash
{test commands}
\`\`\`
```

## Status Icons

| Status | Icon |
|--------|------|
| Waiting | ⏳ |
| In Progress | 🔄 |
| Completed | ✅ |
| Blocked | 🚫 |
