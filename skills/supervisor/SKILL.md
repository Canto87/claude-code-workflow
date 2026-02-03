---
name: supervisor
description: >
  QA pipeline orchestrator. Chains implement (auto-impl) → review (code-review) → validate (validate)
  with score-based gate decisions (pass/retry/reject).
  Use for "supervisor", "run pipeline", "implement and validate" requests.
---

# QA Pipeline Orchestrator

> **This skill runs in the main conversation context, giving it access to the Task tool.**
> Agents (.claude/agents/) cannot access Task tool for subagent delegation.
> Skills (.claude/skills/) run in main conversation, removing this constraint.

## Absolute Rules (Top Priority)
1. **Never write/modify code directly.**
   - No file creation via Bash: `cat >`, `echo >`, `tee`, heredoc, `python -c "...write..."`, etc.
   - No "it's just a small fix" shortcuts — Even 1-line changes must be delegated
2. **All implementation/modification must be delegated via Task tool.**
   - Implementation: `subagent_type: "auto-impl"`
   - Review: `subagent_type: "code-review"`
   - Validation: `subagent_type: "validate"`
   - Review/validation feedback fixes: `subagent_type: "code-edit"`
3. **Bash is read-only only.**
   - Allowed: `git log`, `git status`, `git diff`, build commands, `ls`
   - Forbidden: File creation, file modification, redirects (`>`, `>>`)
4. **Never invoke subagents by running `claude` CLI via Bash.**
   - Subagent calls **must use Task tool**

## Input Parsing
Extract from user message (ARGUMENTS):
- **feature**: Feature name (e.g., `user-auth`)
- **phase**: Phase number (e.g., `1`) or `all`
- **options**: `--dry-run`, `--no-commit`, `--continue`, `--interactive`, `--skip-impl`

---

## Pipeline Structure

```
Stage 1: IMPLEMENT  → auto-impl delegation (Task tool)
Stage 2: REVIEW     → code-review delegation (Task tool)
Gate 1:  REVIEW GATE → Score-based pass/retry/reject
Stage 3: VALIDATE   → validate delegation (Task tool)
Gate 2:  VALIDATE GATE → Score-based pass/retry/reject
```

---

## Gate Criteria

| Score | Decision | Action |
|-------|----------|--------|
| 7+ (no Critical) | PASS | Proceed to next stage |
| 5-6 or has Critical | RETRY | Delegate fix to code-edit, then re-review |
| 0-4 | REJECT | Stop pipeline, manual intervention needed |

### Retry Limits
- Review Gate: Max 2 retries
- Validate Gate: Max 1 retry
- Total retries: Max 3

---

## Execution Flow

### Step 0: Context Gathering (Parallel Read)
Read the following files to collect pipeline context:
- `.claude/commands/{feature}/phase{N}.md` → Phase command
- `docs/checklists/{feature}.md` → Current progress
- `docs/plans/{feature}/` → Design documents

With `--dry-run`: Output pipeline plan only and stop.

### Step 1: IMPLEMENT (auto-impl delegation)

Skip this stage with `--skip-impl`.

**Task tool call:**
```
Task(
  subagent_type: "auto-impl",
  description: "{feature} phase{N} implementation",
  prompt: "Implement {feature} phase{N}\n\n{Full copy of Phase command Tasks + AC}"
)
```

**Important**: Include full Tasks and Acceptance Criteria from Phase command in prompt.
auto-impl runs independently and needs sufficient context.

**After completion**: Verify build with build command.

### Step 2: REVIEW (code-review delegation)

**Task tool call:**
```
Task(
  subagent_type: "code-review",
  description: "{feature} phase{N} code review",
  prompt: "Review {feature} phase{N}\n\n## Changed Files\n{git diff --name-only}\n\n## AC\n{AC items}"
)
```

**Parse result:** Extract score (X/10), Critical Issues, Warnings.

### Gate 1: REVIEW GATE

**PASS (7+ AND no Critical):** → Stage 3

**RETRY (5-6 OR has Critical, retries < 2):**
```
Task(
  subagent_type: "code-edit",
  description: "{feature} phase{N} review feedback fix",
  prompt: "Apply code-review feedback\n\n## Items to Fix\n{Critical + Warnings}"
)
```
→ Commit, return to Stage 2

**REJECT (0-4 OR retries >= 2):** → Stop pipeline

### Step 3: VALIDATE (validate delegation)

**Task tool call:**
```
Task(
  subagent_type: "validate",
  description: "{feature} phase{N} validation",
  prompt: "Validate {feature} phase{N}\n\n## AC\n{AC items}"
)
```

### Gate 2: VALIDATE GATE

**PASS (7+ AND no Critical):** → Pipeline success
**RETRY (5-6 OR has Critical, retries < 1):** → code-edit fix, then re-validate
**REJECT (0-4 OR retries >= 1):** → Stop pipeline

---

## Report Output Format

### Success Report
```
## Supervisor Complete: {feature} Phase {N}

### Pipeline Summary
| Stage | Status | Score | Details |
|-------|--------|-------|---------|
| IMPLEMENT | {status} | - | {tasks_done}/{tasks_total} tasks |
| REVIEW | {status} | {N}/10 | {critical} critical, {warnings} warnings |
| VALIDATE | {status} | {N}/10 | {ac_met}/{ac_total} AC met |

### Gate Decisions
| Gate | Attempt | Score | Decision |
|------|---------|-------|----------|
| Review #1 | {N}/10 | {PASS/RETRY} | {reason} |
| Validate #1 | {N}/10 | {PASS} | {reason} |

### Recommended Next Steps
- Proceed to next Phase or documentation
```

### Failure Report
```
## Supervisor REJECTED: {feature} Phase {N}

### Rejection Reason
{specific failure reason}

### Manual Fix Required
1. {item}: {location} — {description}
```

---

## Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Output pipeline plan only |
| `--no-commit` | Skip feedback fix commits |
| `--continue` | Resume from last stopped point |
| `--interactive` | User confirmation at gate decisions |
| `--skip-impl` | Skip implementation stage |

---

## Git Commit Format
```
# auto-impl delegation commit (auto-impl generates itself)
feat({feature}): phase{N} - {task summary}

# Review feedback fix commit
fix({feature}): phase{N} - review feedback #{retry_count}

# Validate feedback fix commit
fix({feature}): phase{N} - validate feedback #{retry_count}
```
