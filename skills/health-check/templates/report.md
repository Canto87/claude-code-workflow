# Health Check Report Template

Use this template structure when generating health check reports.

## Report Structure

```markdown
## 🏥 Health Check Report

{STATUS_ICON} Project Status: {STATUS}

### Summary
- Errors: {ERROR_COUNT}
- Warnings: {WARNING_COUNT}
- Info: {INFO_COUNT}

{IF_ERRORS}
### 🔴 Errors (Must Fix)

{FOR_EACH_ERROR}
{INDEX}. **{TITLE}**
   - Impact: {IMPACT}
   - Fix: {FIX_INSTRUCTION}
{END_FOR}
{END_IF}

{IF_WARNINGS}
### 🟡 Warnings (Should Fix)

{FOR_EACH_WARNING}
{INDEX}. **{TITLE}**
   - Impact: {IMPACT}
   - Fix: {FIX_INSTRUCTION}
{END_FOR}
{END_IF}

### Details

#### {SECTION_ICON} Required Files
{FOR_EACH_FILE}
- [{CHECK_MARK}] {FILE_PATH} {STATUS_NOTE}
{END_FOR}

#### {SECTION_ICON} Directory Structure
{FOR_EACH_DIR}
- [{CHECK_MARK}] {DIR_PATH} {STATUS_NOTE}
{END_FOR}

#### {SECTION_ICON} Settings Validation
{FOR_EACH_SETTING}
- [{CHECK_MARK}] {SETTING_KEY} {STATUS_NOTE}
{END_FOR}

#### {SECTION_ICON} Hooks
{FOR_EACH_HOOK}
- [{CHECK_MARK}] {HOOK_PATH} {STATUS_NOTE}
{END_FOR}

#### {SECTION_ICON} Skills
{FOR_EACH_SKILL}
- [{CHECK_MARK}] {SKILL_NAME} {STATUS_NOTE}
{END_FOR}

### 💡 Recommendations
{FOR_EACH_RECOMMENDATION}
- {RECOMMENDATION}
{END_FOR}
```

## Status Values

| Status | Icon | Condition |
|--------|------|-----------|
| HEALTHY | ✅ | errors = 0 AND warnings = 0 |
| GOOD | ✅ | errors = 0 AND warnings > 0 |
| NEEDS ATTENTION | ❌ | errors > 0 |

## Check Marks

| Mark | Meaning |
|------|---------|
| ✓ | Check passed |
| ✗ | Check failed |
| - | Not applicable |

## Example Output

### Healthy Project

```markdown
## 🏥 Health Check Report

✅ Project Status: HEALTHY

### Summary
- Errors: 0
- Warnings: 0
- Info: 2

### Details

#### ✅ Required Files
- [✓] .claude/settings.json
- [✓] CLAUDE.md
- [✓] .gitignore
- [✓] README.md

#### ✅ Directory Structure
- [✓] .claude/commands
- [✓] docs/plans

#### ✅ Settings Validation
- [✓] Valid JSON syntax
- [✓] permissions configured

#### ✅ Hooks
- [✓] hooks/slack-notify.sh (executable, valid shebang)

#### ✅ Skills
- [✓] plan-feature (valid)
- [✓] init-impl (valid)
- [✓] slack-notify (valid)
- [✓] worktree (valid)

### 💡 Recommendations
- All checks passed! Your project is well configured.
```

### Project with Issues

```markdown
## 🏥 Health Check Report

❌ Project Status: NEEDS ATTENTION

### Summary
- Errors: 2
- Warnings: 1
- Info: 3

### 🔴 Errors (Must Fix)

1. **Missing .claude/settings.json**
   - Impact: Claude Code cannot load project settings
   - Fix: Run `claude init` or create the file manually

2. **Hook not executable: hooks/deploy.sh**
   - Impact: Hook will fail to run
   - Fix: Run `chmod +x hooks/deploy.sh`

### 🟡 Warnings (Should Fix)

1. **CLAUDE.md is empty**
   - Impact: Claude lacks context about your project
   - Fix: Add project description, coding standards, and guidelines

### Details

#### ⚠️ Required Files
- [✗] .claude/settings.json (missing)
- [✗] CLAUDE.md (empty)
- [✓] .gitignore
- [✓] README.md

#### ✅ Directory Structure
- [✓] .claude/commands
- [-] docs/plans (not found, optional)

#### ⚠️ Settings Validation
- [✗] Cannot validate - settings file missing

#### ⚠️ Hooks
- [✗] hooks/deploy.sh (not executable)
- [✓] hooks/slack-notify.sh (ok)

#### ✅ Skills
- [✓] plan-feature (valid)
- [✓] init-impl (valid)

### 💡 Recommendations
- Create .claude/settings.json to configure Claude Code
- Add content to CLAUDE.md for better AI assistance
- Run `chmod +x hooks/deploy.sh` to fix hook permission
```
