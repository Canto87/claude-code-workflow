# Validate Report Examples

This document shows example outputs from the `validate` agent in both modes.

---

## Mode 1: Artifact Validation

### Example: Consistent Artifacts

```
## Artifact Validation: user-auth

| Category | Score | Status |
|----------|-------|--------|
| Structure | 10/10 | PASS |
| Content | 9/10 | PASS |
| Existence | 10/10 | PASS |
| Documentation | 8/10 | PASS |
| **Overall** | **9.2/10** | **Excellent** |

### Findings
#### Critical
None

#### Warnings
- AC-07: Test Commands missing in phase3 command file
- AC-09: CLAUDE.md missing `user-auth-phase3` command reference

#### Info
None

### Recommendations
1. Add Test Commands section to `.claude/commands/user-auth/phase3.md`
2. Update CLAUDE.md to include all user-auth slash commands
```

### Example: Inconsistent Artifacts

```
## Artifact Validation: payment-gateway

| Category | Score | Status |
|----------|-------|--------|
| Structure | 5/10 | WARN |
| Content | 4/10 | FAIL |
| Existence | 7/10 | PASS |
| Documentation | 5/10 | WARN |
| **Overall** | **5.0/10** | **Needs Improvement** |

### Findings
#### Critical
- AC-01: Phase count mismatch - OVERVIEW lists 4 phases, checklist has 3
- AC-03: Phase 4 command file missing (`.claude/commands/payment-gateway/phase4.md`)

#### Warnings
- AC-02: Phase 2 name differs - OVERVIEW: "Payment Processing", checklist: "Process Payments"
- AC-04: Checklist item "Add webhook handlers" not found in any design document
- AC-05: Design document task "Implement retry logic" not in any command file

#### Info
- AC-07: Phase 2 missing Test Commands section

### Recommendations
1. **Critical**: Add missing Phase 4 to checklist or remove from OVERVIEW
2. **Critical**: Create `.claude/commands/payment-gateway/phase4.md`
3. Align Phase 2 naming across all documents
4. Either add "webhook handlers" to design or remove from checklist
5. Add "retry logic" task to appropriate phase command
```

---

## Mode 2: Implementation Validation

### Example: Phase Passes

```
## Implementation Validation: user-auth Phase 1

| Category | Score | Status |
|----------|-------|--------|
| Build/Test | 10/10 | PASS |
| Acceptance | 9/10 | PASS |
| Checklist | 10/10 | PASS |
| Quality | 8/10 | PASS |
| **Overall** | **9.3/10** | **Excellent** |

### Acceptance Criteria
- [x] User can register with email/password: Verified in `src/auth/register.ts:23`
- [x] Password is hashed before storage: bcrypt used in `src/auth/password.ts:15`
- [x] Email uniqueness enforced: Constraint in `src/db/schema.ts:45`
- [x] Validation errors return 400: Handler at `src/auth/handler.ts:67`
- [x] Success returns user object (no password): DTO at `src/auth/dto.ts:12`
- [ ] Rate limiting on registration: **Not implemented** - design doc mentions but not in AC

### Findings
#### Critical
None

#### Warnings
- IV-04: Rate limiting mentioned in design but not in Acceptance Criteria
  - Consider adding to Phase 2 or documenting as out of scope

#### Info
- IV-08: Error handling follows project patterns
- IV-09: Logging present at registration entry/exit points

### Recommendations
1. Clarify rate limiting scope - add to Phase 2 AC or mark as future work
```

### Example: Phase Needs Work

```
## Implementation Validation: user-auth Phase 2

| Category | Score | Status |
|----------|-------|--------|
| Build/Test | 7/10 | PASS |
| Acceptance | 5/10 | WARN |
| Checklist | 6/10 | WARN |
| Quality | 7/10 | PASS |
| **Overall** | **5.9/10** | **Needs Improvement** |

### Acceptance Criteria
- [x] User can log in with email/password: Verified
- [x] JWT token generated on success: Verified
- [ ] Refresh token mechanism: **Partial** - token generated but no refresh endpoint
- [ ] Token expiry configurable: **Not implemented** - hardcoded 1 hour
- [x] Invalid credentials return 401: Verified
- [ ] Account lockout after N failures: **Not implemented**

### Findings
#### Critical
- IV-03: Phase test `npm run test:auth:login` fails
  - Error: `refreshToken` endpoint not found
  - Expected by test but not implemented

- IV-04: 2 of 6 Acceptance Criteria not met
  - Refresh token: Only generation, no refresh endpoint
  - Token expiry: Hardcoded, not configurable

#### Warnings
- IV-05: 3 checklist items still marked `[ ]`
  - [ ] Implement token refresh endpoint
  - [ ] Add expiry configuration
  - [ ] Add account lockout

- IV-06: Phase status not marked "complete"

### Recommendations
1. **Critical**: Implement `/auth/refresh` endpoint for token refresh
2. **Critical**: Move token expiry to configuration (`AUTH_TOKEN_EXPIRY`)
3. Implement account lockout or move to Phase 3
4. Update checklist items after implementation
5. Run `npm run test:auth:login` to verify before re-validation
```

---

## Score Interpretation

| Score | Grade | Supervisor Gate |
|-------|-------|-----------------|
| 9-10 | Excellent | PASS |
| 7-8 | Good | PASS |
| 5-6 | Needs Improvement | RETRY (fix issues) |
| 0-4 | Fail | REJECT (manual intervention) |

---

## Usage in Supervisor Pipeline

In the supervisor pipeline, validate runs as the final stage:

```
IMPLEMENT (auto-impl)
    ↓
REVIEW (code-review) → Gate 1: 7+ to pass
    ↓
VALIDATE (this) → Gate 2: 7+ to pass
    ↓
Pipeline Complete
```

If validate returns 5-6 with Critical issues, supervisor will:
1. Delegate fixes to `code-edit` agent
2. Re-run validation
3. If still failing after 1 retry, REJECT and require manual intervention
