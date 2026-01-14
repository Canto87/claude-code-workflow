# phase Command Template

Template for `{commands_path}/{feature}/phase{N}.md` file.

---

```markdown
---
description: Phase {N} - {Phase Name} implementation
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, Skill
---

Build {Feature Name} Phase {N}: {Phase Name}

## Overview

{Phase description - extracted from 00_OVERVIEW.md or 0N_*.md}

## Pre-Implementation Check

1. Verify {previous Phase} completion
2. Check current status in `{checklists_path}/{feature}.md`
3. Read previous session notes

## Tasks

{Implementation items extracted from 0N_*.md}

### 1. {Component 1}
Create `{file path}`:
- {detail item}
- {detail item}

### 2. {Component 2}
Create `{file path}`:
- {detail item}
- {detail item}

## Acceptance Criteria

{Checklist items}
- [ ] Item 1 completed
- [ ] Item 2 completed
- [ ] Tests passing

## Test Commands

```bash
# Build
{build_command}

# Run
{run_command}

# Verify
{test_command}
```

## On Completion

1. Update checklist items in `{checklists_path}/{feature}.md`
2. Change Phase {N} status to "Completed"
3. Run tests to verify no regression

## Reference

- Detailed design: `{plans_path}/{feature}/0{N}_*.md`
- Checklist: `{checklists_path}/{feature}.md`
```

---

## Extraction Rules

### Tasks (from "## Implementation" section in 0N_*.md)
```markdown
## Implementation

### 1. {Component 1}
Create `{file path}`:
- {detail item}
```

### Acceptance Criteria (from "## Checklist" section in 0N_*.md)
```markdown
## Checklist
- [ ] Item 1
- [ ] Item 2
```

### Test Commands (from "## Testing" section in 0N_*.md)
```markdown
## Testing
\`\`\`bash
{test commands}
\`\`\`
```

## Build/Test Command Defaults

Get from `config.yaml` or use defaults:

| Language | Build | Test |
|----------|-------|------|
| Go | `go build ./...` | `go test ./...` |
| TypeScript | `npm run build` | `npm test` |
| Python | `python -m build` | `pytest` |
| Rust | `cargo build` | `cargo test` |
