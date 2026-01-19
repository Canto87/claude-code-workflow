# Phase 1: Health Check Skill

> 프로젝트 설정 진단 및 최적화 제안

## 목적

Claude Code 프로젝트의 설정 상태를 점검하고, 누락된 설정이나 잠재적 문제를 사전에 발견합니다.

## 사용 시나리오

```bash
# 프로젝트 시작 시
> /health-check

# 새 팀원 온보딩 시
> /health-check --verbose

# CI/CD 파이프라인에서
> /health-check --ci
```

## 검사 항목

### 1. 필수 파일 검사 (Required Files)

| 파일 | 설명 | 심각도 |
|------|------|--------|
| `.claude/settings.json` | Claude Code 설정 | 🔴 error |
| `CLAUDE.md` | 프로젝트 지침 | 🟡 warning |
| `.gitignore` | Git 제외 규칙 | 🟡 warning |
| `README.md` | 프로젝트 설명 | 🟢 info |

### 2. 디렉토리 구조 검사 (Directory Structure)

| 디렉토리 | 설명 | 심각도 |
|----------|------|--------|
| `.claude/commands/` | 커스텀 명령어 | 🟢 info |
| `docs/plans/` | 설계 문서 | 🟢 info |

### 3. 설정 유효성 검사 (Settings Validation)

```yaml
# .claude/settings.json 검사 항목
checks:
  - JSON 문법 유효성
  - permissions.allow 배열 존재
  - permissions.deny 배열 존재
  - hooks 설정 유효성
```

### 4. Hook 검사 (Hook Validation)

```yaml
hooks:
  - 실행 권한 (chmod +x)
  - shebang 존재 (#!/bin/bash 등)
  - 참조된 명령어 존재
```

### 5. Skill 설정 검사 (Skill Validation)

```yaml
skills:
  - SKILL.md 존재
  - config.yaml 문법 유효성
  - 필수 필드 존재 (name, description)
```

## 출력 형식

### 정상 출력

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

### 문제 발견 시

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

## 파일 구조

```
skills/health-check/
├── SKILL.md              # Skill 정의
├── config.yaml           # 검사 항목 설정
└── templates/
    └── report.md         # 리포트 템플릿
```

## config.yaml 스키마

```yaml
# 검사 설정
checks:
  required_files:
    - path: string        # 파일 경로
      description: string # 설명
      severity: error|warning|info

  required_dirs:
    - path: string
      description: string
      severity: error|warning|info

  settings:
    validate_json: boolean
    required_keys:
      - key: string       # JSON 경로 (예: permissions.allow)
        severity: error|warning|info

  hooks:
    check_executable: boolean
    check_shebang: boolean

  skills:
    check_skill_md: boolean
    check_config_yaml: boolean
```

## SKILL.md 정의

```yaml
---
name: health-check
description: Diagnose project configuration and suggest optimizations
allowed-tools: Read, Glob, Bash
---
```

## 구현 우선순위

1. **필수 파일 검사** - 가장 기본적인 검사
2. **설정 JSON 유효성** - 문법 오류 발견
3. **Hook 실행 권한** - 흔한 실수 방지
4. **리포트 출력** - 명확한 피드백

## 확장 가능성

- `--fix` 옵션: 자동 수정 (예: chmod +x)
- `--json` 옵션: CI/CD용 JSON 출력
- `--watch` 옵션: 파일 변경 감시
