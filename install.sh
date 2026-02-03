#!/bin/bash
set -e

# Claude Code Workflow Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Canto87/claude-code-workflow/main/install.sh | bash

REPO_URL="https://github.com/Canto87/claude-code-workflow"
BRANCH="main"
SKILLS_DIR=".claude/skills"
AGENTS_DIR=".claude/agents"

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
    "review:Code quality review skill"
    "generate-docs:Auto documentation generator"
    "slack-notify:Slack notification configuration"
    "worktree:Git worktree management"
    "supervisor:QA pipeline orchestrator (implement → review → validate)"
    "validate:Artifact and implementation validation"
)

# Available agents (advanced feature)
AVAILABLE_AGENTS=(
    "code-edit:Single-task code modification agent"
    "auto-impl:Phase automation orchestrator"
    "validate:Dual-mode verification agent"
    "code-analyze:Read-only codebase analysis"
    "code-review:Code quality evaluation agent"
)

# Installation options
SELECTED_SKILLS=""
SELECTED_AGENTS=""
INSTALL_AGENTS=false
WITH_SUPERVISOR=false
LIST_ONLY=false
INTERACTIVE=false

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
    --agents                Install all agents (advanced feature)
    --agents=AGENT1,AGENT2  Install specific agents only (comma-separated)
    --with-supervisor       Install agents + supervisor skill (recommended for QA pipeline)
    --list                  List available skills and agents
    --interactive           Interactive selection menu
    --yes, -y               Skip confirmation prompt (for automation)
    --help                  Show this help message

Available Skills:
    plan-feature    Q&A-based design document generation
    init-impl       Generate checklists and commands from design docs
    health-check    Diagnose project configuration
    status          Display implementation progress dashboard
    review          Code quality review skill
    generate-docs   Auto documentation generator
    slack-notify    Slack notification configuration
    worktree        Git worktree management
    supervisor      QA pipeline orchestrator (requires agents)
    validate        Artifact and implementation validation skill

Available Agents (Advanced):
    code-edit       Single-task code modification agent
    auto-impl       Phase automation orchestrator
    validate        Dual-mode verification agent
    code-analyze    Read-only codebase analysis
    code-review     Code quality evaluation agent

Examples:
    ./install.sh                                    # Install all skills (no agents)
    ./install.sh --skills=plan-feature,init-impl   # Install specific skills
    ./install.sh --agents                          # Install skills + all agents
    ./install.sh --agents=code-edit,code-review    # Install skills + specific agents
    ./install.sh --with-supervisor                 # Install skills + agents + supervisor
    ./install.sh --list                            # List available skills and agents
    ./install.sh --interactive                     # Interactive selection
    ./install.sh --output=custom/skills             # Custom output directory
    ./install.sh --yes                             # Skip confirmation (CI/CD)

Note:
  - _shared folder is always installed (contains shared templates)
  - Agents are optional and provide advanced automation capabilities
  - Use --with-supervisor for the full QA pipeline experience

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
    echo -e "${CYAN}Available Agents (Advanced):${NC}"
    echo ""
    printf "  %-15s %s\n" "AGENT" "DESCRIPTION"
    printf "  %-15s %s\n" "-----" "-----------"
    for agent_info in "${AVAILABLE_AGENTS[@]}"; do
        agent_name="${agent_info%%:*}"
        agent_desc="${agent_info#*:}"
        printf "  %-15s %s\n" "$agent_name" "$agent_desc"
    done
    echo ""
    echo -e "${YELLOW}Note:${NC} _shared folder is always installed (contains shared templates)"
    echo -e "${YELLOW}Note:${NC} Use --agents or --with-supervisor to install agents"
    echo ""
}

interactive_select() {
    echo ""
    echo -e "${CYAN}Claude Code Workflow - Interactive Installation${NC}"
    echo ""

    # Skills selection
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

    read -p "Enter skill selection (e.g., '1 3 5' or 'all'): " skill_selection

    if [[ "$skill_selection" == "q" || "$skill_selection" == "Q" ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    if [[ "$skill_selection" == "all" || "$skill_selection" == "a" || "$skill_selection" == "A" ]]; then
        SELECTED_SKILLS=""
    else
        local selected_names=()
        for num in $skill_selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#AVAILABLE_SKILLS[@]}" ]; then
                local idx=$((num - 1))
                local skill_info="${AVAILABLE_SKILLS[$idx]}"
                selected_names+=("${skill_info%%:*}")
            else
                print_warn "Invalid selection: $num (skipped)"
            fi
        done
        SELECTED_SKILLS=$(IFS=,; echo "${selected_names[*]}")
    fi

    # Agents selection
    echo ""
    echo "Select agents to install (optional, for advanced features):"
    echo ""

    i=1
    for agent_info in "${AVAILABLE_AGENTS[@]}"; do
        agent_name="${agent_info%%:*}"
        agent_desc="${agent_info#*:}"
        printf "  ${BLUE}%d)${NC} %-15s - %s\n" "$i" "$agent_name" "$agent_desc"
        ((i++))
    done
    echo ""
    printf "  ${BLUE}a)${NC} All agents\n"
    printf "  ${BLUE}n)${NC} No agents (skip)\n"
    echo ""

    read -p "Enter agent selection (e.g., '1 3' or 'all' or 'n'): " agent_selection

    if [[ "$agent_selection" == "n" || "$agent_selection" == "N" || -z "$agent_selection" ]]; then
        INSTALL_AGENTS=false
        SELECTED_AGENTS=""
    elif [[ "$agent_selection" == "all" || "$agent_selection" == "a" || "$agent_selection" == "A" ]]; then
        INSTALL_AGENTS=true
        SELECTED_AGENTS=""
    else
        INSTALL_AGENTS=true
        local selected_agents=()
        for num in $agent_selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#AVAILABLE_AGENTS[@]}" ]; then
                local idx=$((num - 1))
                local agent_info="${AVAILABLE_AGENTS[$idx]}"
                selected_agents+=("${agent_info%%:*}")
            else
                print_warn "Invalid selection: $num (skipped)"
            fi
        done
        SELECTED_AGENTS=$(IFS=,; echo "${selected_agents[*]}")
    fi

    echo ""
    if [[ -n "$SELECTED_SKILLS" ]]; then
        print_info "Selected skills: $SELECTED_SKILLS"
    else
        print_info "Selected skills: all"
    fi
    if [[ "$INSTALL_AGENTS" == true ]]; then
        if [[ -n "$SELECTED_AGENTS" ]]; then
            print_info "Selected agents: $SELECTED_AGENTS"
        else
            print_info "Selected agents: all"
        fi
    else
        print_info "Selected agents: none"
    fi
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

validate_agents() {
    local agents_input="$1"
    local valid_agents=()

    IFS=',' read -ra agent_array <<< "$agents_input"

    for agent in "${agent_array[@]}"; do
        agent=$(echo "$agent" | xargs)  # trim whitespace
        local found=false
        for agent_info in "${AVAILABLE_AGENTS[@]}"; do
            if [[ "${agent_info%%:*}" == "$agent" ]]; then
                found=true
                valid_agents+=("$agent")
                break
            fi
        done
        if [[ "$found" == false ]]; then
            print_error "Unknown agent: $agent"
            echo "Use --list to see available agents."
            exit 1
        fi
    done

    echo "${valid_agents[*]}"
}

confirm_install() {
    echo ""
    echo -e "${CYAN}Claude Code Workflow Installer${NC}"
    echo ""
    echo "This will install:"
    echo ""
    echo -e "${BLUE}Skills:${NC}"
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

    if [[ "$INSTALL_AGENTS" == true ]]; then
        echo ""
        echo -e "${BLUE}Agents:${NC}"
        if [[ -n "$SELECTED_AGENTS" ]]; then
            IFS=',' read -ra agent_array <<< "$SELECTED_AGENTS"
            for agent in "${agent_array[@]}"; do
                echo "  - $agent"
            done
        else
            for agent_info in "${AVAILABLE_AGENTS[@]}"; do
                echo "  - ${agent_info%%:*}"
            done
        fi
    fi

    echo ""
    echo "Target directories:"
    echo "  - Skills: $SKILLS_DIR/"
    if [[ "$INSTALL_AGENTS" == true ]]; then
        echo "  - Agents: $AGENTS_DIR/"
    fi
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
        --agents)
            INSTALL_AGENTS=true
            shift
            ;;
        --agents=*)
            INSTALL_AGENTS=true
            SELECTED_AGENTS="${1#*=}"
            shift
            ;;
        --with-supervisor)
            INSTALL_AGENTS=true
            WITH_SUPERVISOR=true
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

# Validate selected agents if specified
if [[ -n "$SELECTED_AGENTS" ]]; then
    validate_agents "$SELECTED_AGENTS" > /dev/null
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "git is required but not installed."
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

print_info "Installing Claude Code Workflow..."
print_info "Skills output: $SKILLS_DIR"
if [[ "$INSTALL_AGENTS" == true ]]; then
    print_info "Agents output: $AGENTS_DIR"
fi

# Clone repository
print_info "Downloading from $REPO_URL..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    print_error "Failed to clone repository. Check the URL and try again."
    exit 1
}

# Create output directories
mkdir -p "$SKILLS_DIR"
if [[ "$INSTALL_AGENTS" == true ]]; then
    mkdir -p "$AGENTS_DIR"
fi

# Copy skills
print_info "Copying skills..."

# Always copy _shared first (required dependency)
if [ -d "$TEMP_DIR/skills/_shared" ]; then
    cp -r "$TEMP_DIR/skills/_shared" "$SKILLS_DIR/"
    print_info "  - _shared (required)"
fi

# Copy selected skills or all skills
INSTALLED_SKILLS=()
if [[ -n "$SELECTED_SKILLS" ]]; then
    # Selective installation
    IFS=',' read -ra skill_array <<< "$SELECTED_SKILLS"
    for skill in "${skill_array[@]}"; do
        skill=$(echo "$skill" | xargs)  # trim whitespace
        if [ -d "$TEMP_DIR/skills/$skill" ]; then
            cp -r "$TEMP_DIR/skills/$skill" "$SKILLS_DIR/"
            print_info "  - $skill"
            INSTALLED_SKILLS+=("$skill")
        fi
    done
else
    # Full installation - copy all skills except _shared (already copied)
    for skill_info in "${AVAILABLE_SKILLS[@]}"; do
        skill_name="${skill_info%%:*}"
        if [ -d "$TEMP_DIR/skills/$skill_name" ]; then
            cp -r "$TEMP_DIR/skills/$skill_name" "$SKILLS_DIR/"
            print_info "  - $skill_name"
            INSTALLED_SKILLS+=("$skill_name")
        fi
    done
fi

# Copy agents if requested
INSTALLED_AGENTS=()
if [[ "$INSTALL_AGENTS" == true ]]; then
    print_info "Copying agents..."

    if [[ -n "$SELECTED_AGENTS" ]]; then
        # Selective agent installation
        IFS=',' read -ra agent_array <<< "$SELECTED_AGENTS"
        for agent in "${agent_array[@]}"; do
            agent=$(echo "$agent" | xargs)  # trim whitespace
            if [ -f "$TEMP_DIR/agents/$agent.md" ]; then
                cp "$TEMP_DIR/agents/$agent.md" "$AGENTS_DIR/"
                print_info "  - $agent"
                INSTALLED_AGENTS+=("$agent")
            fi
        done
    else
        # Full agent installation
        for agent_info in "${AVAILABLE_AGENTS[@]}"; do
            agent_name="${agent_info%%:*}"
            if [ -f "$TEMP_DIR/agents/$agent_name.md" ]; then
                cp "$TEMP_DIR/agents/$agent_name.md" "$AGENTS_DIR/"
                print_info "  - $agent_name"
                INSTALLED_AGENTS+=("$agent_name")
            fi
        done
    fi
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

if [[ ${#INSTALLED_AGENTS[@]} -gt 0 ]]; then
    echo "Installed agents:"
    for agent in "${INSTALLED_AGENTS[@]}"; do
        # Get description for each agent
        for agent_info in "${AVAILABLE_AGENTS[@]}"; do
            if [[ "${agent_info%%:*}" == "$agent" ]]; then
                echo "  - $agent: ${agent_info#*:}"
                break
            fi
        done
    done
    echo ""
fi

# Show hooks info only if hooks were installed
if [ -d "${SKILLS_DIR}/../hooks" ]; then
    echo "Installed hooks:"
    echo "  - pre-commit-quality.sh: Pre-commit quality checks"
    echo ""
fi

echo "Configuration files:"
echo "  - Skills: Edit each skill's config.yaml"
for skill in "${INSTALLED_SKILLS[@]}"; do
    if [ -f "$SKILLS_DIR/$skill/config.yaml" ]; then
        echo "     - $SKILLS_DIR/$skill/config.yaml"
    fi
done
echo ""

# Check if slack-notify was installed
for skill in "${INSTALLED_SKILLS[@]}"; do
    if [[ "$skill" == "slack-notify" ]]; then
        echo "Slack notifications:"
        echo "  Set webhook_url in: $SKILLS_DIR/slack-notify/config.yaml"
        echo ""
        break
    fi
done

# Agent-specific instructions
if [[ ${#INSTALLED_AGENTS[@]} -gt 0 ]]; then
    echo -e "${CYAN}Agent System:${NC}"
    echo "  Agents are defined in: $AGENTS_DIR/"
    echo "  See docs/AGENTS.md for usage guide"
    echo "  See docs/DELEGATION.md for task delegation rules"
    echo ""

    # Check if supervisor was installed
    for skill in "${INSTALLED_SKILLS[@]}"; do
        if [[ "$skill" == "supervisor" ]]; then
            echo -e "${CYAN}QA Pipeline:${NC}"
            echo "  Use /supervisor to run the full QA pipeline:"
            echo "    /supervisor {feature} phase{N}"
            echo "  Pipeline: implement → review → validate"
            echo ""
            break
        fi
    done
fi

echo "Next steps:"
echo "  1. Ask Claude: \"Design a new feature: [feature-name]\""
echo "  2. Or run: \"Configure claude-code-workflow for this project\""
if [[ ${#INSTALLED_AGENTS[@]} -gt 0 ]]; then
    echo "  3. For QA pipeline: /supervisor {feature} {phase}"
fi
echo ""
