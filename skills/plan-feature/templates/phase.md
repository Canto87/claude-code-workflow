# 0N_PHASE.md Template

Detailed design document for each phase.

---

```markdown
# Phase N: {Phase Name}

**Implementation Rank: N** | **Difficulty: {Low/Medium/High}** | **Impact: {Low/Medium/High}**

## Goal

{Core goal of this phase}

## Why This Rank?

{Reasoning for rank - dependencies, impact, etc.}

## Architecture

```
{Component diagram for this phase}
```

## Implementation

### 1. {Component 1}

**File**: `{source_path}/{feature}/{file}.{ext}`

{Role description}

<!-- Write example code according to project language -->

**Go Example:**
```go
type {TypeName} struct {
    ...
}

func New{TypeName}() *{TypeName} {
    ...
}
```

**TypeScript Example:**
```typescript
export class {TypeName} {
    constructor() {
        ...
    }
}
```

**Python Example:**
```python
class {TypeName}:
    def __init__(self):
        ...
```

### 2. {Component 2}

**File**: `{source_path}/{feature}/{file2}.{ext}`

{Role description}

## Testing

<!-- Write commands according to project language/build system -->

```bash
# Build (by language)
# Go:         go build ./...
# TypeScript: npm run build
# Python:     python -m build
# Rust:       cargo build

# Run
{run_command}

# Test
# Go:         go test ./...
# TypeScript: npm test
# Python:     pytest
# Rust:       cargo test
```

## Checklist

- [ ] Create `{source_path}/{feature}/types.{ext}`
- [ ] Create `{source_path}/{feature}/store.{ext}`
- [ ] Write test code
- [ ] Integrate with existing systems
- [ ] Update documentation

## Next Steps

After completing this phase → Implement `0{N+1}_{NEXT}.md`

---

## Writing Guide

### Phase Division Criteria

1. **Dependencies**: Does another phase need to complete first?
2. **Difficulty**: Implementation complexity (Low/Medium/High)
3. **Impact**: User experience improvement (Low/Medium/High)
4. **Implementation Order**: Logical sequence

### Recommended Phase Count

- Minimum: 3
- Maximum: 7
- Ideal: 4-5

### Checklist Writing Tips

- List in file creation order
- Include test items
- Specify integration tasks
- Include documentation updates

### Naming Conventions by Language

| Language | File Name | Type Name | Function Name |
|----------|-----------|-----------|---------------|
| Go | snake_case.go | PascalCase | PascalCase |
| TypeScript | kebab-case.ts | PascalCase | camelCase |
| Python | snake_case.py | PascalCase | snake_case |
| Rust | snake_case.rs | PascalCase | snake_case |
