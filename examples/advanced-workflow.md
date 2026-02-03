# Advanced Workflow: Agent System

This document explains the advanced agent-based workflow for larger projects and teams that need automated quality assurance.

## Simple vs Advanced Workflow

### Simple Workflow (Default)
Uses only skills, suitable for most projects:

```
/plan-feature → /init-impl → Manual implementation → /status → /review
```

**Best for:**
- Small to medium projects
- Solo developers
- Quick iterations

### Advanced Workflow (With Agents)
Adds automated implementation and QA pipeline:

```
/plan-feature → /init-impl → /supervisor → Automated QA
```

**Best for:**
- Large projects with many files
- Teams needing consistent quality
- Complex features spanning multiple modules

---

## Agent Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    SKILL LAYER                              │
│  ┌──────────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ plan-feature │  │ init-impl│  │      supervisor      │  │
│  │   (design)   │  │ (setup)  │  │  (QA orchestrator)   │  │
│  └──────────────┘  └──────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    AGENT LAYER                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────┐    │
│  │ auto-impl  │──│ code-edit  │  │                    │    │
│  │(orchestr.) │  │ (worker)   │  │    code-analyze    │    │
│  └────────────┘  └────────────┘  │    (read-only)     │    │
│  ┌────────────┐  ┌────────────┐  │                    │    │
│  │code-review │  │  validate  │  └────────────────────┘    │
│  │(evaluator) │  │(validator) │                            │
│  └────────────┘  └────────────┘                            │
└─────────────────────────────────────────────────────────────┘
```

### Skill Layer
- **plan-feature**: Interactive design document generation
- **init-impl**: Generate checklists and commands from designs
- **supervisor**: QA pipeline orchestrator (implement → review → validate)

### Agent Layer
- **auto-impl**: Phase automation orchestrator (delegates to code-edit)
- **code-edit**: Single-task code modification worker
- **code-analyze**: Read-only codebase analysis
- **code-review**: Code quality evaluation with scoring
- **validate**: Artifact and implementation validation

---

## Supervisor Pipeline

The supervisor skill chains three agents with score-based gates:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  IMPLEMENT  │────▶│   REVIEW    │────▶│  VALIDATE   │
│ (auto-impl) │     │(code-review)│     │ (validate)  │
└─────────────┘     └──────┬──────┘     └──────┬──────┘
                           │                   │
                    ┌──────▼──────┐     ┌──────▼──────┐
                    │ REVIEW GATE │     │VALIDATE GATE│
                    │ Score: 7+   │     │ Score: 7+   │
                    │ = PASS      │     │ = PASS      │
                    └─────────────┘     └─────────────┘
```

### Gate Logic

| Score | Critical Issues | Decision |
|-------|-----------------|----------|
| 7-10 | None | **PASS** → Next stage |
| 5-6 | Any | **RETRY** → Fix and re-review |
| 7-10 | Present | **RETRY** → Fix critical issues |
| 0-4 | Any | **REJECT** → Manual intervention |

### Retry Limits
- Review Gate: 2 retries max
- Validate Gate: 1 retry max
- Total: 3 retries max across pipeline

---

## Usage Examples

### Full Pipeline
```
# Design the feature
/plan-feature user-authentication

# Generate implementation system
/init-impl user-authentication

# Run automated QA pipeline
/supervisor user-authentication phase1
```

### Skip Implementation (Review Existing Code)
```
/supervisor user-authentication phase1 --skip-impl
```

### Dry Run (See Plan Without Executing)
```
/supervisor user-authentication phase1 --dry-run
```

### Manual Agent Invocation

**Analyze before changing:**
```
Analyze the authentication module architecture
→ Uses code-analyze agent
```

**Review specific files:**
```
Review src/auth/login.ts for security issues
→ Uses code-review agent
```

**Single-task modification:**
```
Fix the null check bug in auth/session.ts
→ Uses code-edit agent
```

---

## Adoption Path

Start simple and adopt agents progressively:

### Level 1: Skills Only (Default)
- `/plan-feature` for design
- `/init-impl` for setup
- Manual implementation
- `/review` for quality check

### Level 2: Add Analysis
- Use `code-analyze` agent for understanding codebase
- Use `code-review` agent for pre-merge checks
- Still implement manually

### Level 3: Automated Implementation
- Use `auto-impl` agent for Phase automation
- Manual review and validation

### Level 4: Full QA Pipeline
- Use `supervisor` skill for complete automation
- Score-based gate decisions
- Minimal manual intervention

---

## Installation

### Skills Only (Default)
```bash
./install.sh
```

### With Agents
```bash
./install.sh --agents
```

### With Supervisor Pipeline
```bash
./install.sh --with-supervisor
```

### Selective Installation
```bash
./install.sh --agents=code-edit,code-review
```

---

## Best Practices

### 1. Start with Analysis
Before major changes, run code-analyze to understand impact:
```
Analyze the payment module for change impact
```

### 2. Use Appropriate Scope
- 1-3 files: Let code-edit use `file` scope
- 4-10 files: Use `module` scope
- 10+ files: Use `cross-module` scope

### 3. Review Before Validate
The supervisor pipeline enforces this order:
- Review catches code quality issues
- Validate catches AC compliance issues

### 4. Don't Skip Gates
If a gate fails repeatedly:
- Don't bypass it
- Investigate the root cause
- Fix fundamentally, not superficially

### 5. Trust the Scores
- 7+: Safe to proceed
- 5-6: Worth fixing before merge
- <5: Significant issues need attention
