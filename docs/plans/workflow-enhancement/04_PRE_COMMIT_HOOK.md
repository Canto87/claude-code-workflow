# Phase 4: Pre-commit Hook 강화

> 커밋 전 품질 검증 자동화

## 목적

커밋 시점에 자동으로 품질 검사를 수행하여, 불완전하거나 품질이 낮은
코드가 저장소에 들어가는 것을 방지합니다.

## 사용 시나리오

```bash
# Git commit 시 자동 실행
$ git commit -m "Add login feature"

🔍 Running pre-commit checks...
✅ Checklist validation passed
✅ No TODO comments in staged files
✅ Tests passed
✅ Lint passed

Commit successful!
```

## 검사 항목

### 1. 체크리스트 검증 (Checklist Validation)

현재 작업 중인 feature의 checklist.md를 확인하여,
커밋하려는 변경사항과 관련된 체크리스트 항목이 완료되었는지 확인합니다.

```yaml
check: checklist_validation
behavior:
  - 변경된 파일과 관련된 체크리스트 항목 찾기
  - 해당 항목이 [x]로 체크되어 있는지 확인
  - 미완료 시 경고 (블로킹 아님)
```

### 2. TODO/FIXME 검사

```yaml
check: todo_comments
patterns:
  - "TODO"
  - "FIXME"
  - "XXX"
  - "HACK"
behavior:
  - staged 파일에서 패턴 검색
  - 발견 시 경고 출력 (블로킹 아님)
  - --strict 모드에서는 블로킹
```

### 3. 테스트 실행

```yaml
check: run_tests
behavior:
  - 변경된 파일과 관련된 테스트만 실행
  - 실패 시 커밋 블로킹
  - --skip-tests로 우회 가능
```

### 4. Lint 검사

```yaml
check: lint
behavior:
  - 프로젝트의 린터 실행 (eslint, golint 등)
  - 에러 시 커밋 블로킹
  - 경고는 출력만
```

### 5. 시크릿 검사

```yaml
check: secrets_detection
patterns:
  - API keys (AKIA, sk-, pk_)
  - Passwords in config
  - Private keys
behavior:
  - 발견 시 커밋 블로킹
  - 절대 우회 불가
```

## 출력 형식

### 모든 검사 통과

```
🔍 Pre-commit Quality Check
═══════════════════════════

✅ Checklist     Related items are completed
✅ TODO/FIXME    No issues found
✅ Tests         3 tests passed (0.5s)
✅ Lint          No errors
✅ Secrets       No secrets detected

═══════════════════════════
All checks passed! Proceeding with commit.
```

### 일부 경고

```
🔍 Pre-commit Quality Check
═══════════════════════════

⚠️ Checklist     1 related item not checked
   └─ [ ] Add input validation (internal/auth/handler.go)

⚠️ TODO/FIXME    2 comments found
   └─ internal/auth/store.go:45: TODO: add index
   └─ internal/auth/handler.go:78: FIXME: handle edge case

✅ Tests         5 tests passed (1.2s)
✅ Lint          No errors
✅ Secrets       No secrets detected

═══════════════════════════
⚠️ Warnings found, but proceeding with commit.
   Consider addressing these issues.
```

### 블로킹 에러

```
🔍 Pre-commit Quality Check
═══════════════════════════

✅ Checklist     OK
✅ TODO/FIXME    OK

❌ Tests         2 tests failed
   └─ TestLogin: expected 200, got 401
   └─ TestSignup: timeout after 5s

❌ Lint          3 errors
   └─ handler.go:12: undefined: UserService
   └─ store.go:8: unused import "fmt"
   └─ types.go:25: missing return

✅ Secrets       OK

═══════════════════════════
❌ Commit blocked. Please fix the errors above.

To skip tests (not recommended):
  git commit --no-verify
```

## 파일 구조

```
hooks/
├── pre-commit-quality.sh     # 메인 훅 스크립트
├── checks/
│   ├── checklist.sh          # 체크리스트 검증
│   ├── todo.sh               # TODO 검사
│   ├── tests.sh              # 테스트 실행
│   ├── lint.sh               # 린트 검사
│   └── secrets.sh            # 시크릿 검사
└── config/
    └── pre-commit.yaml       # 훅 설정
```

## pre-commit.yaml 설정

```yaml
# Pre-commit hook configuration

checks:
  checklist:
    enabled: true
    blocking: false           # 경고만, 블로킹 안함
    plans_path: "docs/plans"

  todo:
    enabled: true
    blocking: false
    patterns:
      - "TODO"
      - "FIXME"
    strict_mode: false        # true면 블로킹

  tests:
    enabled: true
    blocking: true            # 실패 시 블로킹
    command: "go test ./..."  # 또는 npm test, pytest 등
    timeout: 60               # 초

  lint:
    enabled: true
    blocking: true
    command: "golangci-lint run"

  secrets:
    enabled: true
    blocking: true            # 항상 블로킹
    patterns:
      - "AKIA[0-9A-Z]{16}"    # AWS Access Key
      - "sk-[a-zA-Z0-9]{48}"  # OpenAI API Key
      - "password\\s*=\\s*[\"'][^\"']+[\"']"

# 파일 필터
filters:
  include:
    - "*.go"
    - "*.ts"
    - "*.py"
  exclude:
    - "*_test.go"
    - "*.mock.*"
    - "vendor/*"
    - "node_modules/*"
```

## 설치 방법

### 자동 설치 (install.sh 확장)

```bash
# install.sh에 추가
install_pre_commit_hook() {
  local hook_path=".git/hooks/pre-commit"

  if [ -f "$hook_path" ]; then
    echo "Pre-commit hook already exists. Backup and replace? (y/n)"
    read answer
    if [ "$answer" != "y" ]; then
      return
    fi
    cp "$hook_path" "$hook_path.backup"
  fi

  cp hooks/pre-commit-quality.sh "$hook_path"
  chmod +x "$hook_path"
  echo "✅ Pre-commit hook installed"
}
```

### 수동 설치

```bash
# 훅 복사
cp hooks/pre-commit-quality.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 또는 심볼릭 링크
ln -s ../../hooks/pre-commit-quality.sh .git/hooks/pre-commit
```

## 훅 스크립트 구조

```bash
#!/bin/bash
# hooks/pre-commit-quality.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Pre-commit Quality Check"
echo "═══════════════════════════"

WARNINGS=0
ERRORS=0

# 1. 체크리스트 검증
source hooks/checks/checklist.sh
if ! check_checklist; then
  ((WARNINGS++))
fi

# 2. TODO 검사
source hooks/checks/todo.sh
if ! check_todos; then
  ((WARNINGS++))
fi

# 3. 테스트 실행
source hooks/checks/tests.sh
if ! run_tests; then
  ((ERRORS++))
fi

# 4. 린트 검사
source hooks/checks/lint.sh
if ! run_lint; then
  ((ERRORS++))
fi

# 5. 시크릿 검사
source hooks/checks/secrets.sh
if ! check_secrets; then
  ((ERRORS++))
fi

echo "═══════════════════════════"

if [ $ERRORS -gt 0 ]; then
  echo -e "${RED}❌ Commit blocked. Please fix the errors above.${NC}"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo -e "${YELLOW}⚠️ Warnings found, but proceeding with commit.${NC}"
  exit 0
else
  echo -e "${GREEN}All checks passed! Proceeding with commit.${NC}"
  exit 0
fi
```

## Claude Code settings.json 연동

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": ["hooks/pre-commit-quality.sh"]
      }
    ]
  }
}
```

## 확장 가능성

- **husky 연동**: Node.js 프로젝트에서 husky와 통합
- **커밋 메시지 검증**: conventional commits 형식 검사
- **브랜치 보호**: 특정 브랜치 직접 커밋 방지
- **파일 크기 제한**: 큰 파일 커밋 방지
