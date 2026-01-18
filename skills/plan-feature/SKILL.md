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
4.5 Alternative Architecture → Propose & compare architecture options
       ↓
   📋 Interim Summary 2
       ↓
5. Functional Design      → Use cases, Interface spec, Error handling
       ↓
   📋 Interim Summary 3
       ↓
6. Auto Phase Proposal    → Analyze & suggest phase structure
       ↓
6.5 Risk Analysis         → Identify risks & rollback strategies
       ↓
7. Details (Optional)     → Priority, Scheduling
       ↓
7.5 Validation            → Verify completeness & consistency
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
| 4.5 | Architecture option selection | O |
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

## Alternative Architecture (Step 4.5)

Propose multiple architecture options based on requirements and let user choose.

### When to Propose Alternatives

| Condition | Trigger |
|-----------|---------|
| Multiple valid patterns | Detected architecture allows variations |
| Complex integration | 3+ system integrations selected |
| Scalability concern | High traffic/data volume expected |
| New technology | Unfamiliar tech stack mentioned |
| Trade-off decision | Clear pros/cons between approaches |

### Architecture Option Generation

```
1. Analyze Requirements
   - Feature complexity (use cases, integrations)
   - Non-functional requirements (scalability, maintainability)
   - Existing codebase patterns
   - Team familiarity (inferred from codebase)

2. Generate Options
   - Option A: Conservative (follow existing patterns)
   - Option B: Optimized (best fit for requirements)
   - Option C: Future-proof (scalable, extensible)

3. Evaluate Each Option
   - Pros/Cons analysis
   - Risk assessment
   - Effort estimation (relative)
   - Long-term implications
```

### Comparison Criteria

| Criteria | Weight | Description |
|----------|--------|-------------|
| Consistency | High | Alignment with existing codebase |
| Complexity | High | Implementation and maintenance effort |
| Scalability | Medium | Growth and performance capacity |
| Flexibility | Medium | Ease of future changes |
| Risk | Medium | Implementation and integration risks |
| Team Fit | Low | Team's familiarity with approach |

### Option Output Format

```
🏗️  Architecture Options

Based on your requirements, here are {N} architecture approaches:

┌─────────────────────────────────────────────────────────────┐
│ Option A: {Name} (Recommended)                              │
│ Approach: {Brief description}                               │
├─────────────────────────────────────────────────────────────┤
│ ✅ Pros                      │ ⚠️  Cons                      │
│ • {Consistent with codebase} │ • {Limited scalability}       │
│ • {Lower complexity}         │ • {May need refactor later}   │
│ • {Faster implementation}    │ •                             │
├─────────────────────────────────────────────────────────────┤
│ Effort: Low-Medium | Risk: Low | Scalability: Medium        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Option B: {Name}                                            │
│ Approach: {Brief description}                               │
├─────────────────────────────────────────────────────────────┤
│ ✅ Pros                      │ ⚠️  Cons                      │
│ • {Better scalability}       │ • {Higher initial complexity} │
│ • {Cleaner separation}       │ • {Deviates from current}     │
│ • {Easier testing}           │ • {Longer implementation}     │
├─────────────────────────────────────────────────────────────┤
│ Effort: Medium-High | Risk: Medium | Scalability: High      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Option C: {Name}                                            │
│ Approach: {Brief description}                               │
├─────────────────────────────────────────────────────────────┤
│ ✅ Pros                      │ ⚠️  Cons                      │
│ • {Maximum flexibility}      │ • {Highest complexity}        │
│ • {Future-proof design}      │ • {Over-engineering risk}     │
│ • {Best practices}           │ • {Steeper learning curve}    │
├─────────────────────────────────────────────────────────────┤
│ Effort: High | Risk: Medium-High | Scalability: Very High   │
└─────────────────────────────────────────────────────────────┘

💡 Recommendation: Option A
   Reason: {Best balance of consistency and requirements}
```

### Common Architecture Patterns

| Pattern | Best For | Trade-offs |
|---------|----------|------------|
| Layered | Simple CRUD, small teams | Easy but can become monolithic |
| Clean/Hexagonal | Complex domains, testability | More boilerplate, steeper curve |
| Microservices | High scale, team autonomy | Operational complexity |
| Event-driven | Async workflows, decoupling | Debugging complexity |
| CQRS | Read/write asymmetry | Eventual consistency |
| Modular Monolith | Growing projects | Balance of simplicity/modularity |

### User Selection Flow

```json
{
  "questions": [{
    "header": "Architecture",
    "question": "Which architecture approach would you like to use?",
    "multiSelect": false,
    "options": [
      {"label": "Option A (Recommended)", "description": "{Conservative approach following existing patterns}"},
      {"label": "Option B", "description": "{Optimized for scalability with moderate changes}"},
      {"label": "Option C", "description": "{Future-proof with significant restructuring}"},
      {"label": "Custom approach", "description": "Describe your preferred architecture"}
    ]
  }]
}
```

### Impact on Phase Proposal

Selected architecture affects phase structure:

| Selection | Phase Impact |
|-----------|--------------|
| Conservative | Fewer phases, follow existing structure |
| Optimized | May need infrastructure phase first |
| Future-proof | Additional phases for patterns/abstractions |
| Custom | Adjust based on user description |

### Architecture Decision Record (ADR)

For selected architecture, generate ADR in OVERVIEW:

```markdown
## Architecture Decision

**Selected**: {Option name}
**Alternatives Considered**: {Other options}
**Decision Rationale**: {Why this option}

### Key Trade-offs Accepted
- {Trade-off 1}: {Accepted because...}
- {Trade-off 2}: {Mitigated by...}

### Constraints
- Must integrate with existing {system}
- Should follow {pattern} conventions
- Limited by {constraint}
```

## Risk Analysis

Automatically identify potential risks for each phase and the overall feature.

### Risk Categories

| Category | Description | Detection Method |
|----------|-------------|------------------|
| Technical | Implementation complexity, new technology | Complexity scoring |
| Dependency | External service, shared component impact | Codebase analysis |
| Integration | Breaking changes, API compatibility | Import/usage analysis |
| Performance | Scalability, resource usage | Data model analysis |
| Security | Auth gaps, data exposure | Security requirements |

### Risk Scoring Matrix

| Impact | Low Probability | Medium Probability | High Probability |
|--------|-----------------|-------------------|------------------|
| High | Medium Risk | High Risk | Critical Risk |
| Medium | Low Risk | Medium Risk | High Risk |
| Low | Minimal Risk | Low Risk | Medium Risk |

### Risk Detection Rules

```
1. Technical Risks
   - New technology/framework → Medium-High
   - Complex algorithm → Medium
   - Third-party API integration → Medium
   - Database schema change → High

2. Dependency Risks
   - Shared component modification → High
   - External service dependency → Medium-High
   - Cross-module coupling → Medium

3. Integration Risks
   - API breaking change → Critical
   - Data migration required → High
   - Multiple system coordination → Medium

4. Rollback Complexity
   - Database change → Hard to rollback
   - Config change → Easy to rollback
   - Code change → Medium to rollback
```

### Risk Output Format

```
⚠️  Risk Assessment

Overall Risk Level: {Low/Medium/High/Critical}

┌─────────────────────────────────────────────────────────────┐
│ Risk                    │ Impact │ Probability │ Level     │
├─────────────────────────────────────────────────────────────┤
│ {Database schema change}│ High   │ High        │ Critical  │
│ {External API dependency}│ Medium │ Medium      │ Medium   │
│ {New framework usage}   │ Low    │ High        │ Medium    │
└─────────────────────────────────────────────────────────────┘

🔄 Rollback Strategy
Phase 1: {Easy/Medium/Hard} - {strategy}
Phase 2: {Easy/Medium/Hard} - {strategy}
Phase 3: {Easy/Medium/Hard} - {strategy}

🛡️  Mitigation Recommendations
1. {risk}: {mitigation action}
2. {risk}: {mitigation action}
3. {risk}: {mitigation action}

📋 Pre-Implementation Checklist
- [ ] {Backup existing data before migration}
- [ ] {Create feature flag for gradual rollout}
- [ ] {Prepare rollback script}
- [ ] {Document breaking changes}
```

### Phase-Specific Risk Analysis

Each phase document includes:

| Section | Content |
|---------|---------|
| Risk Summary | Top 3 risks for this phase |
| Dependencies | What this phase depends on |
| Impact Scope | What this phase affects |
| Rollback Plan | How to undo changes |
| Mitigation | Actions to reduce risk |

### Risk Triggers

| Trigger | Risk Level Increase |
|---------|-------------------|
| Database migration | +2 |
| External API integration | +1 |
| Shared component change | +2 |
| New technology stack | +1 |
| Authentication/Authorization | +1 |
| Data encryption | +1 |
| Breaking API change | +3 |

### Integration with Phase Proposal

Risk analysis affects phase planning:
- High-risk items → Dedicated phase or early phase
- Critical risks → May split into smaller phases
- Rollback complexity → Influences phase ordering

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

## Validation (Step 7.5)

Verify completeness and consistency of collected information before generating documents.

### Validation Categories

| Category | Description | Severity |
|----------|-------------|----------|
| Completeness | Required sections filled | Error |
| Consistency | Cross-reference matching | Error |
| Dependency | Phase ordering valid | Error |
| Coverage | Risk/Error handling complete | Warning |
| Quality | Best practices followed | Info |

### Validation Rules

```
1. Completeness Checks
   ✓ Feature name defined
   ✓ Core goal specified
   ✓ At least one use case defined
   ✓ Architecture selected
   ✓ Phase structure confirmed
   ✓ Risk assessment for high-risk phases

2. Consistency Checks
   ✓ Use cases in OVERVIEW match Phase documents
   ✓ API endpoints consistent across documents
   ✓ Error codes defined in OVERVIEW used in Phases
   ✓ Dependencies reference existing phases
   ✓ Architecture patterns applied consistently

3. Dependency Checks
   ✓ No circular phase dependencies
   ✓ Phase 1 has no internal dependencies
   ✓ All referenced phases exist
   ✓ External dependencies documented

4. Coverage Checks
   ✓ Critical/High risks have mitigations
   ✓ All API endpoints have error handling
   ✓ Security requirements addressed
   ✓ Rollback plans for risky phases

5. Quality Checks
   ✓ Naming conventions followed
   ✓ File structure matches architecture
   ✓ No duplicate functionality across phases
```

### Validation Output Format

```
🔍 Validation Results

┌─────────────────────────────────────────────────────────────┐
│ Category        │ Status │ Issues                           │
├─────────────────────────────────────────────────────────────┤
│ Completeness    │ ✅ Pass │ All required fields present      │
│ Consistency     │ ⚠️ Warn │ 2 issues found                   │
│ Dependency      │ ✅ Pass │ Phase order valid                │
│ Coverage        │ ⚠️ Warn │ 1 issue found                    │
│ Quality         │ ✅ Pass │ Conventions followed             │
└─────────────────────────────────────────────────────────────┘

Overall: ⚠️ 3 Warnings, 0 Errors

⚠️  Warnings:
1. [Consistency] UC-03 in Phase 2 not defined in OVERVIEW Use Cases
2. [Consistency] Endpoint /api/users/{id} missing in Phase 1 but referenced in Phase 2
3. [Coverage] Risk "Database migration" (Critical) has no rollback script prepared

💡 Recommendations:
- Add UC-03 definition to OVERVIEW Use Cases section
- Include /api/users/{id} endpoint in Phase 1 Interface Details
- Add rollback script preparation to Phase 1 Pre-Implementation Checklist

Proceed to Preview? (Warnings will be shown in document previews)
```

### Severity Levels

| Level | Symbol | Action |
|-------|--------|--------|
| Error | ❌ | Must fix before proceeding |
| Warning | ⚠️ | Recommended to fix, can proceed |
| Info | ℹ️ | Suggestion for improvement |

### Error Handling

**If Errors Found:**
```
❌ Validation Failed - 2 Errors Found

Errors must be resolved before proceeding:

1. [Completeness] No use cases defined
   → Go back to Step 5 and define at least one use case

2. [Dependency] Circular dependency: Phase 2 → Phase 3 → Phase 2
   → Restructure phases to remove circular reference

Options:
- [Fix issues] Return to relevant step
- [Override] Proceed anyway (not recommended)
```

**If Warnings Only:**
```
⚠️ Validation Passed with Warnings

3 warnings found. You can:
- [Fix now] Address warnings before preview
- [Proceed] Continue to preview (warnings shown in documents)
- [Ignore] Mark warnings as accepted
```

### Validation Integration with Preview

Warnings appear in document previews:

```
📋 Document Preview: 01_FOUNDATION.md

⚠️ Validation Warnings for this document:
- UC-03 referenced but not defined in OVERVIEW
- Endpoint /api/users/{id} not included

─────────────────────────────────────────────
# Phase 1: Foundation
...
(document content)
...
─────────────────────────────────────────────

[Approve] [Fix warnings] [Skip]
```

### Auto-Fix Suggestions

For common issues, provide auto-fix options:

| Issue | Auto-Fix |
|-------|----------|
| Missing use case reference | Add to OVERVIEW Use Cases |
| Missing error code | Generate standard error code |
| Missing rollback plan | Add template rollback section |
| Naming inconsistency | Rename to match convention |

```
💡 Auto-Fix Available

Issue: UC-03 not defined in OVERVIEW
Suggested fix: Add "UC-03: {Phase 2 use case description}" to OVERVIEW

[Apply fix] [Fix manually] [Ignore]
```

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
