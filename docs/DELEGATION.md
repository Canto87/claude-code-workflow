# Delegation Model

This document explains when and how to delegate tasks to agents in the claude-code-workflow system.

## Table of Contents

- [The 3-File Rule](#the-3-file-rule)
- [Task Type Mapping](#task-type-mapping)
- [Delegation Decision Tree](#delegation-decision-tree)
- [Agent Selection Guide](#agent-selection-guide)
- [Supervisor Pipeline](#supervisor-pipeline)
- [Best Practices](#best-practices)

---

## The 3-File Rule

**When modifying 3 or more code files, always delegate to a subagent.**

### Why?

1. **Context Conservation**: Main conversation context is limited
2. **Reliability**: Agents have clear protocols for multi-file changes
3. **Rollback Support**: Agents track changes for potential rollback
4. **Verification**: Agents run build/test after changes

### Exceptions

- Documentation files (markdown) don't count
- Config files (yaml, json) don't count
- Single-line fixes across files can be done directly

---

## Task Type Mapping

Copy this table to your project's CLAUDE.md:

```markdown
### Plan Mode → Implementation Rules

| Task Type | Tool | Reason |
|-----------|------|--------|
| **Code modification** (3+ files) | `code-edit` agent | Save main context |
| **Multi-file changes** (Phase) | `auto-impl` agent | Phase orchestration |
| **Documentation changes** | Direct Write/Edit | No agent overhead |
| **Config file changes** | Direct Edit | Simple changes |
| **Code analysis/research** | `code-analyze` agent | Read-only exploration |
| **Code quality check** | `code-review` agent | Pre-merge evaluation |
| **Full QA pipeline** | `supervisor` skill | Implement → Review → Validate |
```

---

## Delegation Decision Tree

```
Is this a code modification?
│
├─ No → Is it analysis/research?
│        ├─ Yes → code-analyze agent
│        └─ No → Handle directly
│
└─ Yes → How many files will change?
          │
          ├─ 1-2 files → Handle directly (unless complex)
          │
          └─ 3+ files → Is it part of a Phase?
                        │
                        ├─ Yes → auto-impl agent
                        │
                        └─ No → code-edit agent
```

### Complexity Factors

Even with 1-2 files, consider delegation if:
- Changes span multiple functions
- Refactoring is involved
- Error handling needs updating
- Tests need modification

---

## Agent Selection Guide

### code-edit

**Use when**:
- Single focused task
- 1-20 files affected
- Clear success criteria
- Build/test verification needed

**Don't use when**:
- Research/exploration needed
- Multiple unrelated changes
- Documentation only

**Example**:
```
"Fix the null pointer exception in user service when email is empty"
```

---

### auto-impl

**Use when**:
- Implementing a Phase from init-impl
- Multiple related tasks
- Checkpoint tracking needed
- Systematic progress required

**Don't use when**:
- Single isolated task
- No Phase command exists
- Exploratory work

**Example**:
```
"Implement user-auth phase 2"
```

---

### code-analyze

**Use when**:
- Understanding codebase structure
- Planning changes
- Finding integration points
- Discovering patterns

**Don't use when**:
- You need to modify files
- Simple questions
- Already know the codebase

**Example**:
```
"Analyze the payment module to understand how refunds work"
```

---

### code-review

**Use when**:
- Before merging changes
- After code-edit completes
- Quality gate needed
- Security review required

**Don't use when**:
- Code hasn't been written yet
- Just want analysis, not scoring
- Minor documentation changes

**Example**:
```
"Review the authentication changes for security issues"
```

---

### validate

**Use when**:
- After implementation completes
- Verifying Acceptance Criteria
- Checking artifact consistency
- Quality gate needed

**Don't use when**:
- Implementation still in progress
- No Acceptance Criteria defined
- Just want code review

**Example**:
```
"Validate user-auth phase 1 against the design"
```

---

## Supervisor Pipeline

The supervisor skill orchestrates a complete QA pipeline:

```
IMPLEMENT → REVIEW → VALIDATE
    │          │          │
    ▼          ▼          ▼
auto-impl  code-review  validate
    │          │          │
    └──────────┴──────────┘
           │
      Gate Decisions
      (score-based)
```

### Pipeline Stages

| Stage | Agent | Success Criteria |
|-------|-------|------------------|
| IMPLEMENT | auto-impl | All tasks complete |
| REVIEW | code-review | Score 7+, no Critical |
| VALIDATE | validate | Score 7+, AC met |

### Gate Logic

```
Score 7+ AND no Critical → PASS → Next stage
Score 5-6 OR has Critical → RETRY → Fix and re-check
Score 0-4 → REJECT → Manual intervention
```

### Retry Limits

- Review Gate: 2 retries
- Validate Gate: 1 retry
- Total: 3 retries across pipeline

### Invoking Supervisor

```
/supervisor {feature} {phase}

# Examples:
/supervisor user-auth phase1
/supervisor payment all
/supervisor user-auth phase2 --skip-impl  # Skip implementation, review existing
```

---

## Best Practices

### 1. Start with Analysis

Before making changes, understand the codebase:
```
"Analyze the module I'm about to modify for change impact"
```

### 2. Use Appropriate Scope

Let code-edit auto-detect, or specify:
- `--scope file`: 1-3 files
- `--scope module`: 4-10 files
- `--scope cross-module`: 10-20 files

### 3. Provide Context

When delegating, include:
- Clear task description
- Target files/directories
- Constraints (files not to modify)
- Related design documents

### 4. Review Before Validate

The order matters:
1. **code-review**: Catches code quality issues
2. **validate**: Catches requirement compliance issues

### 5. Trust the Scores

- 7+: Safe to proceed
- 5-6: Worth fixing before merge
- <5: Significant issues to address

### 6. Don't Fight Gates

If a gate rejects:
- Don't try to bypass
- Investigate root cause
- Fix fundamentally

---

## Example CLAUDE.md Integration

```markdown
## Workflow

1. **Start with plan mode** — Review current phase
2. For large features, use `/plan-feature`
3. After plan approval, follow delegation rules
4. Run `/test` after each phase

### Delegation Rules

| Task Type | Tool | Reason |
|-----------|------|--------|
| Code modification (3+ files) | code-edit agent | Context savings |
| Phase implementation | auto-impl agent | Orchestration |
| Documentation | Direct Write/Edit | No overhead |
| Config files | Direct Edit | Simple changes |
| Analysis | code-analyze agent | Read-only |
| Quality check | code-review agent | Evaluation |
| Full QA | supervisor skill | Pipeline |

**Principle**: 3+ code files → always delegate.

### Quality Gates

- Use `/supervisor` for full pipeline
- Score 7+ required to proceed
- Critical issues block progress
```

---

## Related Documentation

- [AGENTS.md](./AGENTS.md) - Agent system guide
- [examples/advanced-workflow.md](../examples/advanced-workflow.md) - Advanced usage
- [examples/CLAUDE.md.example](../examples/CLAUDE.md.example) - Project template
