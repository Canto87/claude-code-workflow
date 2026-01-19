#!/bin/bash
# Pre-commit Quality Hook
# Validates code quality before allowing commits
#
# Installation:
#   1. Copy to .git/hooks/pre-commit (or create symlink)
#   2. chmod +x .git/hooks/pre-commit
#
# Or add to .claude/settings.json hooks section

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

echo "🔍 Running pre-commit quality checks..."
echo ""

# ============================================
# 1. Check for uncommitted checklist items
# ============================================
check_checklist() {
    echo "📋 Checking checklist completion..."

    # Find checklist.md files in staged changes
    CHECKLISTS=$(git diff --cached --name-only | grep -E "checklist\.md$" || true)

    if [ -n "$CHECKLISTS" ]; then
        for file in $CHECKLISTS; do
            # Count incomplete items
            INCOMPLETE=$(grep -c "^\s*- \[ \]" "$file" 2>/dev/null || echo "0")
            COMPLETE=$(grep -c "^\s*- \[x\]" "$file" 2>/dev/null || echo "0")

            if [ "$INCOMPLETE" -gt 0 ]; then
                echo -e "  ${YELLOW}⚠️  $file has $INCOMPLETE incomplete items${NC}"
                ((WARNINGS++))
            else
                echo -e "  ${GREEN}✓${NC} $file - all items complete"
            fi
        done
    else
        echo "  No checklist files in commit"
    fi
    echo ""
}

# ============================================
# 2. Check for TODO/FIXME comments
# ============================================
check_todos() {
    echo "📝 Checking for TODO/FIXME comments..."

    # Get staged files (excluding certain patterns)
    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | \
        grep -vE "\.(md|txt|json|yaml|yml)$" | \
        grep -vE "^(vendor|node_modules|\.git)/" || true)

    if [ -n "$STAGED_FILES" ]; then
        for file in $STAGED_FILES; do
            if [ -f "$file" ]; then
                # Check for TODO, FIXME, HACK, XXX
                TODOS=$(grep -nE "(TODO|FIXME|HACK|XXX):" "$file" 2>/dev/null || true)
                if [ -n "$TODOS" ]; then
                    echo -e "  ${YELLOW}⚠️  $file contains TODO comments:${NC}"
                    echo "$TODOS" | head -3 | sed 's/^/      /'
                    TODO_COUNT=$(echo "$TODOS" | wc -l)
                    if [ "$TODO_COUNT" -gt 3 ]; then
                        echo "      ... and $((TODO_COUNT - 3)) more"
                    fi
                    ((WARNINGS++))
                fi
            fi
        done

        if [ "$WARNINGS" -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} No TODO/FIXME comments found"
        fi
    else
        echo "  No code files in commit"
    fi
    echo ""
}

# ============================================
# 3. Check for secrets/credentials
# ============================================
check_secrets() {
    echo "🔐 Checking for potential secrets..."

    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM || true)
    SECRET_FOUND=0

    if [ -n "$STAGED_FILES" ]; then
        for file in $STAGED_FILES; do
            if [ -f "$file" ]; then
                # Skip binary files and common non-code files
                if file "$file" | grep -q "text"; then
                    # Check for common secret patterns
                    SECRETS=$(grep -nEi \
                        "(password|secret|api_key|apikey|token|credential)\s*[=:]\s*['\"][^'\"]+['\"]" \
                        "$file" 2>/dev/null | \
                        grep -v "example\|sample\|test\|mock\|fake\|placeholder" || true)

                    if [ -n "$SECRETS" ]; then
                        echo -e "  ${RED}🔴 $file may contain secrets:${NC}"
                        echo "$SECRETS" | head -3 | sed 's/^/      /'
                        ((ERRORS++))
                        SECRET_FOUND=1
                    fi

                    # Check for .env files
                    if [[ "$file" == ".env"* ]] && [[ "$file" != ".env.example"* ]]; then
                        echo -e "  ${RED}🔴 Attempting to commit $file (environment file)${NC}"
                        ((ERRORS++))
                        SECRET_FOUND=1
                    fi
                fi
            fi
        done

        if [ "$SECRET_FOUND" -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} No obvious secrets detected"
        fi
    fi
    echo ""
}

# ============================================
# 4. Check for large files
# ============================================
check_large_files() {
    echo "📦 Checking for large files..."

    MAX_SIZE=1048576  # 1MB in bytes
    LARGE_FILES=0

    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM || true)

    if [ -n "$STAGED_FILES" ]; then
        for file in $STAGED_FILES; do
            if [ -f "$file" ]; then
                SIZE=$(wc -c < "$file")
                if [ "$SIZE" -gt "$MAX_SIZE" ]; then
                    SIZE_MB=$(echo "scale=2; $SIZE / 1048576" | bc)
                    echo -e "  ${YELLOW}⚠️  $file is ${SIZE_MB}MB (>1MB)${NC}"
                    ((WARNINGS++))
                    LARGE_FILES=1
                fi
            fi
        done

        if [ "$LARGE_FILES" -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} No large files detected"
        fi
    fi
    echo ""
}

# ============================================
# 5. Run linter (if available)
# ============================================
check_lint() {
    echo "🧹 Running linter..."

    # Detect project type and run appropriate linter
    if [ -f "go.mod" ]; then
        if command -v golangci-lint &> /dev/null; then
            STAGED_GO=$(git diff --cached --name-only --diff-filter=ACM | grep "\.go$" || true)
            if [ -n "$STAGED_GO" ]; then
                if ! golangci-lint run --new-from-rev=HEAD~1 2>/dev/null; then
                    echo -e "  ${YELLOW}⚠️  Linter found issues${NC}"
                    ((WARNINGS++))
                else
                    echo -e "  ${GREEN}✓${NC} Go linter passed"
                fi
            fi
        else
            echo "  golangci-lint not installed, skipping"
        fi
    elif [ -f "package.json" ]; then
        if [ -f "node_modules/.bin/eslint" ]; then
            STAGED_JS=$(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(js|ts|jsx|tsx)$" || true)
            if [ -n "$STAGED_JS" ]; then
                if ! npx eslint $STAGED_JS 2>/dev/null; then
                    echo -e "  ${YELLOW}⚠️  ESLint found issues${NC}"
                    ((WARNINGS++))
                else
                    echo -e "  ${GREEN}✓${NC} ESLint passed"
                fi
            fi
        else
            echo "  ESLint not installed, skipping"
        fi
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        if command -v ruff &> /dev/null; then
            STAGED_PY=$(git diff --cached --name-only --diff-filter=ACM | grep "\.py$" || true)
            if [ -n "$STAGED_PY" ]; then
                if ! ruff check $STAGED_PY 2>/dev/null; then
                    echo -e "  ${YELLOW}⚠️  Ruff found issues${NC}"
                    ((WARNINGS++))
                else
                    echo -e "  ${GREEN}✓${NC} Ruff passed"
                fi
            fi
        else
            echo "  Ruff not installed, skipping"
        fi
    else
        echo "  No supported linter configuration found"
    fi
    echo ""
}

# ============================================
# 6. Check test files exist for new code
# ============================================
check_tests() {
    echo "🧪 Checking for corresponding tests..."

    STAGED_FILES=$(git diff --cached --name-only --diff-filter=A | \
        grep -vE "_test\.(go|py|js|ts)$" | \
        grep -vE "\.test\.(js|ts|jsx|tsx)$" | \
        grep -vE "^test" | \
        grep -vE "\.(md|json|yaml|yml|txt)$" || true)

    MISSING_TESTS=0

    for file in $STAGED_FILES; do
        if [ -f "$file" ]; then
            # Generate expected test file name
            base="${file%.*}"
            ext="${file##*.}"

            case "$ext" in
                go)
                    test_file="${base}_test.go"
                    ;;
                py)
                    test_file="test_$(basename $file)"
                    ;;
                js|ts)
                    test_file="${base}.test.${ext}"
                    ;;
                *)
                    continue
                    ;;
            esac

            if [ ! -f "$test_file" ]; then
                echo -e "  ${YELLOW}⚠️  No test file for $file${NC}"
                echo "      Expected: $test_file"
                ((WARNINGS++))
                MISSING_TESTS=1
            fi
        fi
    done

    if [ "$MISSING_TESTS" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Test coverage looks good"
    fi
    echo ""
}

# ============================================
# Run all checks
# ============================================
check_checklist
check_todos
check_secrets
check_large_files
check_lint
check_tests

# ============================================
# Summary
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}🔴 Errors: $ERRORS${NC}"
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
fi

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
fi

echo ""

# Exit with error if there are errors
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}❌ Commit blocked due to errors. Please fix and try again.${NC}"
    exit 1
fi

# Warn but allow commit if only warnings
if [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Commit allowed with warnings. Consider addressing them.${NC}"
fi

exit 0
