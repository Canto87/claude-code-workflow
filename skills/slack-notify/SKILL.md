---
name: slack-notify
description: Slack 채널로 스킬 완료 알림 전송. PostToolUse hooks로 자동 트리거됨.
allowed-tools:
  - Bash
  - Read
---

# Slack Notification Skill

Claude Code 스킬(plan-feature, init-impl, phase 명령어) 완료 시 Slack 채널로 알림을 보내는 시스템입니다.

## When to Use

이 스킬은 주로 PostToolUse hooks에 의해 **자동으로 트리거**됩니다:

- `plan-feature` 스킬 완료 시
- `init-impl` 스킬 완료 시
- `/phase{N}` 명령어 완료 시

수동으로 테스트하거나 설정을 확인할 때도 사용할 수 있습니다.

## Prerequisites

1. **Slack Incoming Webhook 생성**
   - https://api.slack.com/messaging/webhooks 에서 생성
   - 대상 채널 선택

2. **config.yaml 설정**
   - `webhook_url`: 실제 Webhook URL로 교체
   - `channel`: 대상 채널명

3. **Hooks 등록**
   - `.claude/settings.local.json`에 PostToolUse hook 설정

## Configuration

`config.yaml` 파일에서 설정:

```yaml
# Webhook URL (필수)
webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# 대상 채널
channel: "#claude-notifications"

# 모니터링할 스킬
target_skills:
  - "plan-feature"
  - "init-impl"
  - pattern: "*:phase*"
```

## Monitored Skills

| 스킬 | 트리거 조건 | 알림 내용 |
|------|------------|----------|
| `plan-feature` | 설계 문서 생성 완료 | 생성된 파일 목록, 다음 단계 안내 |
| `init-impl` | 구현 시스템 생성 완료 | 체크리스트, 명령어 목록, 다음 단계 안내 |
| `/phase{N}` | Phase 구현 완료 | 완료된 Phase 번호, 다음 Phase 안내 |

## Message Format

### plan-feature 완료

```
:clipboard: Feature Design Complete

Feature planning is complete.

Generated Files:
- docs/plans/{feature}/00_OVERVIEW.md
- Phase documents

Next Step: Run `init-impl` skill
```

### init-impl 완료

```
:hammer_and_wrench: Implementation System Ready

Implementation system is ready.

Generated Files:
- docs/checklists/{feature}.md
- .claude/commands/{feature}/

Next Step: Start with `/phase1` command
```

### Phase 완료

```
:white_check_mark: Phase {N} Complete

Phase {N} of {feature} is complete.

Checklist: docs/checklists/{feature}.md

Next Step: Continue with `/phase{N+1}`
```

## Setup Verification

설정이 올바른지 확인하려면:

1. `config.yaml`의 `webhook_url`이 실제 URL인지 확인
2. `.claude/settings.local.json`에 hooks가 등록되어 있는지 확인
3. `plan-feature` 또는 `init-impl` 스킬을 실행하여 알림 수신 확인

## Troubleshooting

| 문제 | 해결 방법 |
|------|----------|
| 알림이 오지 않음 | webhook_url이 올바른지 확인 |
| 채널이 틀림 | config.yaml의 channel과 webhook 설정 일치 확인 |
| 특정 스킬만 알림 안 옴 | target_skills에 해당 스킬이 포함되어 있는지 확인 |
| 스크립트 오류 | `bash -x .claude/hooks/slack-notify.sh` 로 디버깅 |

## Dependencies

- `jq`: JSON 파싱 (macOS 기본 포함)
- `curl`: HTTP 요청 (기본 포함)

## Architecture

```
PostToolUse Hook (matcher: "Skill")
    |
    v
slack-notify.sh
    |
    +-- skill name 확인 (plan-feature, init-impl, *:phase*)
    |
    +-- config.yaml 읽기 (webhook_url, channel)
    |
    +-- 메시지 포맷팅
    |
    v
Slack Webhook API
```

## Related Skills

- `plan-feature`: 기능 설계 문서 생성
- `init-impl`: 구현 시스템 생성
- `implement-layer`: Clean Architecture 계층 구현
