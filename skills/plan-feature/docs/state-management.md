# State Management

State persistence for session interruption and resumption.

## State File Location

```
.plan-feature/{feature_name}/
├── state.md          ← Session state
└── interim/          ← Interim summaries
    ├── summary-1.md
    ├── summary-2.md
    └── summary-3.md
```

## State File Structure (state.md)

```markdown
# Plan Feature State: {feature_name}

## Session Info
- Created: {timestamp}
- Last Updated: {timestamp}
- Current Step: {step_number}

## Completed Steps

### Step 2: Basic Info
- Feature Name: {name}
- Core Goal: {goal}

### Step 3: Codebase Analysis
- Architecture: {detected_pattern}
- Tech Stack: {languages, frameworks}
- Key Components: {list}

### Step 4: Architecture Q&A
- Integrations: {systems}
- Storage: {storage_type}
- API: {api_requirements}

### Step 5: Functional Design
- Use Cases: {list}
- Interface: {spec}
- Error Handling: {strategy}

### Step 5.5: Implementation Pattern
- Selected: {pattern_name}
- Rationale: {reason}

### Step 6: Phase Proposal
- Phases: {count}
- Structure: {summary}

### Step 6.5: Risk Analysis
- Overall Risk: {level}
- Critical Risks: {list}

## Conversation Context
Key decisions and user preferences from conversation:
- {decision_1}
- {decision_2}
- {preference_1}
```

## State Operations

| Operation | Trigger | Action |
|-----------|---------|--------|
| Create | New feature | Initialize empty state |
| Update | Step completion | Add step results to state |
| Load | Session start | Read state, resume from current step |
| Archive | Generation complete | Move to completed/ folder |

## Interim Summary Integration

After each summary checkpoint:
1. Save summary to `interim/summary-{N}.md`
2. Update state.md with step results
3. On context pressure: load only latest summary + state.md

---

# Feature Size Assessment

Detect large features and recommend decomposition.

## Size Indicators

| Indicator | Small | Medium | Large | Too Large |
|-----------|-------|--------|-------|-----------|
| Use Cases | 1-3 | 4-7 | 8-12 | 13+ |
| Phases | 1-2 | 3-4 | 5-6 | 7+ |
| Integrations | 0-1 | 2-3 | 4-5 | 6+ |
| Risk Level | Low | Medium | High | Critical |

## Assessment Timing

```
After Step 5 (Functional Design):
→ Count use cases
→ Estimate phase count
→ Check integration complexity
→ Calculate size score
```

## Size Score Calculation

```
score = (use_cases × 2) + (integrations × 3) + (risk_level × 2)

Thresholds:
- score < 15: Normal → Continue
- score 15-25: Large → Warn + suggest split
- score > 25: Too Large → Recommend decomposition
```

## Large Feature Warning

```
⚠️ Feature Size Assessment

This feature appears large:
- Use cases: 12
- Estimated phases: 6
- Integrations: 4
- Risk level: High

Recommendations:
1. Split into sub-features:
   ├── {feature_name}-core (Use cases 1-4)
   ├── {feature_name}-integration (Use cases 5-8)
   └── {feature_name}-advanced (Use cases 9-12)

2. Or continue with session splitting:
   → Complete design in multiple sessions
   → Use --continue to resume

How would you like to proceed?
- [Split feature] Decompose into smaller features
- [Continue] Proceed with current scope (use sessions)
- [Simplify] Reduce scope by removing use cases
```

## Decomposition Suggestions

When splitting is recommended:
1. Group related use cases
2. Identify natural boundaries (data, integration, user flow)
3. Propose sub-feature names
4. Show dependency order

---

# Session Continuation

Support multi-session design for large features.

## Usage

```bash
# Start new feature
/plan-feature payment-system

# Resume existing feature
/plan-feature payment-system --continue

# List in-progress features
/plan-feature --list

# Abandon feature (delete state)
/plan-feature payment-system --abandon
```

## Session Start Logic

```
1. Check for existing state
   → .plan-feature/{feature_name}/state.md exists?

2. If exists (or --continue flag):
   → Load state.md
   → Display progress summary:
     "Resuming: payment-system
      Completed: Steps 1-4
      Current: Step 5 (Functional Design)

      Last session context:
      - Discussed OAuth integration
      - Decided on PostgreSQL storage
      - User prefers detailed error messages"
   → Ask: "Resume or start fresh?"
   → If resume: Jump to current step
   → If fresh: Delete state, start from Step 1

3. If not exists:
   → Create new state file
   → Start from Step 1

4. Load relevant interim summary if available
```

## --list Output

```
📋 In-Progress Features

┌─────────────────────────────────────────────────────────────┐
│ Feature           │ Step    │ Last Updated    │ Size       │
├─────────────────────────────────────────────────────────────┤
│ payment-system    │ 5/9     │ 2 hours ago     │ Large      │
│ user-analytics    │ 3/9     │ 1 day ago       │ Medium     │
│ notification      │ 7/9     │ 3 days ago      │ Small      │
└─────────────────────────────────────────────────────────────┘

Resume: /plan-feature {name} --continue
```

## Session Handoff

When ending a session before completion:

```
💾 Session Saved

Feature: payment-system
Progress: Step 5 of 9
State saved to: .plan-feature/payment-system/state.md

To resume later:
  /plan-feature payment-system --continue

Key context preserved:
- OAuth 2.0 integration selected
- PostgreSQL with Redis cache
- 8 use cases defined
- Async worker pattern chosen
```

## Context Preservation

State.md includes "Conversation Context" section:
- Key decisions made
- User preferences expressed
- Important clarifications
- Rejected options (to avoid re-suggesting)

This enables natural conversation continuation without repeating discussions.

---

# Completion & Archival

## On Document Generation Complete

```
1. Mark state as completed
2. Move state.md to .plan-feature/completed/
3. Keep interim summaries for reference
4. Output completion summary
```

## Completion Output

```
✅ Design Complete

Feature: payment-system
Documents: 4 files generated
Location: {plans_path}/payment-system/

State archived to: .plan-feature/completed/payment-system/

Next: /init-impl payment-system
```

## Cleanup Policy

| State | Age | Action |
|-------|-----|--------|
| In-progress | > 30 days | Warn on --list |
| In-progress | > 90 days | Suggest abandon |
| Completed | > 180 days | Auto-delete archive |
