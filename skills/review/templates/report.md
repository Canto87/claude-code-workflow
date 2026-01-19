# Review Report Template

Use this template structure when generating review reports.

## Phase Review Template

```markdown
## 🔍 Review Report: {FEATURE_NAME} / {PHASE_NAME}

### Summary
| Category | Status | Issues |
|----------|--------|--------|
| Design Consistency | {STATUS_ICON} {STATUS} | {COUNT} |
| Code Quality | {STATUS_ICON} {STATUS} | {COUNT} |
| Test Coverage | {STATUS_ICON} {STATUS} | {COUNT} |
| Security | {STATUS_ICON} {STATUS} | {COUNT} |
| Completeness | {STATUS_ICON} {STATUS} | {COUNT} |

**Overall: {VERDICT_ICON} {VERDICT}** {VERDICT_NOTE}

---

{FOR_EACH_CATEGORY}
### {CATEGORY_NAME} {STATUS_ICON}

{IF_PASSED}
All checks passed:
{FOR_EACH_CHECK}
- [✓] {CHECK_NAME}
{END_FOR}
{END_IF}

{IF_ISSUES}
#### {SEVERITY} Issues

{FOR_EACH_ISSUE}
{INDEX}. **{ISSUE_TITLE}** ({FILE_PATH}:{LINE})
   ```{LANGUAGE}
   // Current
   {CURRENT_CODE}

   // Suggested
   {SUGGESTED_CODE}
   ```
{END_FOR}
{END_IF}

---
{END_FOR}

### Recommendations
{FOR_EACH_RECOMMENDATION}
{INDEX}. {RECOMMENDATION}
{END_FOR}

### Next Steps
→ {NEXT_STEP}
```

## Feature Review Template

```markdown
## 🔍 Review Report: {FEATURE_NAME} (Full Feature)

### Phase Summary

| Phase | Status | Issues | Notes |
|-------|--------|--------|-------|
{FOR_EACH_PHASE}
| {PHASE_NAME} | {STATUS_ICON} {STATUS} | {ISSUE_COUNT} | {NOTES} |
{END_FOR}

### Overall Assessment

**{VERDICT_ICON} {VERDICT}**

The {FEATURE_NAME} feature is ready for:
{FOR_EACH_NEXT_STEP}
- [ ] {NEXT_STEP}
{END_FOR}
```

## Status Icons

| Category Status | Icon | Meaning |
|-----------------|------|---------|
| Pass | ✅ | All checks passed |
| Warning | ⚠️ | Minor issues found |
| Fail | ❌ | Issues need fixing |
| Skipped | ⏭️ | Not reviewed |

## Verdict Icons

| Verdict | Icon | Meaning |
|---------|------|---------|
| APPROVED | ✅ | Ready to proceed |
| APPROVED WITH WARNINGS | ⚠️ | Can proceed with notes |
| NEEDS WORK | ❌ | Fix issues first |
| BLOCKED | 🚫 | Critical issues |

## Example: Passing Review

```markdown
## 🔍 Review Report: payment / Phase 1

### Summary
| Category | Status | Issues |
|----------|--------|--------|
| Design Consistency | ✅ Pass | 0 |
| Code Quality | ✅ Pass | 0 |
| Test Coverage | ✅ Pass | 0 |
| Security | ✅ Pass | 0 |
| Completeness | ✅ Pass | 0 |

**Overall: ✅ APPROVED**

---

### Design Consistency ✅

All checks passed:
- [✓] API endpoints match design
- [✓] Data models match design
- [✓] Architecture followed
- [✓] Dependencies implemented

---

### Code Quality ✅

All checks passed:
- [✓] Error handling
- [✓] Logging
- [✓] Function length
- [✓] Naming conventions

---

### Test Coverage ✅

All checks passed:
- [✓] Unit tests exist
- [✓] Integration tests
- [✓] Edge cases covered

---

### Security ✅

All checks passed:
- [✓] Input validation
- [✓] Authentication checks
- [✓] No hardcoded secrets
- [✓] SQL injection prevention

---

### Completeness ✅

All Phase 1 checklist items completed:
- [x] Create payment model
- [x] Implement payment API
- [x] Add Stripe integration
- [x] Write unit tests

---

### Recommendations

No recommendations - excellent work!

### Next Steps
→ Phase 1 approved. Ready to proceed to Phase 2: Webhooks
```

## Example: Review with Issues

```markdown
## 🔍 Review Report: notification / Phase 2

### Summary
| Category | Status | Issues |
|----------|--------|--------|
| Design Consistency | ✅ Pass | 0 |
| Code Quality | ⚠️ Warning | 2 |
| Test Coverage | ❌ Fail | 1 |
| Security | ✅ Pass | 0 |
| Completeness | ⚠️ Warning | 1 |

**Overall: ❌ NEEDS WORK** (1 error, 3 warnings)

---

### Code Quality ⚠️

#### Warnings

1. **Long function** (internal/notify/sender.go:45)
   - `SendBatch` is 72 lines (threshold: 50)
   - Consider extracting retry logic

2. **Missing error context** (internal/notify/sender.go:89)
   ```go
   // Current
   return err

   // Suggested
   return fmt.Errorf("send notification failed for user %d: %w", userID, err)
   ```

---

### Test Coverage ❌

#### Errors

1. **Missing tests for SendBatch**
   - New function has no corresponding test
   - Required: TestSendBatch, TestSendBatchRetry

---

### Completeness ⚠️

#### Warnings

1. **Unresolved TODO** (internal/notify/sender.go:67)
   ```go
   // TODO: implement rate limiting
   ```

---

### Recommendations

1. Add tests for SendBatch function
2. Remove or resolve TODO comment
3. Split SendBatch into smaller functions

### Next Steps
→ Fix 1 error before proceeding. Address warnings when possible.
```
