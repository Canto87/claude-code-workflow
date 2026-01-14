#!/bin/bash
set -e

# Claude Code Workflow Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Canto87/claude-code-workflow/main/install.sh | bash

REPO_URL="https://github.com/Canto87/claude-code-workflow"
BRANCH="main"
SKILLS_DIR=".claude/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Claude Code Workflow Installer

Usage: ./install.sh [OPTIONS]

Options:
    --output=PATH     Skills output directory
                      Default: .claude/skills
    --help            Show this help message

Examples:
    ./install.sh                           # Install to .claude/skills
    ./install.sh --output=custom/skills    # Custom output directory

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output=*)
            SKILLS_DIR="${1#*=}"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "git is required but not installed."
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

print_info "Installing Claude Code Workflow..."
print_info "Output: $SKILLS_DIR"

# Clone repository
print_info "Downloading from $REPO_URL..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    print_error "Failed to clone repository. Check the URL and try again."
    exit 1
}

# Create output directory
mkdir -p "$SKILLS_DIR"

# Copy skills
print_info "Copying skills..."
cp -r "$TEMP_DIR/skills/"* "$SKILLS_DIR/"

# Copy hooks (if exists)
if [ -d "$TEMP_DIR/hooks" ]; then
    HOOKS_DIR="${SKILLS_DIR}/../hooks"
    print_info "Copying hooks to $HOOKS_DIR..."
    mkdir -p "$HOOKS_DIR"
    cp -r "$TEMP_DIR/hooks/"* "$HOOKS_DIR/"
    chmod +x "$HOOKS_DIR/"*.sh 2>/dev/null || true
fi

# Summary
echo ""
print_info "Installation complete!"
echo ""
echo "Installed skills:"
echo "  - plan-feature: Design phase-based documents"
echo "  - init-impl: Generate checklists and commands"
echo "  - slack-notify: Send Slack notifications on skill completion"
echo ""
echo "Installed hooks:"
echo "  - slack-notify.sh: PostToolUse hook for Slack notifications"
echo ""
echo "Each skill has its own config.yaml file."
echo ""
echo "Next steps:"
echo "  1. Edit each skill's config.yaml for your project:"
echo "     - $SKILLS_DIR/plan-feature/config.yaml"
echo "     - $SKILLS_DIR/init-impl/config.yaml"
echo "     - $SKILLS_DIR/slack-notify/config.yaml (set webhook_url)"
echo ""
echo "  2. For Slack notifications, add to your .claude/settings.local.json:"
echo '     {"hooks": {"PostToolUse": [{"matcher": "Skill", "hooks": [{"type": "command", "command": ".claude/hooks/slack-notify.sh"}]}]}}'
echo ""
echo "  3. Ask Claude: \"Design a new feature: [feature-name]\""
echo ""
