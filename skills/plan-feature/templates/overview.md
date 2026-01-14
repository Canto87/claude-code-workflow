# 00_OVERVIEW.md Template

Overview file for design documents.

---

```markdown
# {Feature Name} System

> {One-line description}

## Overview

{Detailed description based on collected information}

## System Architecture

```
{ASCII diagram}
```

## Implementation Phases

| Rank | Phase | Feature | Difficulty | Impact | Status |
|------|-------|---------|------------|--------|--------|
| 1 | Phase 1 | {feature} | {difficulty} | {impact} | Not implemented |
| 2 | Phase 2 | {feature} | {difficulty} | {impact} | Not implemented |
| ... | ... | ... | ... | ... | ... |

## Existing System Utilization

### Reusable Components
- `{source_path}/{module}/` - {description}
- ...

### New Components to Implement
- `{source_path}/{new_module}/` - {description}
- ...

## Data Model

### Schema (based on storage selection)

**SQL-based (SQLite/PostgreSQL):**
```sql
CREATE TABLE {table_name} (
    id INTEGER PRIMARY KEY,
    ...
);
```

**File-based (JSON/YAML):**
```yaml
{feature}:
  items:
    - id: 1
      ...
```

### Type Definitions

<!-- Write according to project language -->

**Go:**
```go
type {TypeName} struct {
    ID   int64
    ...
}
```

**TypeScript:**
```typescript
interface {TypeName} {
    id: number;
    ...
}
```

**Python:**
```python
@dataclass
class {TypeName}:
    id: int
    ...
```

## Configuration

```yaml
{feature}:
  enabled: true
  ...
```

## Implementation File List

```
{source_path}/{feature}/
├── types.{ext}
├── store.{ext}
├── processor.{ext}
└── ...

{apps_path}/{feature}/
└── main.{ext}
```

---

## Writing Guide

1. **Overview**: Write based on collected "Core goal"
2. **Architecture**: Diagram relationships with integrated systems
3. **Implementation Phases**: Reflect "Priority" answers, 3-7 phases
4. **Data Model**: Define schema based on "Storage" selection
5. **Configuration**: Define required environment variables/config files

## File Extensions by Language

| Language | Extension | source_path | apps_path |
|----------|-----------|-------------|-----------|
| Go | .go | internal | apps |
| TypeScript | .ts | src | apps |
| Python | .py | src | scripts |
| Java | .java | src/main/java | - |
| Rust | .rs | src | src/bin |
