---
name: validate
description: >
  Validation skill wrapper. Invokes the validate agent for artifact consistency (Mode 1)
  or implementation verification (Mode 2). Outputs 10-point score report.
  Use for "validate", "verify artifacts", "check implementation" requests.
---

# Validation Skill

## Overview
This skill wraps the `validate` agent to provide convenient validation of:
- **Mode 1 (artifacts)**: Design doc / checklist / command consistency
- **Mode 2 (phase)**: Implementation against Acceptance Criteria

## Usage

### Mode 1: Artifact Validation
```
/validate {feature} artifacts
```
Validates consistency between:
- Design documents (`docs/plans/{feature}/`)
- Checklists (`docs/checklists/{feature}.md`)
- Phase commands (`.claude/commands/{feature}/`)

### Mode 2: Implementation Validation
```
/validate {feature} phase{N}
```
or
```
/validate {feature} all
```
Validates:
- Build/test pass
- Acceptance Criteria fulfillment
- Checklist completion
- Code quality patterns

## Output

Both modes produce a structured report with:
- Category-wise scores
- Overall score (0-10)
- Critical issues
- Warnings
- Recommendations

## Score Interpretation

| Score | Grade | Action |
|-------|-------|--------|
| 9-10 | Excellent | Ready to proceed |
| 7-8 | Good | Minor issues, can proceed |
| 5-6 | Needs Work | Fix issues before proceeding |
| 0-4 | Fail | Significant rework required |

## Integration with Supervisor

The supervisor skill uses validate in its final stage:
1. IMPLEMENT (auto-impl)
2. REVIEW (code-review)
3. **VALIDATE (this skill)**

Score-based gate determines pass/retry/reject.

## Examples

```
# Validate feature artifacts before implementation
/validate user-auth artifacts

# Validate Phase 1 implementation
/validate user-auth phase1

# Validate all phases
/validate user-auth all
```

## Related

- `code-review` skill: Code quality evaluation
- `supervisor` skill: Full QA pipeline (implement → review → validate)
- `validate` agent: The underlying agent performing validation
