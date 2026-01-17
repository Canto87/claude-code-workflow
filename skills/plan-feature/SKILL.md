---
name: plan-feature
description: Generate phase-based design documents for new features. Use for feature planning, roadmap creation, design documents, or "design a feature" requests.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion, Task
---

# Phase Document Generator

Collects requirements through interactive Q&A and generates phase-based design documents.

## When to Use

- "Design a XX feature"
- "Plan a new feature: YY"
- "Create a roadmap for ZZ"
- When design is needed before implementing a large feature

## Configuration File

Skill settings are managed in `config.yaml` in the same folder.

```yaml
# config.yaml example
project:
  name: "my-project"
  language: go  # go | python | typescript | java | rust | other

paths:
  source: "internal"      # Source code path
  apps: "apps"            # Application entry points
  plans: "docs/plans"     # Design docs output path
```

## Execution Flow

```
1. Check Config           → Read config.yaml (use defaults if missing)
       ↓
2. Basic Info (Required)  → Feature name, Core goal
       ↓
3. Codebase Analysis      → Explore related modules
       ↓
   📋 Interim Summary 1
       ↓
4. Architecture Q&A       → Integration, Storage, API
       ↓
   📋 Interim Summary 2
       ↓
5. Functional Design      → Use cases, Interface spec, Error handling
       ↓
   📋 Interim Summary 3
       ↓
6. Details (Optional)     → Priority, Scheduling
       ↓
7. Preview & Confirm      → Show each file preview, allow edits
       ↓
8. Generate Documents     → Write confirmed docs
```

**Key Rules:**
- All questions include "Generate design docs" option (can exit anytime)
- Interim summaries to check progress
- Question format: See [questions.md](questions.md)

## Question Categories

| Step | Question | Required |
|------|----------|----------|
| 2 | Feature name confirmation | O |
| 2 | Core goal | O |
| 4 | System integration (multiSelect) | O |
| 4 | Data storage | O |
| 4 | API requirement | O |
| 5 | Core use cases (multiSelect) | O |
| 5 | Interface specification | O |
| 5 | Error handling strategy | O |
| 5 | Security/Validation | - |
| 6 | Priority | - |
| 6 | Scheduling | - |

## Output

Generated in `{config.paths.plans}/{feature_name}/` folder:

```
{plans_path}/{feature_name}/
├── 00_OVERVIEW.md     ← Overall overview
├── 01_{PHASE1}.md     ← Phase 1 details
├── 02_{PHASE2}.md     ← Phase 2 details
└── ...
```

Templates:
- [templates/overview.md](templates/overview.md) - OVERVIEW template
- [templates/phase.md](templates/phase.md) - Phase template

## Preview & Confirm Flow

For each document (OVERVIEW, Phase1, Phase2, ...):

```
1. Generate Preview    → Create document content in memory
       ↓
2. Show Preview        → Display content to user
       ↓
3. User Decision       → Approve / Request changes / Skip
       ↓
4. Apply Changes       → If changes requested, regenerate
       ↓
5. Write File          → Save confirmed content
```

**User options at each preview:**
- **Approve** - Save file as-is, proceed to next
- **Request changes** - Describe what to modify, regenerate preview
- **Skip** - Don't create this file, proceed to next

## Phase Division Criteria

1. **Dependencies**: Does another Phase need to complete first?
2. **Difficulty**: Low/Medium/High
3. **Impact**: Low/Medium/High
4. **Implementation Order**: Logical sequence

Recommended Phase count: 3-7

## Limitations

- **AskUserQuestion: Max 4 options**
- To modify previous answer: Select "Other" then type "redo previous question"

## Completion Output

```
## Design Documents Generated

📁 {plans_path}/{feature_name}/
├── 00_OVERVIEW.md     ✓ (confirmed)
├── 01_{name}.md       ✓ (confirmed)
├── 02_{name}.md       ✓ (modified)
└── 03_{name}.md       ⊘ (skipped)

### Collected Information Summary
- Feature name: {feature_name}
- Core goal: {goal}
- Integration: {systems}
- Storage: {storage}
- Use cases: {use_cases}
- Interface: {interface_spec}
- Error handling: {error_strategy}
- Phase count: {count}

### Next Steps
"{feature_name} prepare for implementation" → init-impl Skill
```

**Status indicators:**
- ✓ (confirmed) - Approved without changes
- ✓ (modified) - Approved after user modifications
- ⊘ (skipped) - User chose to skip this file

## Next Steps

After design completion, initialize implementation system:
- "{feature_name} prepare for implementation"
- init-impl Skill auto-triggers
