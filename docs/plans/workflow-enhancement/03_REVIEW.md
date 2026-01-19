# Phase 3: Review Agent Skill

> Code quality review agent on phase completion

## Purpose

Automatically review code quality, design conformance, and test coverage at each
implementation phase completion to ensure quality before moving to the next phase.

## Usage Scenarios

```bash
# Review after phase completion
> /review phase-1

# Review entire feature (all phases)
> /review user-auth --all

# Review with specific focus
> /review --focus security
> /review --focus performance
> /review --focus design-match
```

## Review Perspectives

### 1. Design Conformance

```yaml
checks:
  - Are files specified in design documents created?
  - Are designed functions/methods implemented?
  - Does the data model match the design?
  - Are API endpoints implemented as designed?
```

**Comparison Method:**
```
Design Document (01_PHASE1.md)     Implementation Code
─────────────────────────────    ─────────────
internal/auth/types.go   →   [✓] File exists
  - User struct          →   [✓] Type defined
  - Session struct       →   [✓] Type defined
  - TokenPair struct     →   [✗] Missing
```

### 2. Code Quality

```yaml
checks:
  - Is error handling appropriate?
  - Are there hardcoded values?
  - Is function length appropriate? (Recommended: 50 lines or less)
  - Is complexity too high?
  - Is there duplicate code?
```

### 3. Testing

```yaml
checks:
  - Do unit tests exist?
  - Do tests pass?
  - Are main paths covered?
  - Are error case tests present?
```

### 4. Security

```yaml
checks:
  - SQL injection vulnerabilities
  - XSS vulnerabilities
  - Hardcoded secrets
  - Proper authentication/authorization checks
  - Input validation
```

### 5. Performance

```yaml
checks:
  - N+1 query problems
  - Unnecessary memory allocation
  - Infinite loop possibilities
  - Missing indexes (DB)
```

## Output Format

### Review Report

```
## 🔍 Review Report: user-auth / Phase 1

### Summary
| Aspect | Score | Issues |
|--------|-------|--------|
| Design Conformance | 🟢 90% | 1 minor |
| Code Quality | 🟡 75% | 2 warnings |
| Testing | 🟢 85% | 1 suggestion |
| Security | 🟢 95% | 0 |

**Overall: 🟢 APPROVED** (with minor issues)

---

### 📐 Design Conformance (90%)

✅ **Implemented as Designed**
- `internal/auth/types.go` - User, Session structs
- `internal/auth/store.go` - Database operations
- `internal/auth/handler.go` - HTTP handlers

⚠️ **Minor Deviation**
- `TokenPair` struct missing (documented in design)
  - Recommendation: Add in Phase 2 (JWT) or update design doc

---

### 📊 Code Quality (75%)

⚠️ **Warnings**

1. **Long function** - `handler.go:45 HandleSignup()`
   - Current: 78 lines
   - Recommended: < 50 lines
   - Suggestion: Extract validation logic

2. **Magic number** - `store.go:23`
   ```go
   if len(password) < 8 {  // 8 should be a constant
   ```
   - Suggestion: Use `const MinPasswordLength = 8`

---

### 🧪 Testing (85%)

✅ **Test Coverage**
- `types_test.go` - 100% (model validation)
- `store_test.go` - 80% (DB operations)
- `handler_test.go` - 75% (HTTP handlers)

💡 **Suggestion**
- Add error case test for duplicate email signup

---

### 🔒 Security (95%)

✅ All security checks passed
- No SQL injection vulnerabilities
- Password properly hashed (bcrypt)
- No hardcoded secrets

---

### ✅ Checklist for Next Phase

Before starting Phase 2:
- [ ] Fix magic number in store.go
- [ ] Consider refactoring HandleSignup
- [ ] Add TokenPair struct or update design doc

### Approve Phase Completion?
→ Recommended: **APPROVE** (minor issues can be addressed in refactoring)
```

## File Structure

```
skills/review/
├── SKILL.md              # Skill definition
├── config.yaml           # Review settings
├── checklists/
│   ├── design.md         # Design conformance checklist
│   ├── quality.md        # Code quality checklist
│   ├── testing.md        # Testing checklist
│   ├── security.md       # Security checklist
│   └── performance.md    # Performance checklist
└── templates/
    └── report.md         # Report template
```

## config.yaml Schema

```yaml
# review skill settings
review:
  # Active review perspectives
  perspectives:
    - design      # Design conformance
    - quality     # Code quality
    - testing     # Testing
    - security    # Security (optional)
    - performance # Performance (optional)

  # Score thresholds
  thresholds:
    pass: 70          # Pass if above this score
    warning: 50       # Warning if below this score

  # Code quality rules
  quality_rules:
    max_function_length: 50
    max_file_length: 300
    max_complexity: 10

  # Security check patterns
  security_patterns:
    - pattern: "password\\s*=\\s*[\"']"
      message: "Hardcoded password detected"
    - pattern: "TODO.*security"
      message: "Security TODO found"
```

## SKILL.md Definition

```yaml
---
name: review
description: Review completed phase for code quality, design conformance, and security
allowed-tools: Read, Glob, Grep, Bash, Task
---
```

## Workflow Integration

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ /init-impl   │────▶│ Development  │────▶│  /review     │
│ (Checklist)  │     │(Code Writing)│     │(Quality Rev.)│
└──────────────┘     └──────────────┘     └──────────────┘
       │                                          │
       │                                          ▼
       │                                  ┌──────────────┐
       │                                  │    Pass?     │
       │                                  └──────────────┘
       │                                    │        │
       │                                   Yes       No
       │                                    │        │
       │                                    ▼        ▼
       │                              Next Phase   Fix and
       │                                         Re-review
       └──────────────────────────────────────────────┘
```

## Automation Options

### Git Hook Integration

```bash
# .git/hooks/pre-push
#!/bin/bash
claude "/review --quick"
if [ $? -ne 0 ]; then
  echo "Review failed. Please fix issues before pushing."
  exit 1
fi
```

### CI/CD Integration

```yaml
# .github/workflows/review.yml
- name: Code Review
  run: claude "/review --ci --output json" > review.json
```

## Extensibility

- **Auto-fix**: `--fix` option to auto-fix simple issues
- **Custom Rules**: Add project-specific review rules
- **Review History**: Compare with previous review results
- **Team Standards**: Check team coding conventions
