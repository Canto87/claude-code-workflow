# Code Review Report Example

This is an example output from the `code-review` agent.

---

## Code Review: user-auth phase1 (phase)

### Summary
| Category | Score | Status | Key Finding |
|----------|-------|--------|-------------|
| Correctness | 9/10 | PASS | Logic verified, one edge case noted |
| Error Handling | 7/10 | PASS | Good wrapping, minor improvements possible |
| Security | 8/10 | PASS | Input validation present |
| Project Patterns | 9/10 | PASS | Follows conventions |
| Readability | 8/10 | PASS | Clear code structure |
| Test Quality | 6/10 | WARN | Missing edge case tests |
| **Overall** | **7.8/10** | **Good** | |

### Critical Issues
None

### Warnings

#### CR-04: Unhandled edge case
- **Location**: `src/auth/login.ts:67`
- **Issue**: Empty password string passes initial check but fails later
- **Fix Suggestion**:
  ```typescript
  // Before
  if (password) {
    // process
  }

  // After
  if (password && password.trim().length > 0) {
    // process
  }
  ```

#### CR-05: Error wrapping could be more specific
- **Location**: `src/auth/session.ts:34`
- **Issue**: Generic error message loses context
- **Fix Suggestion**:
  ```typescript
  // Before
  throw new Error('Session creation failed');

  // After
  throw new AuthError('SESSION_CREATE_FAILED', `Failed to create session for user ${userId}`, originalError);
  ```

#### CR-23: Missing test for concurrent login attempts
- **Location**: `src/auth/__tests__/login.test.ts`
- **Issue**: No test coverage for race condition scenarios
- **Fix Suggestion**: Add test case for simultaneous login attempts from same user

### Info
- CR-19: `src/auth/handler.ts:45` — Function `handleLogin` is 42 lines, approaching recommended limit
- CR-21: `src/auth/config.ts:12` — Magic number `3600` should be `SESSION_TIMEOUT_SECONDS` constant
- CR-22: `src/auth/types.ts:8` — Consider renaming `data` to more descriptive `userData`

### Positives
- Clean separation between authentication and session management
- Consistent use of async/await throughout
- Good TypeScript type coverage
- Logging present at key decision points

### Recommended Fix Priority
1. [Warning] CR-04: Handle empty password edge case
2. [Warning] CR-05: Improve error context in session creation
3. [Warning] CR-23: Add concurrent login test
4. [Info] CR-21: Extract magic numbers to constants

---

## Score Breakdown

### Correctness (9/10)
- CR-01 Logic errors: PASS (10)
- CR-02 Concurrency bugs: PASS (10)
- CR-03 Resource leaks: PASS (10)
- CR-04 Edge cases: WARN (5)
- Average: 8.75 → 9/10

### Error Handling (7/10)
- CR-05 Error wrapping: WARN (5)
- CR-06 Ignored errors: PASS (10)
- CR-07 Fallback handling: PASS (10)
- CR-08 Context propagation: N/A
- Average: 8.33 → weighted to 7/10

### Security (8/10)
- CR-09 Injection: PASS (10)
- CR-10 Hardcoded secrets: PASS (10)
- CR-11 Input validation: PASS (10)
- CR-12 Auth checks: N/A
- Average: 10 → 8/10 (conservative for security)

### Project Patterns (9/10)
- CR-13 Logging: PASS (10)
- CR-14 Concurrency: N/A
- CR-15 State management: PASS (10)
- CR-16 Architecture: PASS (10)
- CR-17 Workflow rules: N/A
- CR-18 File organization: PASS (10)
- Average: 10 → 9/10

### Readability (8/10)
- CR-19 Function length: PASS (10) - borderline
- CR-20 Complex conditionals: PASS (10)
- CR-21 Magic numbers: INFO (5)
- CR-22 Naming: INFO (5)
- Average: 7.5 → 8/10

### Test Quality (6/10)
- CR-23 Tests exist: WARN (5)
- CR-24 Meaningful tests: PASS (10)
- CR-25 Table-driven: N/A
- Average: 7.5 → 6/10 (rounded down for missing coverage)

---

## Verdict

**Good (7.8/10)** - Ready to merge after addressing warnings

This score would **PASS** the supervisor review gate (threshold: 7.0).
