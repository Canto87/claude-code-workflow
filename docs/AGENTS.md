# Agent System Guide

This document explains the agent system in claude-code-workflow, providing automated code modification, analysis, and quality assurance capabilities.

## Table of Contents

- [Overview](#overview)
- [Agent Catalog](#agent-catalog)
- [Hierarchical Execution](#hierarchical-execution)
- [Scoring System](#scoring-system)
- [Installation](#installation)
- [Usage Examples](#usage-examples)
- [Creating Custom Agents](#creating-custom-agents)

---

## Overview

Agents are specialized Claude Code components that handle specific types of tasks autonomously. They:

- **Conserve main context** by running as subagents
- **Follow strict protocols** for predictable behavior
- **Produce structured output** for easy parsing and automation
- **Support score-based quality gates** for automated QA pipelines

### Skills vs Agents

| Aspect | Skills | Agents |
|--------|--------|--------|
| **Location** | `.claude/skills/` | `.claude/agents/` |
| **Invocation** | Slash commands (`/plan-feature`) | Task tool (`subagent_type: "code-edit"`) |
| **Context** | Run in main conversation | Run as subagents |
| **Tool Access** | Full (including Task tool) | Limited by definition |
| **Primary Use** | User-facing workflows | Automation building blocks |

---

## Agent Catalog

### code-edit

**Purpose**: Single-task code modifications

**Capabilities**:
- File discovery and analysis
- Change planning with scope tiers
- Code modification with rollback support
- Build/test verification
- Automatic commit generation

**Input**:
```
task: Fix null check in auth/login.ts
target: src/auth/
constraints: Don't modify auth/config.ts
--scope file
```

**Output**: Success/failure report with modified files list

**Scope Tiers**:
| Scope | Max Files | Use Case |
|-------|-----------|----------|
| `file` | 3 | Bug fixes, small changes |
| `module` | 10 | Refactoring, feature additions |
| `cross-module` | 20 | API changes, architecture updates |

---

### auto-impl

**Purpose**: Phase automation orchestrator

**Capabilities**:
- Parses Phase commands from init-impl
- Delegates tasks to code-edit agent
- Maintains checkpoints in checklists
- Handles retries and scope escalation

**Input**:
```
feature: user-auth
phase: 1
--no-commit
```

**Output**: Progress report with task completion status

**Delegation Protocol**:
1. Extract tasks from Phase command
2. For each task: delegate to code-edit
3. Parse code-edit result
4. On success: update checklist, commit
5. On failure: retry with additional context or escalate scope

---

### code-analyze

**Purpose**: Read-only codebase analysis

**Capabilities**:
- Architecture mapping
- Implementation detail extraction
- Change impact analysis
- Pattern discovery

**Modes**:
| Mode | Focus |
|------|-------|
| `architecture` | Component relationships, data flow |
| `implementation` | Core logic, error handling, concurrency |
| `change-impact` | Affected files, modification order |
| `pattern` | Coding conventions, reference implementations |

**Depth Levels**:
- `quick`: 3-5 files, ~80 lines output
- `standard`: 8-15 files, ~150 lines output
- `deep`: Full exploration, ~250 lines output

---

### code-review

**Purpose**: Code quality evaluation

**Capabilities**:
- Multi-category review (6 categories, 25 items)
- Project pattern compliance checking
- Security vulnerability detection
- Weighted scoring system

**Categories**:
| Category | Weight | Focus |
|----------|--------|-------|
| Correctness | 25% | Logic errors, race conditions, resource leaks |
| Error Handling | 20% | Proper wrapping, no ignored errors |
| Security | 20% | Injection, hardcoded secrets, auth |
| Project Patterns | 15% | CLAUDE.md conventions |
| Readability | 10% | Function length, nesting, naming |
| Test Quality | 10% | Test coverage and meaningfulness |

---

### validate

**Purpose**: Dual-mode verification

**Mode 1: Artifact Validation**
```
/validate user-auth artifacts
```
Checks consistency between:
- Design documents
- Checklists
- Phase commands

**Mode 2: Implementation Validation**
```
/validate user-auth phase1
```
Verifies:
- Build/test pass
- Acceptance Criteria fulfillment
- Checklist completion
- Code quality patterns

---

## Hierarchical Execution

Agents can call other agents, creating a hierarchy:

```
supervisor (skill)
    │
    ├── auto-impl (agent)
    │       └── code-edit (agent)
    │
    ├── code-review (agent)
    │
    └── validate (agent)
```

### Model Strategy

Agents use different models for different tasks:

| Task Type | Model | Reason |
|-----------|-------|--------|
| File exploration, diff collection | Sonnet | Cost-effective |
| Deep analysis, scoring | Opus | Higher quality |
| Code modification | Opus | Accuracy critical |

Example from code-review agent:
```
Step 1-2: Task(model="sonnet") for file collection
Step 3-4: Opus directly for quality judgment
```

---

## Scoring System

### Score Calculation

Per-item scores:
| Judgment | Score |
|----------|-------|
| Pass | 10 |
| Warning | 5 |
| Fail | 0 |
| N/A | (excluded) |

Category score = Average of applicable items
Overall score = Weighted sum of category scores

### Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 9-10 | Excellent | Ready to proceed/merge |
| 7-8 | Good | Minor fixes recommended |
| 5-6 | Needs Work | Fixes required |
| 0-4 | Fail | Significant rework needed |

### Gate Decisions (in supervisor)

| Score | Critical Issues | Decision |
|-------|-----------------|----------|
| 7+ | None | PASS |
| 5-6 | Any | RETRY |
| 7+ | Present | RETRY |
| 0-4 | Any | REJECT |

---

## Installation

### Install All Agents
```bash
./install.sh --agents
```

### Install Specific Agents
```bash
./install.sh --agents=code-edit,code-review
```

### Install with Supervisor Pipeline
```bash
./install.sh --with-supervisor
```

### Verify Installation
```bash
ls -la .claude/agents/
# Expected: code-edit.md, auto-impl.md, validate.md, code-analyze.md, code-review.md
```

---

## Usage Examples

### Direct Agent Invocation

Agents are invoked through natural language that Claude interprets:

```
# Analysis
"Analyze the authentication module architecture"
→ Uses code-analyze agent

# Review
"Review the changes in src/api/ for security issues"
→ Uses code-review agent

# Modification
"Fix the null check bug in auth/session.ts"
→ Uses code-edit agent
```

### Programmatic Invocation (in CLAUDE.md)

Define delegation rules in your project's CLAUDE.md:

```markdown
### Plan Mode → Implementation Rules

| Task Type | Tool | Reason |
|-----------|------|--------|
| Code modification (3+ files) | code-edit agent | Save main context |
| Multi-file changes (Phase) | auto-impl agent | Orchestration |
| Code analysis | code-analyze agent | Read-only |
| Code quality check | code-review agent | Evaluation |
```

### Supervisor Pipeline

```
/supervisor user-auth phase1
```

Executes:
1. **IMPLEMENT**: auto-impl delegates tasks to code-edit
2. **REVIEW**: code-review evaluates changes (7+ to pass)
3. **VALIDATE**: validate checks AC fulfillment (7+ to pass)

---

## Creating Custom Agents

### Agent Definition Structure

Create a `.md` file in `.claude/agents/`:

```markdown
---
name: my-agent
description: >
  Brief description of what this agent does.
  Keywords that trigger this agent.
tools: Read, Write, Edit, Bash, Glob, Grep
disallowedTools: Task
model: opus
permissionMode: acceptEdits
---

# Agent Title

## Role
Detailed description of the agent's purpose.

## Input Parsing
How to extract information from user input.

## Execution Flow
Step-by-step process the agent follows.

## Output Format
Structure of the agent's output.

## Important Rules
Constraints and requirements.
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Agent identifier |
| `description` | Yes | Purpose and trigger keywords |
| `tools` | Yes | Comma-separated list of allowed tools |
| `disallowedTools` | No | Tools explicitly denied |
| `model` | No | Model preference (opus, sonnet) |
| `permissionMode` | No | How to handle permissions |

### Best Practices

1. **Single Responsibility**: One agent, one purpose
2. **Clear Output**: Structured, parseable output
3. **Error Handling**: Define rollback procedures
4. **Model Strategy**: Use Sonnet for exploration, Opus for judgment
5. **Scope Limits**: Define clear boundaries
6. **Read-Only When Possible**: Use `disallowedTools: Write, Edit` for analysis agents

---

## Related Documentation

- [DELEGATION.md](./DELEGATION.md) - Task delegation rules
- [examples/advanced-workflow.md](../examples/advanced-workflow.md) - Advanced usage guide
- [examples/CLAUDE.md.example](../examples/CLAUDE.md.example) - Project configuration template
