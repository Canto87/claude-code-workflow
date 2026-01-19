# Phase 2: Status/Progress Skill

> 구현 진행 상황 대시보드

## 목적

init-impl로 생성된 체크리스트의 진행 상황을 시각화하고,
전체 구현 현황을 한눈에 파악할 수 있도록 합니다.

## 사용 시나리오

```bash
# 현재 기능 진행 상황 확인
> /status

# 특정 기능 상태 확인
> /status user-auth

# 전체 프로젝트 상태 요약
> /status --all
```

## 데이터 소스

```
docs/plans/{feature_name}/
├── 00_OVERVIEW.md
├── 01_PHASE1.md
├── 02_PHASE2.md
└── checklist.md          ← 진행 상황 파싱
```

### checklist.md 파싱 규칙

```markdown
## Phase 1: Basic Auth
- [x] Create user model        ← 완료
- [x] Implement signup API     ← 완료
- [ ] Add login endpoint       ← 미완료
- [ ] Write unit tests         ← 미완료

## Phase 2: JWT Management
- [ ] Generate access token    ← 미완료
- [ ] Implement refresh logic  ← 미완료
```

**파싱 결과:**
```yaml
phases:
  - name: "Phase 1: Basic Auth"
    total: 4
    completed: 2
    progress: 50%
  - name: "Phase 2: JWT Management"
    total: 2
    completed: 0
    progress: 0%
overall:
  total: 6
  completed: 2
  progress: 33%
```

## 출력 형식

### 기본 출력

```
## 📊 Implementation Status: user-auth

### Overall Progress
██████████░░░░░░░░░░ 50% (12/24 tasks)

### Phase Breakdown

| Phase | Progress | Tasks | Status |
|-------|----------|-------|--------|
| Phase 1: Basic Auth | ████████████████████ 100% | 6/6 | ✅ Done |
| Phase 2: JWT | ████████████░░░░░░░░ 60% | 3/5 | 🔄 In Progress |
| Phase 3: Session | ████████░░░░░░░░░░░░ 40% | 2/5 | 🔄 In Progress |
| Phase 4: Social | ░░░░░░░░░░░░░░░░░░░░ 0% | 0/8 | ⏳ Pending |

### Current Focus
🔄 **Phase 2: JWT Management**
   - [x] Generate access token
   - [x] Implement refresh logic
   - [x] Token validation
   - [ ] Blacklist expired tokens  ← Next
   - [ ] Add token expiry config

### Blockers
⚠️ No blockers identified

### Time Tracking (Optional)
- Started: 2024-01-15
- Last activity: 2024-01-18
- Estimated remaining: 2 phases
```

### 전체 프로젝트 요약 (`--all`)

```
## 📊 Project Status Overview

### Active Features

| Feature | Progress | Phases | Last Updated |
|---------|----------|--------|--------------|
| user-auth | ██████████░░ 50% | 2/4 | 2 days ago |
| payment | ████░░░░░░░░ 20% | 1/5 | 5 days ago |
| dashboard | ░░░░░░░░░░░░ 0% | 0/3 | - |

### Summary
- Total features: 3
- In progress: 2
- Completed: 0
- Not started: 1

### Recommended Next Action
→ Continue with "user-auth" Phase 2 (60% complete)
```

## 파일 구조

```
skills/status/
├── SKILL.md              # Skill 정의
├── config.yaml           # 설정
└── templates/
    ├── status.md         # 단일 기능 템플릿
    └── overview.md       # 전체 요약 템플릿
```

## config.yaml 스키마

```yaml
# status skill 설정
paths:
  plans: "docs/plans"     # 설계 문서 경로

parsing:
  checklist_file: "checklist.md"
  checkbox_pattern: "- \\[([ x])\\]"
  phase_pattern: "^## Phase \\d+:"

display:
  progress_bar_width: 20
  show_time_tracking: false
  show_blockers: true
```

## SKILL.md 정의

```yaml
---
name: status
description: Display implementation progress dashboard for features
allowed-tools: Read, Glob
---
```

## 핵심 로직

### 1. 체크리스트 파싱

```
Input: checklist.md 내용
Output:
  {
    phases: [
      { name, total, completed, items: [...] }
    ],
    overall: { total, completed, percentage }
  }
```

### 2. 진행률 계산

```
phase_progress = completed_items / total_items * 100
overall_progress = sum(completed) / sum(total) * 100
```

### 3. 상태 결정

```
status =
  if progress == 100%: "✅ Done"
  elif progress > 0%: "🔄 In Progress"
  else: "⏳ Pending"
```

### 4. 현재 포커스 찾기

```
current_focus = first phase where 0% < progress < 100%
next_task = first unchecked item in current_focus
```

## 연동

### init-impl과 연동

```
/init-impl 실행 후 → checklist.md 생성
/status 실행 → checklist.md 파싱하여 진행 상황 표시
```

### plan-feature와 연동

```
/plan-feature 완료 → 00_OVERVIEW.md에 Phase 목록 존재
/status → Phase 메타데이터 참조 가능
```

## 확장 가능성

- **Slack 연동**: 일일 진행 상황 자동 리포트
- **Git 연동**: 커밋과 체크리스트 항목 자동 매칭
- **번다운 차트**: 시간 경과에 따른 진행률 시각화
