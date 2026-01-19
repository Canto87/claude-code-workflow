# Phase 1: Health Check Skill

> Project configuration diagnosis and optimization suggestions

## Purpose

Check the configuration status of Claude Code projects and discover missing settings or potential issues in advance.

## Usage Scenarios

```bash
# At project start
> /health-check

# When onboarding new team members
> /health-check --verbose

# In CI/CD pipelines
> /health-check --ci
```

## Check Items

### 1. Required Files

| File | Description | Severity |
|------|-------------|----------|
| `.claude/settings.json` | Claude Code settings | 🔴 error |
| `CLAUDE.md` | Project guidelines | 🟡 warning |
| `.gitignore` | Git exclude rules | 🟡 warning |
| `README.md` | Project description | 🟢 info |

### 2. Directory Structure

| Directory | Description | Severity |
|-----------|-------------|----------|
| `.claude/commands/` | Custom commands | 🟢 info |
| `docs/plans/` | Design documents | 🟢 info |

### 3. Settings Validation

```yaml
# .claude/settings.json check items
checks:
  - JSON syntax validity
  - permissions.allow array exists
  - permissions.deny array exists
  - hooks configuration validity
```

### 4. Hook Validation

```yaml
hooks:
  - Execution permission (chmod +x)
  - Shebang exists (#!/bin/bash etc.)
  - Referenced commands exist
```

### 5. Skill Validation

```yaml
skills:
  - SKILL.md exists
  - config.yaml syntax validity
  - Required fields exist (name, description)
```

## Output Format

### Normal Output

```
## 🏥 Health Check Report

✅ Project Status: HEALTHY

### Summary
- Errors: 0
- Warnings: 1
- Info: 3

### Details

#### ✅ Required Files
- [✓] .claude/settings.json
- [✓] CLAUDE.md
- [✓] .gitignore

#### ⚠️ Warnings
- [ ] README.md could include more setup instructions

#### 💡 Recommendations
- Consider adding `.claude/commands/` for custom slash commands
- Add `docs/plans/` for design documents
```

### When Issues Found

```
## 🏥 Health Check Report

❌ Project Status: NEEDS ATTENTION

### Summary
- Errors: 2
- Warnings: 1
- Info: 2

### 🔴 Errors (Must Fix)

1. **Missing .claude/settings.json**
   - Impact: Claude Code may not work correctly
   - Fix: Run `claude init` or create manually

2. **Hook not executable: hooks/pre-commit.sh**
   - Impact: Hook will not run
   - Fix: `chmod +x hooks/pre-commit.sh`

### 🟡 Warnings (Should Fix)

1. **CLAUDE.md is empty**
   - Impact: Claude lacks project context
   - Fix: Add project description and guidelines

### 🟢 Info

- No custom commands found (optional)
- No design documents found (optional)
```

## File Structure

```
skills/health-check/
├── SKILL.md              # Skill definition
├── config.yaml           # Check item settings
└── templates/
    └── report.md         # Report template
```

## config.yaml Schema

```yaml
# Check settings
checks:
  required_files:
    - path: string        # File path
      description: string # Description
      severity: error|warning|info

  required_dirs:
    - path: string
      description: string
      severity: error|warning|info

  settings:
    validate_json: boolean
    required_keys:
      - key: string       # JSON path (e.g., permissions.allow)
        severity: error|warning|info

  hooks:
    check_executable: boolean
    check_shebang: boolean

  skills:
    check_skill_md: boolean
    check_config_yaml: boolean
```

## SKILL.md Definition

```yaml
---
name: health-check
description: Diagnose project configuration and suggest optimizations
allowed-tools: Read, Glob, Bash
---
```

## Implementation Priority

1. **Required files check** - Most basic check
2. **Settings JSON validity** - Syntax error detection
3. **Hook execution permission** - Prevent common mistakes
4. **Report output** - Clear feedback

## Extensibility

- `--fix` option: Auto-fix (e.g., chmod +x)
- `--json` option: JSON output for CI/CD
- `--watch` option: File change monitoring
