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

## Architecture Decision

**Selected Approach**: {Option name} - {Pattern name}

**Alternatives Considered**:
| Option | Pattern | Why Not Selected |
|--------|---------|------------------|
| {Option B} | {Pattern} | {Reason - e.g., "Over-engineering for current scope"} |
| {Option C} | {Pattern} | {Reason - e.g., "Team unfamiliar with pattern"} |

**Decision Rationale**:
{Why this architecture was chosen - e.g., "Best balance of consistency with existing codebase and implementation speed. Allows future migration to more complex patterns if needed."}

### Key Trade-offs Accepted

| Trade-off | Impact | Mitigation |
|-----------|--------|------------|
| {Limited scalability} | {Medium} | {Can refactor to Option B if load increases} |
| {Tighter coupling} | {Low} | {Use interfaces at boundaries} |

### Architecture Constraints

- Must integrate with existing {system/component}
- Should follow {pattern} conventions used in project
- Limited by {constraint - e.g., "current team expertise"}

### Recommended Structure

```
{source_path}/
├── {layer1}/              ← {description}
│   └── {feature}/
│       ├── {file1}.{ext}  ← {component description}
│       └── {file2}.{ext}  ← {component description}
├── {layer2}/              ← {description}
│   └── {feature}/
│       └── {file}.{ext}   ← {component description}
└── {layer3}/              ← {description}
    └── {feature}/
        └── {file}.{ext}   ← {component description}
```

### Key Patterns to Follow

| Pattern | Where to Use | Example |
|---------|--------------|---------|
| {Repository} | {Data access layer} | `{feature}Repository` |
| {Service} | {Business logic} | `{feature}Service` |
| {Handler/Controller} | {API layer} | `{feature}Handler` |

## Use Cases

### Primary Use Cases

| ID | Actor | Action | Expected Result |
|----|-------|--------|-----------------|
| UC-01 | {actor} | {action} | {result} |
| UC-02 | {actor} | {action} | {result} |
| ... | ... | ... | ... |

### User Flow

```
{User flow diagram - show main scenarios}

1. User initiates {action}
       ↓
2. System validates {input}
       ↓
3. System processes {operation}
       ↓
4. System returns {response}
```

## Interface Specification

### API Endpoints

<!-- If REST API was selected -->

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/{feature}` | List items | {Yes/No} |
| GET | `/api/{feature}/:id` | Get single item | {Yes/No} |
| POST | `/api/{feature}` | Create item | {Yes/No} |
| PUT | `/api/{feature}/:id` | Update item | {Yes/No} |
| DELETE | `/api/{feature}/:id` | Delete item | {Yes/No} |

### Request/Response Examples

**GET /api/{feature}**
```json
// Request
GET /api/{feature}?page=1&limit=10

// Response 200 OK
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 10
  }
}
```

**POST /api/{feature}**
```json
// Request
{
  "field1": "value1",
  "field2": "value2"
}

// Response 201 Created
{
  "id": 1,
  "field1": "value1",
  "field2": "value2",
  "created_at": "2024-01-01T00:00:00Z"
}
```

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "{ERROR_CODE}",
    "message": "{User-friendly message}",
    "details": "{Technical details for debugging}"
  }
}
```

### Error Codes

| Code | HTTP Status | Description | Recovery Action |
|------|-------------|-------------|-----------------|
| {FEATURE}_NOT_FOUND | 404 | Resource not found | Verify ID exists |
| {FEATURE}_INVALID_INPUT | 400 | Validation failed | Check input format |
| {FEATURE}_UNAUTHORIZED | 401 | Authentication required | Login first |
| {FEATURE}_FORBIDDEN | 403 | Permission denied | Contact admin |
| {FEATURE}_CONFLICT | 409 | Resource conflict | Resolve conflict |

### Edge Cases

- Empty result set: Return empty array with 200 OK
- Concurrent modification: Return 409 Conflict
- Rate limiting: Return 429 Too Many Requests

## Security & Validation

### Authentication

<!-- Based on security requirements -->
- {Authentication method: JWT/Session/API Key/None}
- Token expiration: {duration}
- Refresh mechanism: {method}

### Authorization

| Role | Permissions |
|------|------------|
| {role1} | {read/write/delete} |
| {role2} | {read/write/delete} |

### Input Validation Rules

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| {field1} | string | Yes | max 255 chars |
| {field2} | number | Yes | min 0, max 1000 |
| {field3} | email | No | valid email format |

## Implementation Phases

| Rank | Phase | Feature | Difficulty | Impact | Risk | Status |
|------|-------|---------|------------|--------|------|--------|
| 1 | Phase 1 | {feature} | {difficulty} | {impact} | {Low/Medium/High} | Not implemented |
| 2 | Phase 2 | {feature} | {difficulty} | {impact} | {Low/Medium/High} | Not implemented |
| ... | ... | ... | ... | ... | ... | ... |

## Risk Assessment

### Overall Risk Level: {Low/Medium/High/Critical}

### Identified Risks

| Risk | Category | Impact | Probability | Level | Phase |
|------|----------|--------|-------------|-------|-------|
| {Database schema migration} | Technical | High | High | Critical | 1 |
| {External API dependency} | Dependency | Medium | Medium | Medium | 2 |
| {Shared component change} | Integration | High | Low | Medium | 1 |

### Risk Details

#### Critical Risks
- **{Risk name}**: {Description and why it's critical}
  - Impact: {What happens if it occurs}
  - Mitigation: {How to prevent or reduce}

#### High Risks
- **{Risk name}**: {Description}
  - Mitigation: {Action to take}

### Rollback Strategy

| Phase | Rollback Difficulty | Strategy |
|-------|-------------------|----------|
| Phase 1 | {Easy/Medium/Hard} | {Revert migration, restore backup} |
| Phase 2 | {Easy/Medium/Hard} | {Feature flag disable, code revert} |
| Phase 3 | {Easy/Medium/Hard} | {Config rollback} |

### Pre-Implementation Checklist

- [ ] Backup existing data/schema before Phase 1
- [ ] Create feature flags for gradual rollout
- [ ] Prepare rollback scripts for each phase
- [ ] Document all breaking changes
- [ ] Set up monitoring for new components
- [ ] Plan communication for affected teams

### Mitigation Actions

| Risk | Mitigation | Owner | Status |
|------|------------|-------|--------|
| {risk1} | {action} | {TBD} | Pending |
| {risk2} | {action} | {TBD} | Pending |

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
3. **Use Cases**: Define based on "Core use cases" selection
   - CRUD operations → List standard CRUD use cases
   - Data processing → List transformation/aggregation use cases
   - User interaction → List form/validation use cases
4. **Interface Specification**: Based on "Interface specification" level
   - Detailed spec → Full endpoint definitions with examples
   - Standard patterns → Basic RESTful endpoint table
   - Minimal → Skip or placeholder only
5. **Error Handling**: Based on "Error handling strategy"
   - Comprehensive → Full error code table with recovery actions
   - Standard pattern → Reference project conventions
   - Basic → HTTP status codes only
6. **Security & Validation**: Based on "Security/Validation" selection
   - Authentication → Define auth method and flow
   - Authorization → Define roles and permissions
   - Input validation → Define validation rules per field
7. **Implementation Phases**: Reflect "Priority" answers, 3-7 phases
8. **Data Model**: Define schema based on "Storage" selection
9. **Configuration**: Define required environment variables/config files

## File Extensions by Language

| Language | Extension | source_path | apps_path |
|----------|-----------|-------------|-----------|
| Go | .go | internal | apps |
| TypeScript | .ts | src | apps |
| Python | .py | src | scripts |
| Java | .java | src/main/java | - |
| Rust | .rs | src | src/bin |
