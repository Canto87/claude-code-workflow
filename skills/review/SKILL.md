---
name: review
description: Review completed phases for quality, consistency, and completeness. Use after completing a phase or feature.
allowed-tools: Read, Glob, Grep, Task, Bash
---

# Review Skill

Reviews completed implementation phases against design documents, checking for quality, consistency, and completeness.

## When to Use

- After completing a phase
- Before merging a feature branch
- During code review preparation
- Quality gate before deployment

## Usage

```bash
# Review specific phase
> /review user-auth phase-2

# Review entire feature
> /review user-auth

# Review with specific focus
> /review user-auth --focus security
```

## Configuration File

Skill settings are managed in `config.yaml` in the same folder.

## Execution Flow

```
1. Load Context          → Read design docs and checklist
       ↓
2. Analyze Code          → Find implemented files
       ↓
3. Design Consistency    → Compare code vs design
       ↓
4. Quality Checks        → Run quality analysis
       ↓
5. Test Coverage         → Check test existence
       ↓
6. Security Scan         → Look for common issues
       ↓
7. Generate Report       → Output review findings
```

## Review Categories

### 1. Design Consistency

Compares implementation against design documents:

| Check | Description |
|-------|-------------|
| API endpoints | Do implemented APIs match design? |
| Data models | Do types/schemas match design? |
| Architecture | Does structure follow planned architecture? |
| Dependencies | Are planned integrations implemented? |

### 2. Code Quality

| Check | Description |
|-------|-------------|
| Error handling | Are errors properly handled? |
| Logging | Is appropriate logging in place? |
| Documentation | Are complex functions documented? |
| Naming | Do names follow conventions? |

### 3. Test Coverage

| Check | Description |
|-------|-------------|
| Unit tests | Do tests exist for new functions? |
| Integration tests | Are integrations tested? |
| Edge cases | Are edge cases covered? |

### 4. Security

| Check | Description |
|-------|-------------|
| Input validation | Is user input validated? |
| Authentication | Are auth checks in place? |
| Secrets | No hardcoded secrets? |
| SQL injection | Parameterized queries used? |

### 5. Completeness

| Check | Description |
|-------|-------------|
| Checklist items | All items marked complete? |
| TODOs | No unresolved TODOs? |
| Placeholders | No placeholder code? |

## Output Format

### Phase Review

```
## 🔍 Review Report: user-auth / Phase 2

### Summary
| Category | Status | Issues |
|----------|--------|--------|
| Design Consistency | ✅ Pass | 0 |
| Code Quality | ⚠️ Warning | 2 |
| Test Coverage | ✅ Pass | 0 |
| Security | ✅ Pass | 0 |
| Completeness | ✅ Pass | 0 |

**Overall: ✅ APPROVED** (with minor suggestions)

---

### Design Consistency ✅

All implemented components match design specifications:
- [✓] POST /api/auth/refresh endpoint
- [✓] Token refresh logic
- [✓] Blacklist mechanism

---

### Code Quality ⚠️

#### Warnings

1. **Missing error context** (internal/auth/jwt.go:45)
   ```go
   // Current
   return nil, err

   // Suggested
   return nil, fmt.Errorf("failed to refresh token: %w", err)
   ```

2. **Long function** (internal/auth/handler.go:120)
   - `HandleRefresh` is 85 lines
   - Consider extracting validation logic

---

### Test Coverage ✅

- [✓] TestRefreshToken
- [✓] TestRefreshTokenExpired
- [✓] TestRefreshTokenBlacklisted

---

### Security ✅

- [✓] Token validation before refresh
- [✓] Old token blacklisted after refresh
- [✓] No secrets in code

---

### Completeness ✅

All Phase 2 checklist items completed:
- [x] Generate access token
- [x] Implement refresh logic
- [x] Token validation
- [x] Blacklist expired tokens
- [x] Add token expiry config

---

### Recommendations

1. Add error context to token refresh failures
2. Consider splitting HandleRefresh into smaller functions
3. Add integration test for concurrent refresh attempts

### Next Steps
→ Phase 2 approved. Ready to proceed to Phase 3: Session Management
```

### Feature Review

```
## 🔍 Review Report: user-auth (Full Feature)

### Phase Summary

| Phase | Status | Issues | Notes |
|-------|--------|--------|-------|
| Phase 1: Basic Auth | ✅ Pass | 0 | Completed |
| Phase 2: JWT | ✅ Pass | 2 warnings | Minor suggestions |
| Phase 3: Session | ✅ Pass | 0 | Completed |
| Phase 4: Social | ⏭️ Skipped | - | Not in scope |

### Overall Assessment

**✅ FEATURE APPROVED**

The user-auth feature is ready for:
- [ ] Final code review by team
- [ ] QA testing
- [ ] Documentation generation (`/generate-docs user-auth`)
- [ ] Merge to main branch
```

## Review Verdicts

| Verdict | Icon | Meaning |
|---------|------|---------|
| APPROVED | ✅ | Ready to proceed |
| APPROVED WITH WARNINGS | ⚠️ | Can proceed, address warnings |
| NEEDS WORK | ❌ | Must fix issues before proceeding |
| BLOCKED | 🚫 | Critical issues found |

## Focus Modes

| Mode | Checks |
|------|--------|
| `--focus quality` | Code quality only |
| `--focus security` | Security checks only |
| `--focus tests` | Test coverage only |
| `--focus design` | Design consistency only |
| (default) | All checks |

## On Completion (Slack Notification)

After review completion, send Slack notification if configured:

1. **Check webhook configuration:**
   ```bash
   WEBHOOK=$(grep 'webhook_url:' skills/slack-notify/config.yaml 2>/dev/null | sed 's/.*"\(.*\)"/\1/')
   ```

2. **If webhook is configured** (not empty and doesn't contain "YOUR"):
   ```bash
   curl -s -X POST "$WEBHOOK" \
     -H "Content-Type: application/json" \
     -d '{
       "blocks": [
         {"type": "header", "text": {"type": "plain_text", "text": "🔍 Review Complete", "emoji": true}},
         {"type": "section", "text": {"type": "mrkdwn", "text": "*{feature_name}* {phase} review is complete."}},
         {"type": "section", "fields": [
           {"type": "mrkdwn", "text": "*Verdict:*\n{verdict_icon} {verdict}"},
           {"type": "mrkdwn", "text": "*Issues:*\n{error_count} errors, {warning_count} warnings"}
         ]},
         {"type": "context", "elements": [{"type": "mrkdwn", "text": "Next: {next_action}"}]}
       ]
     }' > /dev/null 2>&1 || true
   ```

3. **Continue with normal completion output** (notification failure should not block)

## Related Skills

- `/status` → Check progress before review
- `/init-impl` → Created the checklist being reviewed
- `/generate-docs` → Generate docs after approval

---

## Skill vs Agent: When to Use Which

| | `/review` Skill | `code-review` Agent |
|---|---|---|
| **Invocation** | `/review feature phase` | Natural language or Task tool |
| **Focus** | Phase/feature completion review | Code quality evaluation |
| **Context** | Design docs + checklist | Changed files + project patterns |
| **Output** | Approval verdict | 10-point score report |
| **Best For** | Phase milestone checks | Pre-merge code quality |
| **Use With** | Manual workflow | supervisor pipeline |

**Recommendation:**
- Use `/review` skill for **phase completion checks** (design match, checklist complete)
- Use `code-review` agent for **code quality evaluation** (bugs, security, patterns)
- In supervisor pipeline, both are used: code-review for quality gate, then validate for AC
