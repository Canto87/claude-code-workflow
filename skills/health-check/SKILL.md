---
name: health-check
description: Diagnose project configuration and suggest optimizations. Use for project setup verification, onboarding, or troubleshooting.
allowed-tools: Read, Glob, Bash
---

# Health Check Skill

Diagnoses Claude Code project configuration and provides actionable recommendations.

## When to Use

- Starting work on a new project
- Onboarding new team members
- Troubleshooting configuration issues
- Verifying project setup after changes

## Configuration File

Skill settings are managed in `config.yaml` in the same folder.

## Execution Flow

```
1. Load Config           → Read config.yaml for check definitions
       ↓
2. Check Required Files  → Verify essential files exist
       ↓
3. Check Directories     → Verify directory structure
       ↓
4. Validate Settings     → Parse and validate .claude/settings.json
       ↓
5. Check Hooks           → Verify hook files are executable
       ↓
6. Check Skills          → Validate skill configurations
       ↓
7. Generate Report       → Output formatted health report
```

## Check Categories

### 1. Required Files

| File | Description | Severity |
|------|-------------|----------|
| `.claude/settings.json` | Claude Code settings | 🔴 error |
| `CLAUDE.md` | Project instructions | 🟡 warning |
| `.gitignore` | Git ignore rules | 🟡 warning |
| `README.md` | Project description | 🟢 info |

### 2. Directory Structure

| Directory | Description | Severity |
|-----------|-------------|----------|
| `.claude/commands/` | Custom slash commands | 🟢 info |
| `docs/plans/` | Design documents | 🟢 info |

### 3. Settings Validation

For `.claude/settings.json`:
- JSON syntax validity
- `permissions.allow` array exists
- `permissions.deny` array exists
- Hooks configuration validity

### 4. Hook Validation

For each hook file:
- Executable permission (`chmod +x`)
- Shebang line exists (`#!/bin/bash` etc.)
- Referenced commands available

### 5. Skill Validation

For each skill in `skills/` or `.claude/commands/`:
- `SKILL.md` exists with valid frontmatter
- `config.yaml` has valid YAML syntax
- Required fields present (name, description)

## Output Format

### Healthy Project

```
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

#### ✅ Settings
- [✓] Valid JSON syntax
- [✓] permissions.allow configured
- [✓] permissions.deny configured

#### ✅ Hooks
- [✓] hooks/slack-notify.sh (executable)

#### 💡 Recommendations
- All checks passed!
```

### Issues Found

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

### 💡 Recommendations
- Consider adding custom commands to `.claude/commands/`
```

## Severity Levels

| Level | Icon | Meaning |
|-------|------|---------|
| error | 🔴 | Must fix - blocks functionality |
| warning | 🟡 | Should fix - may cause issues |
| info | 🟢 | Nice to have - optional improvement |

## Options

| Option | Description |
|--------|-------------|
| (default) | Standard check with formatted report |
| `--verbose` | Include all details and recommendations |
| `--ci` | Exit with error code if errors found |

## Related Skills

- After health check passes → Ready to use `/plan-feature`
- Hook issues found → Check `hooks/` documentation
