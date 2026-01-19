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
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Available skills (excluding _shared which is always required)
AVAILABLE_SKILLS=(
    "plan-feature:Q&A-based design document generation"
    "init-impl:Generate checklists and commands from design docs"
    "health-check:Diagnose project configuration"
    "status:Display implementation progress dashboard"
    "review:Code quality review agent"
    "generate-docs:Auto documentation generator"
    "slack-notify:Slack notification configuration"
    "worktree:Git worktree management"
)

# Installation options
SELECTED_SKILLS=""
LIST_ONLY=false
INTERACTIVE=false
AUTO_YES=false

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
    --output=PATH           Skills output directory (default: .claude/skills)
    --skills=SKILL1,SKILL2  Install specific skills only (comma-separated)
    --list                  List available skills and exit
    --interactive           Interactive skill selection menu
    --yes, -y               Skip confirmation prompt (for automation)
    --help                  Show this help message

Available Skills:
    plan-feature    Q&A-based design document generation
    init-impl       Generate checklists and commands from design docs
    health-check    Diagnose project configuration
    status          Display implementation progress dashboard
    review          Code quality review agent
    generate-docs   Auto documentation generator
    slack-notify    Slack notification configuration
    worktree        Git worktree management

Examples:
    ./install.sh                                    # Install all skills
    ./install.sh --skills=plan-feature,init-impl   # Install specific skills
    ./install.sh --list                             # List available skills
    ./install.sh --interactive                      # Interactive selection
    ./install.sh --output=custom/skills             # Custom output directory
    ./install.sh --yes                              # Skip confirmation (CI/CD)

Note: _shared folder is always installed as it contains shared templates.

EOF
}

list_skills() {
    echo ""
    echo -e "${CYAN}Available Skills:${NC}"
    echo ""
    printf "  %-15s %s\n" "SKILL" "DESCRIPTION"
    printf "  %-15s %s\n" "-----" "-----------"
    for skill_info in "${AVAILABLE_SKILLS[@]}"; do
        skill_name="${skill_info%%:*}"
        skill_desc="${skill_info#*:}"
        printf "  %-15s %s\n" "$skill_name" "$skill_desc"
    done
    echo ""
    echo -e "${YELLOW}Note:${NC} _shared folder is always installed (contains shared templates)"
    echo ""
}

interactive_select() {
    echo ""
    echo -e "${CYAN}Claude Code Workflow - Interactive Installation${NC}"
    echo ""
    echo "Select skills to install (space-separated numbers, or 'all' for all skills):"
    echo ""

    local i=1
    for skill_info in "${AVAILABLE_SKILLS[@]}"; do
        skill_name="${skill_info%%:*}"
        skill_desc="${skill_info#*:}"
        printf "  ${BLUE}%d)${NC} %-15s - %s\n" "$i" "$skill_name" "$skill_desc"
        ((i++))
    done
    echo ""
    printf "  ${BLUE}a)${NC} All skills\n"
    printf "  ${BLUE}q)${NC} Cancel\n"
    echo ""

    read -p "Enter selection (e.g., '1 3 5' or 'all'): " selection

    if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    if [[ "$selection" == "all" || "$selection" == "a" || "$selection" == "A" ]]; then
        SELECTED_SKILLS=""
        return
    fi

    local selected_names=()
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#AVAILABLE_SKILLS[@]}" ]; then
            local idx=$((num - 1))
            local skill_info="${AVAILABLE_SKILLS[$idx]}"
            selected_names+=("${skill_info%%:*}")
        else
            print_warn "Invalid selection: $num (skipped)"
        fi
    done

    if [ ${#selected_names[@]} -eq 0 ]; then
        print_error "No valid skills selected."
        exit 1
    fi

    SELECTED_SKILLS=$(IFS=,; echo "${selected_names[*]}")
    echo ""
    print_info "Selected skills: $SELECTED_SKILLS"
}

validate_skills() {
    local skills_input="$1"
    local valid_skills=()

    IFS=',' read -ra skill_array <<< "$skills_input"

    for skill in "${skill_array[@]}"; do
        skill=$(echo "$skill" | xargs)  # trim whitespace
        local found=false
        for skill_info in "${AVAILABLE_SKILLS[@]}"; do
            if [[ "${skill_info%%:*}" == "$skill" ]]; then
                found=true
                valid_skills+=("$skill")
                break
            fi
        done
        if [[ "$found" == false ]]; then
            print_error "Unknown skill: $skill"
            echo "Use --list to see available skills."
            exit 1
        fi
    done

    echo "${valid_skills[*]}"
}

confirm_install() {
    echo ""
    echo -e "${CYAN}Claude Code Workflow Installer${NC}"
    echo ""
    echo "This will install:"
    echo "  - _shared (required)"

    if [[ -n "$SELECTED_SKILLS" ]]; then
        IFS=',' read -ra skill_array <<< "$SELECTED_SKILLS"
        for skill in "${skill_array[@]}"; do
            echo "  - $skill"
        done
    else
        for skill_info in "${AVAILABLE_SKILLS[@]}"; do
            echo "  - ${skill_info%%:*}"
        done
    fi

    echo ""
    echo "Target: $SKILLS_DIR/"
    echo ""

    if [[ "$AUTO_YES" == true ]]; then
        return 0
    fi

    read -p "Continue? (y/n): " answer
    case "$answer" in
        [Yy]* ) return 0 ;;
        * ) echo "Installation cancelled."; exit 0 ;;
    esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output=*)
            SKILLS_DIR="${1#*=}"
            shift
            ;;
        --skills=*)
            SELECTED_SKILLS="${1#*=}"
            shift
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
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

# Handle --list option
if [[ "$LIST_ONLY" == true ]]; then
    list_skills
    exit 0
fi

# Handle --interactive option
if [[ "$INTERACTIVE" == true ]]; then
    interactive_select
fi

# Validate selected skills if specified
if [[ -n "$SELECTED_SKILLS" ]]; then
    validate_skills "$SELECTED_SKILLS" > /dev/null
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "git is required but not installed."
    exit 1
fi

# Confirm installation (skip for --interactive which already has user interaction)
if [[ "$INTERACTIVE" == false ]]; then
    confirm_install
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

# Always copy _shared first (required dependency)
if [ -d "$TEMP_DIR/skills/_shared" ]; then
    cp -r "$TEMP_DIR/skills/_shared" "$SKILLS_DIR/"
    print_info "  - _shared (required)"
fi

# Copy selected skills or all skills
if [[ -n "$SELECTED_SKILLS" ]]; then
    # Selective installation
    IFS=',' read -ra skill_array <<< "$SELECTED_SKILLS"
    for skill in "${skill_array[@]}"; do
        skill=$(echo "$skill" | xargs)  # trim whitespace
        if [ -d "$TEMP_DIR/skills/$skill" ]; then
            cp -r "$TEMP_DIR/skills/$skill" "$SKILLS_DIR/"
            print_info "  - $skill"
        fi
    done
    INSTALLED_SKILLS=("${skill_array[@]}")
else
    # Full installation - copy all skills except _shared (already copied)
    INSTALLED_SKILLS=()
    for skill_info in "${AVAILABLE_SKILLS[@]}"; do
        skill_name="${skill_info%%:*}"
        if [ -d "$TEMP_DIR/skills/$skill_name" ]; then
            cp -r "$TEMP_DIR/skills/$skill_name" "$SKILLS_DIR/"
            print_info "  - $skill_name"
            INSTALLED_SKILLS+=("$skill_name")
        fi
    done
fi

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
for skill in "${INSTALLED_SKILLS[@]}"; do
    # Get description for each skill
    for skill_info in "${AVAILABLE_SKILLS[@]}"; do
        if [[ "${skill_info%%:*}" == "$skill" ]]; then
            echo "  - $skill: ${skill_info#*:}"
            break
        fi
    done
done
echo ""

# Show hooks info only if hooks were installed
if [ -d "${SKILLS_DIR}/../hooks" ]; then
    echo "Installed hooks:"
    echo "  - pre-commit-quality.sh: Pre-commit quality checks"
    echo ""
fi

echo "Each skill has its own config.yaml file."
echo ""
echo "Next steps:"
echo "  1. Edit each skill's config.yaml for your project:"
for skill in "${INSTALLED_SKILLS[@]}"; do
    echo "     - $SKILLS_DIR/$skill/config.yaml"
done
echo ""

# Check if slack-notify was installed
for skill in "${INSTALLED_SKILLS[@]}"; do
    if [[ "$skill" == "slack-notify" ]]; then
        echo "  2. For Slack notifications, set webhook_url in:"
        echo "     $SKILLS_DIR/slack-notify/config.yaml"
        echo ""
        break
    fi
done

echo "  3. Ask Claude: \"Design a new feature: [feature-name]\""
echo "     Or run: \"Configure claude-code-workflow for this project\""
echo ""
