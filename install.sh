#!/bin/bash
set -e

# Claude Skills Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Canto87/claude-skills/main/install.sh | bash

REPO_URL="https://github.com/Canto87/claude-skills"
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
Claude Skills Installer

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

print_info "Installing Claude Skills..."
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

# Summary
echo ""
print_info "Installation complete!"
echo ""
echo "Installed skills:"
echo "  - plan-feature: Design phase-based documents"
echo "  - init-impl: Generate checklists and commands"
echo ""
echo "Each skill has its own config.yaml file."
echo ""
echo "Next steps:"
echo "  1. Edit each skill's config.yaml for your project:"
echo "     - $SKILLS_DIR/plan-feature/config.yaml"
echo "     - $SKILLS_DIR/init-impl/config.yaml"
echo "  2. Ask Claude: \"Design a new feature: [feature-name]\""
echo ""
