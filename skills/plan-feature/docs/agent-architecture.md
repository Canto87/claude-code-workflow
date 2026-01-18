# Agent Architecture Design

> **Status**: Future Enhancement
> **Priority**: Low (implement when current approach hits limits)
> **Last Updated**: 2024-01-18

This document outlines the agent-based architecture for plan-feature skill, to be implemented when the current state management approach becomes insufficient.

## When to Implement Agent Architecture

Consider implementing agents when:

| Trigger | Threshold |
|---------|-----------|
| Average feature size | > 15 use cases regularly |
| Session failures | > 30% due to context limits |
| User complaints | About conversation context loss |
| Feature complexity | Multi-team, cross-domain features |

## Design Principles

### 1. Preserve Conversational Q&A

The core strength of plan-feature is interactive Q&A. Any agent architecture must:

- **Maintain natural conversation flow** within each agent
- **Preserve context** for follow-up questions
- **Support "as I mentioned earlier"** style references

### 2. Skill-Driven Agents (Not Spec-Driven)

Use natural language prompts with clear examples, not rigid YAML schemas.

```
Why Skill-Driven:
- LLMs understand natural language better than schemas
- More flexible, graceful degradation on edge cases
- Consistent with Claude Code skill ecosystem
- Easier to maintain and modify
```

### 3. Minimal Agent Boundaries

Only separate what truly needs separation:

```
Agents that DON'T need conversation:
├── Analyzer (automatic codebase scan)
├── Generator (document creation)
└── Validator (automated checks)

Agents that NEED conversation:
└── Designer (requirements, patterns, phases, risks)
    → Keep as single conversational unit
```

## Proposed Agent Structure

### Agent 1: Analyzer (Automatic)

```markdown
# Analyzer Agent

## Role
Automatically analyze codebase without user interaction.

## Input
- feature_name: string
- project_root: path
- config: from config.yaml

## Output (save to state.md)
- architecture: detected pattern
- tech_stack: languages and frameworks
- components: reusable components list
- patterns: coding conventions

## Behavior
1. Scan directory structure
2. Analyze package.json / go.mod / etc.
3. Detect architecture pattern
4. Identify reusable components
5. Save results to state.md

## No User Interaction
This agent runs silently and saves results.
```

### Agent 2: Designer (Conversational)

```markdown
# Designer Agent

## Role
Interactive requirements gathering and design decisions.

## Input (from state.md)
- Analyzer results (architecture, components)

## Conversation Flow
1. Basic Info (name, goal)
2. Architecture Q&A (integrations, storage, API)
3. Functional Design (use cases, interface, errors)
4. Implementation Pattern selection
5. Phase proposal and confirmation
6. Risk analysis

## Output (save to state.md)
- All collected requirements
- User decisions
- Phase structure
- Risk assessment

## Key Behaviors
- Ask clarifying questions
- Remember previous answers
- Suggest based on context
- Handle "as I mentioned" references
```

### Agent 3: Generator (Automatic)

```markdown
# Generator Agent

## Role
Generate design documents from collected information.

## Input (from state.md)
- All Designer outputs
- Analyzer results
- Templates

## Output
- 00_OVERVIEW.md
- 01_{phase1}.md
- 02_{phase2}.md
- ...

## No User Interaction
Generate all documents based on state.
Preview handled separately.
```

### Agent 4: Validator (Automatic)

```markdown
# Validator Agent

## Role
Validate generated documents for completeness and consistency.

## Input
- Generated documents
- State.md (requirements)

## Output
- Validation report
- Error/Warning/Info list
- Auto-fix suggestions

## No User Interaction
Run validation checks automatically.
```

## State Management Between Agents

### State File (state.md)

```markdown
# Plan Feature State: {feature_name}

## Agent Progress
- [x] Analyzer (completed)
- [x] Designer (completed)
- [ ] Generator (pending)
- [ ] Validator (pending)

## Analyzer Results
{structured data from analyzer}

## Designer Results
{all Q&A results and decisions}

## Conversation Context
{key decisions for context continuity}
```

### Agent Handoff

```
Analyzer completes
    ↓
Save to state.md
    ↓
Designer loads state.md (Analyzer section only)
    ↓
Designer completes with Q&A
    ↓
Save to state.md (full)
    ↓
Generator loads state.md (all sections)
    ↓
...
```

## Implementation Approach

### Phase 1: Prepare (Current)

```
- State management in place ✓
- Session continuation support ✓
- Feature size assessment ✓
- This design document ✓
```

### Phase 2: Extract Analyzer

When ready to implement:

1. Create `agents/analyzer.md`
2. Extract codebase analysis logic
3. Run as pre-step before conversation
4. Save results to state.md

```
agents/
└── analyzer.md

Execution:
/plan-feature {name}
    ↓
Run analyzer agent (silent)
    ↓
Continue with main flow (conversational)
```

### Phase 3: Extract Generator

1. Create `agents/generator.md`
2. Extract document generation logic
3. Run after design confirmation
4. Handle preview separately

### Phase 4: Full Agent Pipeline

Only if needed:

1. Create `agents/designer.md`
2. Create `agents/validator.md`
3. Implement orchestration in SKILL.md
4. Full pipeline with handoffs

## Agent File Structure

```
skills/plan-feature/
├── SKILL.md                 # Orchestrator + main logic
├── agents/
│   ├── analyzer.md          # Codebase analysis
│   ├── designer.md          # Interactive design (if separated)
│   ├── generator.md         # Document generation
│   └── validator.md         # Validation
├── docs/
│   └── agent-architecture.md # This document
├── templates/
│   └── ...
└── questions.md
```

## Agent Prompt Template

Each agent file follows this structure:

```markdown
# {Agent Name} Agent

## Role
{One-line description}

## Input
{What this agent receives}
- From state.md: {sections}
- From user: {if any}
- From config: {if any}

## Output
{What this agent produces}
- Save to state.md: {sections}
- Create files: {if any}

## Behavior
{Step-by-step instructions}
1. {Step 1}
2. {Step 2}
...

## Output Format
{Example of expected output}

```{format}
{example}
```

## Constraints
- {Constraint 1}
- {Constraint 2}
```

## Trade-offs Considered

### Conversation Context vs Agent Isolation

| Approach | Conversation | Context Usage | Complexity |
|----------|--------------|---------------|------------|
| Current (monolithic) | Excellent | High | Low |
| Partial agents | Good | Medium | Medium |
| Full agents | Limited | Low | High |

**Decision**: Start with partial (Analyzer + Generator only), keep Designer monolithic for conversation quality.

### Automatic vs Manual Agent Handoff

| Approach | UX | Control | Implementation |
|----------|-----|---------|----------------|
| Automatic pipeline | Seamless | Low | Complex |
| Manual commands | Explicit | High | Simple |
| Hybrid | Balanced | Medium | Medium |

**Decision**: Hybrid - automatic for non-interactive agents, manual trigger points for review.

## Migration Path

```
Current State
    ↓
Add state management (done)
    ↓
Add session continuation (done)
    ↓
Extract Analyzer agent (when needed)
    ↓
Extract Generator agent (when needed)
    ↓
Consider Designer split (only if required)
```

## Success Criteria for Agent Implementation

Before implementing agents, verify:

- [ ] Current approach fails > 30% of large features
- [ ] Users request mid-session handoff capability
- [ ] Feature complexity exceeds single-session capacity
- [ ] Team requests parallel agent development

## References

- Main skill: [SKILL.md](../SKILL.md)
- State management: SKILL.md > State Management section
- Session continuation: SKILL.md > Session Continuation section
