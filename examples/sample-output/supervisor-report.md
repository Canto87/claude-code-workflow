# Supervisor Pipeline Report Example

This is an example output from the supervisor skill showing a successful pipeline execution.

---

## Supervisor Complete: user-auth Phase 1

### Pipeline Summary
| Stage | Status | Score | Details |
|-------|--------|-------|---------|
| IMPLEMENT | ✅ DONE | - | 5/5 tasks |
| REVIEW | ✅ PASS | 8.5/10 | 0 critical, 2 warnings |
| VALIDATE | ✅ PASS | 9.0/10 | 6/6 AC met |

### Gate Decisions
| Gate | Attempt | Score | Decision |
|------|---------|-------|----------|
| Review #1 | 6.5/10 | RETRY | CR-06 (ignored error) found |
| Review #2 | 8.5/10 | PASS | Fixed error handling |
| Validate #1 | 9.0/10 | PASS | All AC met |

### Stage Details

#### IMPLEMENT (auto-impl)
```
## Progress: user-auth Phase 1 -- Task 5/5
- Task: Add session middleware
- Delegation: code-edit SUCCESS
- Phase Test: PASS
- Commit: a1b2c3d
- Checklist: 12/12 items complete
```

#### REVIEW (code-review)

**Attempt #1 (Score: 6.5/10)**
```
## Code Review: user-auth phase1 (phase)

### Summary
| Category | Score | Status | Key Finding |
|----------|-------|--------|-------------|
| Correctness | 8/10 | PASS | Logic verified |
| Error Handling | 4/10 | FAIL | Ignored errors in 2 locations |
| Security | 7/10 | PASS | Input validation present |
| Project Patterns | 7/10 | PASS | Follows conventions |
| Readability | 8/10 | PASS | Clear code |
| Test Quality | 6/10 | WARN | Missing edge case tests |

### Critical Issues
#### CR-06: Ignored error
- **Location**: `src/auth/session.ts:45`
- **Issue**: Error from validateToken() not checked
- **Fix Suggestion**:
  if (error) {
    logger.error('Token validation failed', { error });
    throw new AuthError('INVALID_TOKEN');
  }
```

**Feedback Fix Commit:**
```
fix(user-auth): phase1 - review feedback #1
- Fix ignored error in session.ts:45
- Add error propagation in token validation
```

**Attempt #2 (Score: 8.5/10)**
```
### Summary
| Category | Score | Status | Key Finding |
|----------|-------|--------|-------------|
| Correctness | 8/10 | PASS | Logic verified |
| Error Handling | 8/10 | PASS | Proper error handling |
| Security | 7/10 | PASS | Input validation present |
| Project Patterns | 9/10 | PASS | Follows conventions |
| Readability | 8/10 | PASS | Clear code |
| Test Quality | 6/10 | WARN | Could add edge case tests |

### Critical Issues
None

### Warnings
- CR-23: Consider adding tests for token expiry edge case
- CR-21: Magic number 3600 should be SESSION_TIMEOUT constant
```

#### VALIDATE (validate)

```
## Implementation Validation: user-auth Phase 1

| Category | Score | Status |
|----------|-------|--------|
| Build/Test | 10/10 | PASS |
| Acceptance | 9/10 | PASS |
| Checklist | 8/10 | PASS |
| Quality | 9/10 | PASS |
| **Overall** | **9.0/10** | **Excellent** |

### Acceptance Criteria
- [x] User can log in with email/password
- [x] Session token generated on successful login
- [x] Session stored in database
- [x] Invalid credentials return 401
- [x] Session middleware validates token
- [x] Logout clears session

### Findings
#### Critical
None

#### Warnings
- Session notes could be more detailed
```

### Commits
1. `a1b2c3d` feat(user-auth): phase1 - implement login endpoint
2. `b2c3d4e` feat(user-auth): phase1 - add session storage
3. `c3d4e5f` feat(user-auth): phase1 - implement middleware
4. `d4e5f6g` feat(user-auth): phase1 - add logout endpoint
5. `e5f6g7h` feat(user-auth): phase1 - add session validation
6. `f6g7h8i` fix(user-auth): phase1 - review feedback #1

### Recommended Next Steps
- Proceed to Phase 2: Password Reset Flow
- Consider adding tests for edge cases (optional)
- Document API endpoints in README

---

## Failure Example

For comparison, here's what a rejected pipeline looks like:

```
## Supervisor REJECTED: payment Phase 2

### Rejection Reason
Review score (3.5/10) below minimum threshold after 2 retry attempts.
Multiple critical security issues remain unresolved.

### Manual Fix Required
1. CR-09 (Critical): SQL injection in `src/payment/query.ts:78`
   - User input directly concatenated into query
   - Must use parameterized queries

2. CR-10 (Critical): API key hardcoded in `src/payment/stripe.ts:12`
   - Move to environment variable

3. CR-12 (Critical): Missing authorization check in `src/payment/refund.ts:34`
   - Any user can trigger refunds for any order

### Pipeline State
- IMPLEMENT: ✅ Complete
- REVIEW: ❌ REJECTED (Score: 3.5/10, Attempts: 2/2)
- VALIDATE: ⏳ Not reached

### Recovery Steps
1. Fix all critical issues manually
2. Run `/supervisor payment phase2 --skip-impl` to re-review
```
