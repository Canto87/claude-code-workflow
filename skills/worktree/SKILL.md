---
name: worktree
description: Git worktree management for parallel branch development. Create, list, remove, and view worktree info with safety checks.
allowed-tools: Bash, Read, AskUserQuestion
---

# Git Worktree Management

Manage git worktrees to work on multiple branches simultaneously without stashing or losing context.

## When to Use

- Need to work on multiple branches simultaneously
- Want to review a PR branch without affecting current work
- Need to run long builds/tests while continuing development
- Want isolated environments for different features

## Prerequisites

- [ ] Inside a git repository
- [ ] Git version 2.5+ installed
- [ ] Write permission in parent directory (for new worktrees)

## Quick Start

### Run the Skill

```
/worktree list     # Show all worktrees
/worktree add dev  # Create worktree for dev branch
/worktree info     # Show current worktree info
```

---

## Workflow Overview

### Step 0: Load Configuration

**Purpose**: Load skill configuration to determine behavior

**Process**:
1. Read config file (`config.project.yaml`)
2. Load worktree settings (base_dir, naming_pattern)
3. Load safety settings

**Configuration determines**:
- Base directory for new worktrees
- Directory naming pattern
- Safety checks before removal

**Quick config check**:
```bash
cat .claude/skills/worktree/config.project.yaml
```

---

### Step 1: Determine Action

**Purpose**: Identify user's intended action

**Options** (via argument or AskUserQuestion):

| Action | Description |
|--------|-------------|
| `list` | Show all worktrees with status |
| `add` | Create new worktree for a branch |
| `remove` | Safely remove a worktree |
| `info` | Show current worktree details |
| `switch` | Switch Claude Code session to another worktree |

**If no action specified**: Show interactive menu

---

### Step 2A: List Worktrees (action: list)

**Purpose**: Display all worktrees with their status

**Commands**:
```bash
# Get worktree list
git worktree list

# Check each worktree for changes
git -C /path/to/worktree status --short
```

**Output format**:
```
Git Worktrees:

  # | Path                              | Branch       | Status
----+-----------------------------------+--------------+---------
  1 | /Users/user/project/main          | main         | clean
  2 | /Users/user/project/feature-auth  | feature/auth | 2 changes
  3 | /Users/user/project/fix-bug       | fix/bug-123  | clean

Current: #1 (main)
```

**Status values**:
- `clean` - No uncommitted changes
- `N changes` - N uncommitted files

---

### Step 2B: Add Worktree (action: add)

**Purpose**: Create new worktree for parallel development

**Step 2B-1: Determine branch**

If branch argument provided:
- Use provided branch name
- Check if branch exists (local or remote)

If no branch argument:
```bash
# Fetch latest
git fetch --all --prune

# Show available branches
git branch -a | head -30
```

Ask user to select or enter branch name.

**Step 2B-2: Determine directory path**

Default path pattern (from config):
```
{base_dir}/{branch_name_sanitized}
```

Example:
- Branch: `feature/auth`
- base_dir: `..`
- Result: `../feature-auth`

Sanitization rules:
- `/` → `-`
- Other special chars → `-`

Ask user to confirm or customize path.

**Step 2B-3: Create worktree**

For existing branch:
```bash
git worktree add /path/to/worktree branch-name
```

For new branch (with `-b` flag):
```bash
git worktree add -b new-branch /path/to/worktree origin/dev
```

**Success output**:
```
Worktree created successfully!

Path: /Users/user/project/feature-auth
Branch: feature/auth

To switch to this worktree:
  cd /Users/user/project/feature-auth

To open in new terminal:
  Open new terminal and navigate to above path
```

---

### Step 2C: Remove Worktree (action: remove)

**Purpose**: Safely remove a worktree with change detection

**Step 2C-1: Select worktree to remove**

Show worktree list (excluding current) with status.

Ask user to select which worktree to remove.

**Step 2C-2: Check for uncommitted changes**

```bash
git -C /path/to/target status --short
git -C /path/to/target stash list
```

**If changes exist** (and `safety.check_uncommitted: true`):

```
Warning: This worktree has uncommitted changes!

Modified files:
  M pkg/entity/user.go
  A pkg/usecase/new_feature.go

Options:
1. Stash changes and remove
2. Force remove (discard all changes)
3. Cancel
```

**Step 2C-3: Execute removal**

Normal removal:
```bash
git worktree remove /path/to/worktree
git worktree prune
```

Force removal (if requested):
```bash
git worktree remove --force /path/to/worktree
git worktree prune
```

**Success output**:
```
Worktree removed successfully!

Removed: /Users/user/project/feature-auth
Branch: feature/auth (still exists locally)

Note: The branch was NOT deleted. To delete:
  git branch -d feature/auth
```

---

### Step 2D: Info (action: info)

**Purpose**: Show current worktree details and navigation help

**Commands**:
```bash
pwd
git branch --show-current
git worktree list
git status --short
```

**Output format**:
```
Current Worktree:

Path: /Users/user/project/main
Branch: main
Status: clean (or: 3 uncommitted changes)

Other Worktrees:
  1. /Users/user/project/feature-auth (feature/auth)
  2. /Users/user/project/fix-bug (fix/bug-123)

To switch worktree:
  cd /Users/user/project/feature-auth

Tip: Each worktree is independent. Changes in one
     do not affect others until committed and merged.
```

---

### Step 2E: Switch Worktree (action: switch)

**Purpose**: Switch Claude Code session to work in a different worktree

**Step 2E-1: Select target worktree**

Show worktree list (excluding current):
```bash
git worktree list
```

Ask user to select which worktree to switch to (or accept path argument).

**Step 2E-2: Verify worktree exists**

```bash
# Check path exists and is a git worktree
test -d /path/to/worktree/.git || test -f /path/to/worktree/.git
```

**Step 2E-3: Change working directory**

```bash
cd /path/to/target/worktree
```

**Step 2E-4: Load context (if available)**

```bash
# Check for CLAUDE.md in target worktree
if [ -f CLAUDE.md ]; then
    cat CLAUDE.md
fi

# Show current branch and status
git branch --show-current
git status --short
```

**Success output**:
```
Switched to worktree!

Path: /Users/user/project/feature-auth
Branch: feature/auth
Status: clean

Context loaded from CLAUDE.md (if exists)

You are now working in this worktree.
All subsequent commands will run in this directory.
```

**Important notes**:
- The `cd` command changes Claude Code's working directory for this session
- All subsequent file operations and bash commands will use this new path
- To return to original worktree, use `/worktree switch` again

---

## Success Criteria

**For list**:
- [ ] All worktrees displayed
- [ ] Status shown for each
- [ ] Current worktree highlighted

**For add**:
- [ ] Worktree created at correct path
- [ ] Branch checked out correctly
- [ ] Path is accessible

**For remove**:
- [ ] User confirmed deletion
- [ ] Uncommitted changes handled
- [ ] Worktree removed from git
- [ ] Directory cleaned up

**For info**:
- [ ] Current path and branch displayed
- [ ] Other worktrees listed
- [ ] Navigation instructions provided

**For switch**:
- [ ] Target worktree exists and is valid
- [ ] Working directory changed successfully
- [ ] CLAUDE.md loaded if present
- [ ] Branch and status displayed

---

## Common Issues

| Issue | Solution |
|-------|----------|
| "branch is already checked out" | Branch is in use by another worktree. Remove that worktree first or use different branch. |
| "path already exists" | Directory exists. Choose different path or remove existing directory. |
| "not a git repository" | Run command from within a git repository. |
| Branch not found | Run `git fetch --all` to update remote branches. |
| Permission denied | Check directory permissions. |
| Worktree locked | Another process may be using it. Close any editors in that worktree. |

---

## Safety Features

1. **Change detection**: Shows uncommitted changes before removal
2. **Stash option**: Can preserve changes when removing
3. **Confirmation prompts**: Requires confirmation for destructive actions
4. **Main protection**: Can protect main worktree from deletion (configurable)

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `/worktree` | Interactive mode |
| `/worktree list` | Show all worktrees |
| `/worktree add <branch>` | Create worktree for branch |
| `/worktree add -b <new-branch>` | Create new branch and worktree |
| `/worktree remove <path>` | Remove worktree |
| `/worktree remove -f <path>` | Force remove |
| `/worktree info` | Show current worktree info |
| `/worktree switch` | Switch to another worktree (interactive) |
| `/worktree switch <path>` | Switch to specific worktree |

---

## Summary

**How to use**: `/worktree [action] [options]`

The skill helps you manage git worktrees for parallel branch development with safety checks for uncommitted changes.

**New**: Use `/worktree switch` to change Claude Code's working directory to another worktree and continue working there.
