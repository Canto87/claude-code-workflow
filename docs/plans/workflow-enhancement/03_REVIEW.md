# Phase 3: Review Agent Skill

> 페이즈 완료 시 코드 품질 검토 에이전트

## 목적

각 구현 페이즈 완료 시점에 코드 품질, 설계 일치성, 테스트 커버리지를
자동으로 검토하여 다음 페이즈로 넘어가기 전 품질을 보장합니다.

## 사용 시나리오

```bash
# 페이즈 완료 후 검토
> /review phase-1

# 전체 기능 검토 (모든 페이즈)
> /review user-auth --all

# 특정 관점으로 검토
> /review --focus security
> /review --focus performance
> /review --focus design-match
```

## 검토 관점 (Review Perspectives)

### 1. 설계 일치성 (Design Conformance)

```yaml
checks:
  - 설계 문서에 명시된 파일이 생성되었는가?
  - 설계된 함수/메서드가 구현되었는가?
  - 데이터 모델이 설계와 일치하는가?
  - API 엔드포인트가 설계대로 구현되었는가?
```

**비교 방식:**
```
설계 문서 (01_PHASE1.md)     구현 코드
─────────────────────────    ─────────────
internal/auth/types.go   →   [✓] 파일 존재
  - User struct          →   [✓] 타입 정의됨
  - Session struct       →   [✓] 타입 정의됨
  - TokenPair struct     →   [✗] 누락됨
```

### 2. 코드 품질 (Code Quality)

```yaml
checks:
  - 에러 핸들링이 적절한가?
  - 하드코딩된 값이 없는가?
  - 함수 길이가 적절한가? (권장: 50줄 이하)
  - 복잡도가 높지 않은가?
  - 중복 코드가 없는가?
```

### 3. 테스트 (Testing)

```yaml
checks:
  - 단위 테스트가 존재하는가?
  - 테스트가 통과하는가?
  - 주요 경로가 커버되는가?
  - 에러 케이스 테스트가 있는가?
```

### 4. 보안 (Security)

```yaml
checks:
  - SQL 인젝션 취약점
  - XSS 취약점
  - 하드코딩된 시크릿
  - 적절한 인증/인가 체크
  - 입력 검증
```

### 5. 성능 (Performance)

```yaml
checks:
  - N+1 쿼리 문제
  - 불필요한 메모리 할당
  - 무한 루프 가능성
  - 인덱스 누락 (DB)
```

## 출력 형식

### 검토 리포트

```
## 🔍 Review Report: user-auth / Phase 1

### Summary
| Aspect | Score | Issues |
|--------|-------|--------|
| Design Conformance | 🟢 90% | 1 minor |
| Code Quality | 🟡 75% | 2 warnings |
| Testing | 🟢 85% | 1 suggestion |
| Security | 🟢 95% | 0 |

**Overall: 🟢 APPROVED** (with minor issues)

---

### 📐 Design Conformance (90%)

✅ **Implemented as Designed**
- `internal/auth/types.go` - User, Session structs
- `internal/auth/store.go` - Database operations
- `internal/auth/handler.go` - HTTP handlers

⚠️ **Minor Deviation**
- `TokenPair` struct missing (documented in design)
  - Recommendation: Add in Phase 2 (JWT) or update design doc

---

### 📊 Code Quality (75%)

⚠️ **Warnings**

1. **Long function** - `handler.go:45 HandleSignup()`
   - Current: 78 lines
   - Recommended: < 50 lines
   - Suggestion: Extract validation logic

2. **Magic number** - `store.go:23`
   ```go
   if len(password) < 8 {  // 8 should be a constant
   ```
   - Suggestion: Use `const MinPasswordLength = 8`

---

### 🧪 Testing (85%)

✅ **Test Coverage**
- `types_test.go` - 100% (model validation)
- `store_test.go` - 80% (DB operations)
- `handler_test.go` - 75% (HTTP handlers)

💡 **Suggestion**
- Add error case test for duplicate email signup

---

### 🔒 Security (95%)

✅ All security checks passed
- No SQL injection vulnerabilities
- Password properly hashed (bcrypt)
- No hardcoded secrets

---

### ✅ Checklist for Next Phase

Before starting Phase 2:
- [ ] Fix magic number in store.go
- [ ] Consider refactoring HandleSignup
- [ ] Add TokenPair struct or update design doc

### Approve Phase Completion?
→ Recommended: **APPROVE** (minor issues can be addressed in refactoring)
```

## 파일 구조

```
skills/review/
├── SKILL.md              # Skill 정의
├── config.yaml           # 검토 설정
├── checklists/
│   ├── design.md         # 설계 일치성 체크리스트
│   ├── quality.md        # 코드 품질 체크리스트
│   ├── testing.md        # 테스트 체크리스트
│   ├── security.md       # 보안 체크리스트
│   └── performance.md    # 성능 체크리스트
└── templates/
    └── report.md         # 리포트 템플릿
```

## config.yaml 스키마

```yaml
# review skill 설정
review:
  # 활성화할 검토 관점
  perspectives:
    - design      # 설계 일치성
    - quality     # 코드 품질
    - testing     # 테스트
    - security    # 보안 (선택)
    - performance # 성능 (선택)

  # 점수 기준
  thresholds:
    pass: 70          # 이 점수 이상이면 통과
    warning: 50       # 이 점수 미만이면 경고

  # 코드 품질 규칙
  quality_rules:
    max_function_length: 50
    max_file_length: 300
    max_complexity: 10

  # 보안 검사 패턴
  security_patterns:
    - pattern: "password\\s*=\\s*[\"']"
      message: "Hardcoded password detected"
    - pattern: "TODO.*security"
      message: "Security TODO found"
```

## SKILL.md 정의

```yaml
---
name: review
description: Review completed phase for code quality, design conformance, and security
allowed-tools: Read, Glob, Grep, Bash, Task
---
```

## 워크플로우 연동

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ /init-impl   │────▶│   개발 작업   │────▶│  /review     │
│ (체크리스트)  │     │ (코드 작성)  │     │ (품질 검토)  │
└──────────────┘     └──────────────┘     └──────────────┘
       │                                          │
       │                                          ▼
       │                                  ┌──────────────┐
       │                                  │  통과?       │
       │                                  └──────────────┘
       │                                    │        │
       │                                   Yes       No
       │                                    │        │
       │                                    ▼        ▼
       │                              다음 Phase   수정 후
       │                                         재검토
       └──────────────────────────────────────────────┘
```

## 자동화 옵션

### Git Hook 연동

```bash
# .git/hooks/pre-push
#!/bin/bash
claude "/review --quick"
if [ $? -ne 0 ]; then
  echo "Review failed. Please fix issues before pushing."
  exit 1
fi
```

### CI/CD 연동

```yaml
# .github/workflows/review.yml
- name: Code Review
  run: claude "/review --ci --output json" > review.json
```

## 확장 가능성

- **자동 수정**: `--fix` 옵션으로 간단한 이슈 자동 수정
- **커스텀 룰**: 프로젝트별 검토 규칙 추가
- **리뷰 히스토리**: 이전 리뷰 결과와 비교
- **팀 표준**: 팀 코딩 컨벤션 검사
