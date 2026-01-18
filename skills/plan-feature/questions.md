# Q&A Template

Question format for interactive requirements gathering.

**Rules:**
- All questions include "Generate design docs" option
- AskUserQuestion: Max 4 options
- To modify previous answer: Select "Other" then input

---

## Step 0: Session Check

Before starting, check for existing session state.

### Check Logic

```
1. Check if .plan-feature/{feature_name}/state.md exists
2. If exists → Show resume prompt
3. If not exists → Proceed to Step 1
```

### Resume Prompt Display

```
📋 Found Existing Session

Feature: {feature_name}
Progress: Step {N} of 9 ({step_name})
Last Updated: {timestamp}

Previous session context:
- {decision_1}
- {decision_2}
- {preference_1}
```

### Question: Session Resume

```json
{
  "questions": [{
    "header": "Session",
    "question": "Found existing session for '{feature_name}'. How would you like to proceed?",
    "multiSelect": false,
    "options": [
      {"label": "Resume", "description": "Continue from Step {N} ({step_name})"},
      {"label": "Start fresh", "description": "Delete existing state and start over"},
      {"label": "View state", "description": "Show full state before deciding"}
    ]
  }]
}
```

### Behavior by Selection

| Selection | Action |
|-----------|--------|
| Resume | Load state.md, jump to current step |
| Start fresh | Delete .plan-feature/{feature_name}/, start Step 1 |
| View state | Display full state.md content, ask again |

---

## Step 1: Check Configuration

Read `config.yaml` from the skill folder:

```yaml
# Defaults (when no config file exists)
project:
  name: "my-project"
  language: other

paths:
  source: "src"
  apps: "apps"
  plans: "docs/plans"

integrations: []  # Define per project

storage:
  - label: "SQLite"
    description: "Lightweight embedded DB"
    recommended: true
  - label: "PostgreSQL"
    description: "Production DB"
  - label: "Memory only"
    description: "Resets on restart"
  - label: "File-based"
    description: "JSON/YAML files"
```

---

## Step 2: Basic Information (Required)

### Question 1: Feature Name Confirmation

```json
{
  "questions": [{
    "header": "Feature Name",
    "question": "Converting '{user mentioned feature}' to snake_case gives '{converted_name}'. Is this correct?",
    "options": [
      {"label": "Yes, correct", "description": "Proceed with this name"},
      {"label": "Use different name", "description": "Enter manually"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ],
    "multiSelect": false
  }]
}
```

### Question 2: Core Goal

```json
{
  "questions": [{
    "header": "Core Goal",
    "question": "What is the most important goal for this feature?",
    "options": [
      {"label": "Real-time processing", "description": "Needs immediate response"},
      {"label": "Batch processing", "description": "Process periodically in bulk"},
      {"label": "Data collection", "description": "Gather and store information"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ],
    "multiSelect": false
  }]
}
```

---

## Step 3: Intelligent Codebase Analysis

No questions - automatic deep analysis using Task tool with Explore agent.

### Analysis Steps

```
1. Structure Scan
   - Glob: {config.paths.source}/**/*
   - Identify directory patterns
   - Detect architecture style

2. Component Discovery
   - Grep: "type.*struct" (Go), "class.*{" (TS/Java), "def.*:" (Python)
   - Find interfaces, types, classes
   - Identify shared utilities

3. Dependency Analysis
   - Grep: import/require statements
   - Map module relationships
   - Detect potential reuse

4. Pattern Recognition
   - Check for common patterns (Repository, Service, Handler)
   - Identify naming conventions
   - Find configuration patterns
```

### Language-Specific Analysis

**Go:**
```bash
# Find types and interfaces
grep -r "type.*struct\|type.*interface" {source}/
# Find packages
ls -d {source}/*/
# Check go.mod for dependencies
cat go.mod
```

**TypeScript:**
```bash
# Find classes and interfaces
grep -r "class.*{$\|interface.*{$\|type.*=" {source}/
# Check package.json
cat package.json
```

**Python:**
```bash
# Find classes
grep -r "class.*:" {source}/
# Check requirements
cat requirements.txt
```

### Architecture Detection Rules

| Directory Pattern | Detected Architecture | Confidence |
|-------------------|----------------------|------------|
| `domain/`, `usecase/`, `adapter/` | Clean Architecture | High |
| `models/`, `views/`, `controllers/` | MVC | High |
| `api/`, `service/`, `repository/` | Layered | High |
| `ports/`, `adapters/` | Hexagonal | High |
| `modules/{name}/` | Modular Monolith | Medium |
| `{feature}/handler.go`, `{feature}/service.go` | Feature-based | Medium |
| Single `src/` or `internal/` | Undetermined | Low |

### Reusable Component Identification

Scan for common reusable components:

| Component Type | Search Pattern | Reuse Potential |
|---------------|----------------|-----------------|
| Database client | `db`, `database`, `store` | High |
| HTTP client | `client`, `http`, `api` | High |
| Logger | `log`, `logger` | High |
| Config loader | `config`, `cfg`, `env` | High |
| Validators | `valid`, `validator` | Medium |
| Middleware | `middleware`, `interceptor` | Medium |
| Utils/Helpers | `util`, `helper`, `common` | Medium |

### Output to Interim Summary 1

```
🔍 Codebase Analysis Results

Architecture: {detected} ({confidence} confidence)
Language: {language}

📁 Directory Structure
{source}/
├── {dir1}/     ← {layer_type}: {description}
├── {dir2}/     ← {layer_type}: {description}
└── {dir3}/     ← {layer_type}: {description}

♻️  Reusable Components Found
| Component | Location | Type | Recommendation |
|-----------|----------|------|----------------|
| {name1} | {path1} | {type1} | Direct reuse |
| {name2} | {path2} | {type2} | Extend |
| {name3} | {path3} | {type3} | Reference pattern |

🔗 Existing Integrations
- {integration1}: {path} - {status}
- {integration2}: {path} - {status}

📋 Recommendations for {feature_name}
- Follow {architecture} pattern
- Reuse {component} for {purpose}
- Create new {component_type} in {suggested_path}/
- Consider {existing_module} integration

⚠️  Notes
- {warning_or_consideration}
```

---

## Interim Summary 1

```
📋 Information collected so far:
- Feature name: {feature_name}
- Core goal: {goal}
- Related modules: {modules}

Continue with more questions?
```

---

## Step 4: Architecture Questions

### Question 3: System Integration (multiSelect)

**When integrations exist in config:**
```json
{
  "questions": [{
    "header": "Integration",
    "question": "Which existing systems need integration?",
    "multiSelect": true,
    "options": [
      // Dynamically generated from config.integrations (max 3)
      {"label": "{integration.label}", "description": "{integration.description} ({integration.path})"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**When no integrations in config (default):**
```json
{
  "questions": [{
    "header": "Integration",
    "question": "Which existing systems need integration?",
    "multiSelect": true,
    "options": [
      {"label": "Database", "description": "Needs DB integration"},
      {"label": "External API", "description": "Call external services"},
      {"label": "None", "description": "New independent module"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 4: Data Storage

```json
{
  "questions": [{
    "header": "Data Storage",
    "question": "How should data be stored? (Select 'Other' to modify previous answer)",
    "multiSelect": false,
    "options": [
      // Dynamically generated from config.storage or use defaults
      {"label": "SQLite (Recommended)", "description": "Lightweight embedded DB"},
      {"label": "Memory only", "description": "Resets on restart"},
      {"label": "File-based", "description": "Save as JSON/YAML files"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 5: API Endpoints

```json
{
  "questions": [{
    "header": "API",
    "question": "Do you need externally accessible API? (Select 'Other' to modify previous answer)",
    "multiSelect": false,
    "options": [
      {"label": "Yes, REST API", "description": "Add HTTP endpoints"},
      {"label": "No", "description": "Internal use only"},
      {"label": "Redo previous question", "description": "Modify previous answer"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

---

## Interim Summary 2

```
📋 Information collected so far:
- Feature name: {feature_name}
- Core goal: {goal}
- Architecture: {detected_architecture} (from codebase)
- Integration: {systems}
- Storage: {storage}
- API: {api}

Continue with functional design questions?
```

---

## Step 5: Functional Design (Required)

### Question 8: Core Use Cases

```json
{
  "questions": [{
    "header": "Use Cases",
    "question": "What are the core use cases for this feature?",
    "multiSelect": true,
    "options": [
      {"label": "CRUD operations", "description": "Create, Read, Update, Delete"},
      {"label": "Data processing", "description": "Transform, aggregate, analyze"},
      {"label": "User interaction", "description": "Forms, validation, feedback"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**Follow-up if "Other" selected:**
- Ask user to describe specific use cases
- Format: "As a {user}, I want to {action} so that {benefit}"

### Question 9: Interface Specification

```json
{
  "questions": [{
    "header": "Interface",
    "question": "How detailed should the interface specification be?",
    "multiSelect": false,
    "options": [
      {"label": "Detailed spec", "description": "Define each endpoint with request/response"},
      {"label": "Standard patterns", "description": "Use RESTful conventions"},
      {"label": "Minimal", "description": "Define during implementation"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**If "Detailed spec" selected, follow-up:**
```json
{
  "questions": [{
    "header": "Endpoints",
    "question": "Which operations need explicit interface definition?",
    "multiSelect": true,
    "options": [
      {"label": "List/Query", "description": "GET with filters, pagination"},
      {"label": "Create", "description": "POST with validation rules"},
      {"label": "Update/Delete", "description": "PUT/PATCH/DELETE operations"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 10: Error Handling Strategy

```json
{
  "questions": [{
    "header": "Errors",
    "question": "How should errors be handled?",
    "multiSelect": false,
    "options": [
      {"label": "Comprehensive", "description": "Define error codes, messages, recovery"},
      {"label": "Standard pattern", "description": "Follow project's existing error handling"},
      {"label": "Basic", "description": "Standard HTTP status codes only"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**If "Comprehensive" selected, include in design:**
- Error code taxonomy (e.g., E001, E002)
- User-facing error messages
- Recovery/retry strategies
- Logging requirements

### Question 11: Security & Validation (Optional)

```json
{
  "questions": [{
    "header": "Security",
    "question": "What security and validation requirements apply?",
    "multiSelect": true,
    "options": [
      {"label": "Authentication", "description": "Login required for access"},
      {"label": "Authorization", "description": "Role-based permissions"},
      {"label": "Input validation", "description": "Strict input sanitization"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

---

## Interim Summary 3

```
📋 Functional Design Summary:
- Use cases: {use_cases}
- Interface: {interface_level}
- Error handling: {error_strategy}
- Security: {security_requirements}

Proceeding to implementation pattern selection...
```

---

## Step 5.5a: Feature Size Assessment

After collecting functional design, automatically assess feature size.

### Size Calculation

```
score = (use_cases × 2) + (integrations × 3) + (risk_level × 2)

Thresholds:
- score < 15: Normal → Continue to Step 5.5
- score 15-25: Large → Show warning, ask user
- score > 25: Too Large → Recommend decomposition
```

### Large Feature Warning Display

```
⚠️ Feature Size Assessment

This feature appears large:
- Use cases: {count}
- Estimated phases: {count}
- Integrations: {count}
- Risk level: {level}

Recommendations:
1. Split into sub-features:
   ├── {feature_name}-core (Use cases 1-4)
   ├── {feature_name}-integration (Use cases 5-8)
   └── {feature_name}-advanced (Use cases 9-12)

2. Or continue with session splitting:
   → Complete design in multiple sessions
   → Use --continue to resume
```

### Question: Feature Size Decision

```json
{
  "questions": [{
    "header": "Size",
    "question": "This feature is large ({score} score). How would you like to proceed?",
    "multiSelect": false,
    "options": [
      {"label": "Split feature", "description": "Decompose into smaller features"},
      {"label": "Continue", "description": "Proceed with current scope (use sessions)"},
      {"label": "Simplify", "description": "Reduce scope by removing use cases"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Follow-up: Split Feature

If "Split feature" selected:
- Show suggested sub-features with use case groupings
- Ask which sub-feature to design first
- Create separate plan-feature sessions for each

### Follow-up: Simplify

If "Simplify" selected:
```json
{
  "questions": [{
    "header": "Reduce",
    "question": "Which use cases should be removed or deferred?",
    "multiSelect": true,
    "options": [
      {"label": "UC-{N}: {name}", "description": "Remove from current scope"},
      {"label": "UC-{N}: {name}", "description": "Remove from current scope"},
      {"label": "UC-{N}: {name}", "description": "Remove from current scope"},
      {"label": "Keep all", "description": "Don't remove any use cases"}
    ]
  }]
}
```

---

## Step 5.5: Implementation Pattern Selection

Based on architecture (from Step 3) and functional requirements (from Step 5), propose implementation patterns.

### Pattern Analysis Output

```
🔧 Implementation Pattern Selection

Architecture: {detected_architecture} (from codebase analysis)

Requirements Summary:
- Use cases: {N} defined ({types})
- Expected volume: {estimated_volume}
- Integrations: {integration_list}
- Processing: {sync/async needs}

Select an implementation pattern for this feature:

┌─────────────────────────────────────────────────────────────┐
│ Option A: Synchronous Processing (Recommended)              │
│ Standard request-response within {detected_architecture}   │
├─────────────────────────────────────────────────────────────┤
│ ✅ Pros                      │ ⚠️  Cons                      │
│ • Simple implementation      │ • Blocks during processing   │
│ • Easy debugging             │ • Limited throughput         │
│ • Follows existing patterns  │ • No automatic retry         │
├─────────────────────────────────────────────────────────────┤
│ Effort: Low | Risk: Low | Throughput: ~1K/min              │
│ Best for: Simple CRUD, low volume, immediate response      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Option B: Async with Worker Pool                            │
│ Background processing with in-process worker pool          │
├─────────────────────────────────────────────────────────────┤
│ ✅ Pros                      │ ⚠️  Cons                      │
│ • Fast API response          │ • Job loss on restart        │
│ • Better throughput          │ • Harder to debug            │
│ • No external dependencies   │ • Limited horizontal scale   │
├─────────────────────────────────────────────────────────────┤
│ Effort: Medium | Risk: Medium | Throughput: ~10K/min       │
│ Best for: Medium volume, single instance, tolerable loss   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Option C: Message Queue Integration                         │
│ External queue for reliable async processing               │
├─────────────────────────────────────────────────────────────┤
│ ✅ Pros                      │ ⚠️  Cons                      │
│ • Reliable delivery          │ • Infrastructure required    │
│ • Auto retry on failure      │ • Higher complexity          │
│ • Horizontal scaling         │ • Eventual consistency       │
├─────────────────────────────────────────────────────────────┤
│ Effort: High | Risk: Medium | Throughput: ~100K/min        │
│ Best for: High volume, reliability critical, distributed   │
└─────────────────────────────────────────────────────────────┘

💡 Recommendation: Option {X}
   Reason: {Based on volume/requirements analysis}
```

### Question 12: Implementation Pattern Selection

```json
{
  "questions": [{
    "header": "Pattern",
    "question": "Which implementation pattern suits this feature?",
    "multiSelect": false,
    "options": [
      {"label": "Option A (Recommended)", "description": "Synchronous - simple, follows existing patterns"},
      {"label": "Option B", "description": "Async Worker - better throughput, in-process"},
      {"label": "Option C", "description": "Message Queue - reliable, scalable"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Follow-up: Custom Pattern

If user selects "Other":

```
Please describe your preferred implementation pattern.

Consider specifying:
- Processing model (sync/async/event-driven)
- Worker mechanism (goroutine pool, thread pool, external queue)
- Retry strategy (none, immediate, exponential backoff)
- Data flow (request-response, fire-and-forget, pub-sub)

I'll incorporate your approach into the design documents.
```

### Pattern Selection Summary

After selection, display:

```
✅ Implementation Pattern Selected: {Option name}

Architecture: {detected_architecture} (unchanged)
Pattern: {selected_pattern}

📁 Component Structure:
{source_path}/{feature}/
├── {standard_components}     ← From {detected_architecture}
└── {additional_components}   ← From {selected_pattern}

🔧 Additional Components:
{If Option B: worker_pool.go, job.go}
{If Option C: queue.go, consumer.go, producer.go}

⚠️  Trade-offs Accepted:
- {Trade-off 1}
- {Trade-off 2}

Proceeding to phase proposal with this pattern...
```

---

## Step 6: Auto Phase Proposal

### Phase Analysis Process

Before asking for confirmation, analyze collected information:

```
1. Count Complexity Factors:
   - Use cases selected: {count}
   - Integrations required: {count}
   - API endpoints needed: {estimated}
   - Security layers: {count}

2. Calculate Recommended Phases:
   - Base: 3 phases (minimum)
   - +1 if integrations > 2
   - +1 if use cases include all types
   - +1 if security includes auth + authz
   - Max: 7 phases

3. Determine Phase Contents:
   Phase 1 (Foundation):
     - Data model setup
     - Basic storage layer
     - Core types/interfaces

   Phase 2+ (Features):
     - Group by dependency
     - One major use case per phase
     - Include related endpoints

   Final Phase (Polish):
     - Error handling refinement
     - Security hardening
     - Performance optimization
```

### Phase Proposal Display

Show this to user before asking:

```
📋 Recommended Phase Structure

Based on your requirements:
- {X} use cases
- {Y} integrations
- {Z} API endpoints
- Security: {level}

I recommend {N} phases:

┌──────────────────────────────────────────────┐
│ Phase 1: Foundation                          │
│ Difficulty: Medium | Impact: High            │
├──────────────────────────────────────────────┤
│ • Data models and types                      │
│ • Storage layer ({storage_type})             │
│ • Base configuration                         │
│ Why first: Required by all other phases      │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ Phase 2: Core Features                       │
│ Difficulty: {diff} | Impact: High            │
├──────────────────────────────────────────────┤
│ • {Primary use case implementation}          │
│ • {Related API endpoints}                    │
│ • Basic error handling                       │
│ Depends on: Phase 1                          │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│ Phase 3: {Additional Features / Integration} │
│ Difficulty: {diff} | Impact: Medium          │
├──────────────────────────────────────────────┤
│ • {Secondary use cases}                      │
│ • {Integration with external systems}        │
│ Depends on: Phase 1, 2                       │
└──────────────────────────────────────────────┘

{... more phases if needed ...}

Dependency Graph:
Phase 1 ──→ Phase 2 ──→ Phase 3
              ↘──→ Phase 4 (parallel possible)
```

### Question 12: Phase Proposal Confirmation

```json
{
  "questions": [{
    "header": "Phase Plan",
    "question": "How would you like to proceed with this {N}-phase structure?",
    "multiSelect": false,
    "options": [
      {"label": "Accept proposal", "description": "Use the suggested {N} phases"},
      {"label": "Fewer phases", "description": "Combine into {N-1} or fewer phases"},
      {"label": "More phases", "description": "Split into {N+1} or more phases"},
      {"label": "Custom structure", "description": "I'll describe my own phases"}
    ]
  }]
}
```

### Follow-up: Fewer Phases

```json
{
  "questions": [{
    "header": "Combine",
    "question": "Which phases should be combined?",
    "multiSelect": false,
    "options": [
      {"label": "Merge 1+2", "description": "Foundation + Core together"},
      {"label": "Merge later phases", "description": "Combine feature phases"},
      {"label": "Minimum (2)", "description": "Foundation + Everything else"},
      {"label": "Back", "description": "Return to original proposal"}
    ]
  }]
}
```

### Follow-up: More Phases

```json
{
  "questions": [{
    "header": "Split",
    "question": "What should be split into separate phases?",
    "multiSelect": true,
    "options": [
      {"label": "Separate each use case", "description": "One use case per phase"},
      {"label": "Separate integrations", "description": "Each integration = 1 phase"},
      {"label": "Isolate security", "description": "Dedicated security phase"},
      {"label": "Back", "description": "Return to original proposal"}
    ]
  }]
}
```

### Follow-up: Custom Structure

```
Please describe your preferred phase structure.

Format:
- Phase 1: {name} - {what it includes}
- Phase 2: {name} - {what it includes}
...

I'll validate dependencies and adjust the design documents accordingly.
```

---

## Step 6.5: Risk Analysis Summary

After phase structure is confirmed, display risk analysis:

```
⚠️  Risk Assessment Summary

Overall Risk Level: {Low/Medium/High/Critical}

┌─────────────────────────────────────────────────────────────┐
│ Risk                     │ Impact │ Probability │ Level     │
├─────────────────────────────────────────────────────────────┤
│ {Database schema change} │ High   │ High        │ Critical  │
│ {External API dependency}│ Medium │ Medium      │ Medium    │
│ {New framework usage}    │ Low    │ High        │ Medium    │
└─────────────────────────────────────────────────────────────┘

Phase-Specific Risks:
┌─────────────────────────────────────────────────────────────┐
│ Phase │ Risk Level │ Top Risk               │ Rollback     │
├─────────────────────────────────────────────────────────────┤
│ 1     │ High       │ Database migration     │ Hard         │
│ 2     │ Medium     │ API integration        │ Medium       │
│ 3     │ Low        │ UI changes             │ Easy         │
└─────────────────────────────────────────────────────────────┘

🛡️  Key Mitigations:
1. {risk}: {mitigation action}
2. {risk}: {mitigation action}
3. {risk}: {mitigation action}

📋 Pre-Implementation Checklist:
- [ ] Backup existing data/schema before Phase 1
- [ ] Create feature flags for gradual rollout
- [ ] Prepare rollback scripts for each phase
- [ ] Document all breaking changes

Proceed to generate design documents with this risk assessment?
```

### Risk Detection Rules

Apply these rules to identify risks:

| Trigger | Risk Category | Level Increase |
|---------|---------------|----------------|
| Database migration | Technical | +2 (Critical) |
| External API integration | Dependency | +1 (High) |
| Shared component change | Integration | +2 (Critical) |
| New technology stack | Technical | +1 (High) |
| Authentication/Authorization | Security | +1 (High) |
| Data encryption | Security | +1 (High) |
| Breaking API change | Integration | +3 (Critical) |
| Multiple system coordination | Integration | +1 (High) |

### Rollback Difficulty Assessment

| Change Type | Rollback | Strategy |
|-------------|----------|----------|
| Database schema change | Hard | Backup required, migration script rollback |
| Data migration | Hard | Point-in-time restore |
| Config change | Easy | Revert config file |
| Code change only | Medium | Git revert, redeploy |
| Feature flag guarded | Easy | Disable flag |
| External integration | Medium | Fallback mechanism |

---

## Step 7: Details (Optional)

### Question 14: Priority

```json
{
  "questions": [{
    "header": "Priority",
    "question": "Should we separate MVP (minimum features) from extensions?",
    "multiSelect": false,
    "options": [
      {"label": "Yes, in phases", "description": "Implement in phases"},
      {"label": "No, all at once", "description": "All features together"},
      {"label": "Redo previous question", "description": "Modify previous answer"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 15: Scheduling

```json
{
  "questions": [{
    "header": "Scheduling",
    "question": "Are there tasks that need to run periodically? (Select 'Other' to modify previous answer)",
    "multiSelect": false,
    "options": [
      {"label": "Yes, cron schedule", "description": "Run at fixed times"},
      {"label": "Yes, event-based", "description": "Run on specific conditions"},
      {"label": "No", "description": "Manual execution only"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

---

## Step 7.5: Validation

Automatically validate collected information before preview.

### Validation Output

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
2. [Consistency] Endpoint /api/users/{id} missing in Phase 1 but referenced
3. [Coverage] Risk "Database migration" (Critical) has no rollback script

💡 Recommendations:
- Add UC-03 definition to OVERVIEW Use Cases section
- Include /api/users/{id} endpoint in Phase 1 Interface Details
- Add rollback script to Phase 1 Pre-Implementation Checklist
```

### Validation Check Rules

| Category | Check | Severity |
|----------|-------|----------|
| Completeness | Feature name defined | Error |
| Completeness | Core goal specified | Error |
| Completeness | At least one use case | Error |
| Completeness | Architecture selected | Error |
| Consistency | Use cases match across docs | Error |
| Consistency | API endpoints consistent | Warning |
| Consistency | Error codes mapped | Warning |
| Dependency | No circular dependencies | Error |
| Dependency | Phase 1 no internal deps | Error |
| Coverage | Critical risks have mitigation | Warning |
| Coverage | API endpoints have error handling | Warning |
| Quality | Naming conventions | Info |
| Quality | File structure matches arch | Info |

### User Decision After Validation

```json
{
  "questions": [{
    "header": "Validation",
    "question": "Validation complete with {N} warnings. How to proceed?",
    "multiSelect": false,
    "options": [
      {"label": "Proceed to preview", "description": "Warnings will appear in document previews"},
      {"label": "Fix warnings first", "description": "Address issues before preview"},
      {"label": "Ignore warnings", "description": "Mark as accepted and proceed"}
    ]
  }]
}
```

### Error Handling

If errors found, must resolve before proceeding:

```
❌ Validation Failed - {N} Errors

1. [Completeness] No use cases defined
   → Return to Step 5 to define use cases

2. [Dependency] Circular: Phase 2 → Phase 3 → Phase 2
   → Restructure phases in Step 6

[Fix issues] [Override (not recommended)]
```

### Preview Integration

Warnings appear in each document preview:

```
📋 Document Preview: 01_FOUNDATION.md

⚠️ Warnings:
- UC-03 referenced but not defined
- Missing error handling for /api/users

───────────────────────────────────
(document content)
───────────────────────────────────

[Approve] [Fix warnings] [Skip]
```

---

## Special Behaviors

### When "Other" selected then "redo previous question" entered
- Show previous question again
- Ignore previous answer and collect new one

### When "Generate design docs" selected
- Generate documents immediately with current information
- Use reasonable defaults for missing information
