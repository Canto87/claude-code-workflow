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
6. Auto Phase Proposal    → Analyze & suggest phase structure
       ↓
7. Details (Optional)     → Priority, Scheduling
       ↓
8. Preview & Confirm      → Show each file preview, allow edits
       ↓
9. Generate Documents     → Write confirmed docs
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
| 6 | Phase proposal confirmation | O |
| 7 | Priority | - |
| 7 | Scheduling | - |

## Intelligent Codebase Analysis (Step 3)

Automatically analyze the codebase to identify reusable components and architecture patterns.

### Analysis Targets

| Target | Method | Output |
|--------|--------|--------|
| Directory structure | Glob patterns | Architecture pattern detection |
| Existing modules | File/folder scan | Reusable component list |
| Dependencies | Import analysis | Dependency graph |
| Patterns | Code grep | Design pattern recognition |

### Analysis Process

```
1. Structure Analysis
   - Scan {config.paths.source}/ directory
   - Identify layer patterns (handler, service, repository, etc.)
   - Detect existing module boundaries

2. Component Discovery
   - Find existing types/interfaces
   - Identify shared utilities
   - Locate configuration patterns

3. Dependency Mapping
   - Trace import relationships
   - Build dependency graph
   - Identify circular dependencies

4. Pattern Recognition
   - Detect architecture style (MVC, Clean, Hexagonal, etc.)
   - Identify coding conventions
   - Find reusable patterns
```

### Architecture Pattern Detection

| Pattern | Indicators | Recommended Structure |
|---------|------------|----------------------|
| Clean Architecture | `domain/`, `usecase/`, `interface/` | Follow existing layers |
| MVC | `models/`, `views/`, `controllers/` | Add to respective folders |
| Hexagonal | `ports/`, `adapters/`, `core/` | Create port/adapter pair |
| Layered | `api/`, `service/`, `repository/` | Add new layer components |
| Modular | `modules/{name}/` | Create new module folder |

### Analysis Output Format

```
🔍 Codebase Analysis Results

Architecture: {detected_pattern}
Language: {project.language}

📁 Structure
{source_path}/
├── {layer1}/          ← {description}
├── {layer2}/          ← {description}
└── {layer3}/          ← {description}

♻️  Reusable Components
┌─────────────────────────────────────────────┐
│ Component        │ Path           │ Reuse   │
├─────────────────────────────────────────────┤
│ {DatabaseClient} │ {path/to/db}   │ Direct  │
│ {Logger}         │ {path/to/log}  │ Direct  │
│ {HTTPClient}     │ {path/to/http} │ Wrap    │
│ {ConfigLoader}   │ {path/to/cfg}  │ Extend  │
└─────────────────────────────────────────────┘

🔗 Dependency Suggestions
- Use existing {component} for {purpose}
- Extend {interface} for {new_feature}
- Follow {pattern} convention for consistency

⚠️  Considerations
- {existing_module} may need modification
- {shared_component} is used by {N} modules
- Avoid circular dependency with {module}
```

### Reuse Categories

| Category | Description | Action |
|----------|-------------|--------|
| Direct | Use as-is | Import directly |
| Wrap | Add thin wrapper | Create adapter |
| Extend | Add new methods | Extend interface |
| Reference | Copy pattern | Follow convention |
| Avoid | Don't use | Create new component |

### Integration with Phase Proposal

Analysis results feed into Auto Phase Proposal:
- Reusable components → Reduce Phase 1 scope
- Existing patterns → Follow conventions in all phases
- Dependencies → Inform phase ordering
- Complexity → Adjust difficulty estimates

## Auto Phase Proposal

After collecting functional design info, automatically analyze and propose phases.

### Analysis Factors

| Factor | Weight | Source |
|--------|--------|--------|
| Use case count | High | Step 5 answers |
| Integration complexity | High | Step 4 answers |
| Data model complexity | Medium | Storage selection |
| API endpoint count | Medium | Interface spec |
| Security requirements | Low | Security selection |

### Phase Proposal Algorithm

```
1. Analyze Complexity
   - Count use cases → estimate work units
   - Check integrations → identify dependencies
   - Evaluate storage → determine data layer work

2. Identify Natural Boundaries
   - Group related use cases
   - Separate by dependency order
   - Consider testing isolation

3. Estimate Difficulty/Impact
   - Foundation work → High impact, varies difficulty
   - Core features → High impact, Medium difficulty
   - Extensions → Lower impact, varies difficulty

4. Generate Proposal
   - Phase 1: Foundation (data model, base structure)
   - Phase 2-N: Feature groups (by dependency)
   - Final Phase: Polish (optimization, edge cases)
```

### Proposal Output Format

```
📋 Recommended Phase Structure

Based on your requirements, I suggest {N} phases:

┌─────────────────────────────────────────────────────────┐
│ Phase 1: {Name}                                         │
│ Difficulty: {Low/Medium/High} | Impact: {Low/Medium/High}│
├─────────────────────────────────────────────────────────┤
│ • {Component/Feature 1}                                 │
│ • {Component/Feature 2}                                 │
│ Why first: {Reasoning - e.g., "Foundation for others"}  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Phase 2: {Name}                                         │
│ Difficulty: {Low/Medium/High} | Impact: {Low/Medium/High}│
├─────────────────────────────────────────────────────────┤
│ • {Component/Feature 3}                                 │
│ • {Component/Feature 4}                                 │
│ Depends on: Phase 1                                     │
└─────────────────────────────────────────────────────────┘

... (more phases)

Total estimated phases: {N}
```

### User Options

```json
{
  "questions": [{
    "header": "Phase Plan",
    "question": "How would you like to proceed with this phase structure?",
    "multiSelect": false,
    "options": [
      {"label": "Accept proposal", "description": "Use suggested {N} phases"},
      {"label": "Fewer phases", "description": "Combine into fewer, larger phases"},
      {"label": "More phases", "description": "Split into smaller, focused phases"},
      {"label": "Custom structure", "description": "Define your own phases"}
    ]
  }]
}
```

### Adjustment Rules

**If "Fewer phases" selected:**
- Merge phases with similar difficulty
- Combine related features
- Minimum: 2 phases

**If "More phases" selected:**
- Split complex phases
- Isolate risky components
- Maximum: 7 phases

**If "Custom structure" selected:**
- Ask user to describe desired phases
- Validate dependencies
- Generate based on user input

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
- [templates/phase-analysis.md](templates/phase-analysis.md) - Phase analysis guide
- [templates/codebase-analysis.md](templates/codebase-analysis.md) - Codebase analysis guide

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
