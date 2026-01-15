---
description: Manage git worktrees for parallel branch development
allowed-tools: Bash, Read, AskUserQuestion
---

# /worktree [action] [options]

Manage git worktrees to work on multiple branches simultaneously.

## Usage

- `/worktree` - Interactive mode (choose action)
- `/worktree list` - List all worktrees with status
- `/worktree add [branch]` - Create worktree for existing branch
- `/worktree add -b [new-branch]` - Create new branch and worktree
- `/worktree remove [path]` - Remove worktree safely
- `/worktree info` - Show current worktree info

## Actions

| Action | Description | Example |
|--------|-------------|---------|
| list | Show all worktrees | `/worktree list` |
| add | Create new worktree | `/worktree add feature/auth` |
| remove | Delete worktree | `/worktree remove ../feature-auth` |
| info | Current worktree info | `/worktree info` |

## Options

| Option | Description | Used with |
|--------|-------------|-----------|
| `-b, --branch` | Create new branch | add |
| `-f, --force` | Force remove (discard changes) | remove |
| `--base` | Base branch for new branch (default: main) | add -b |
| `--path` | Custom path for worktree | add |

## Examples

```bash
# List all worktrees
/worktree list

# Checkout existing branch in new worktree
/worktree add feature/scratch

# Create new branch and worktree from main
/worktree add -b feature/new-feature --base main

# Remove worktree (will prompt if changes exist)
/worktree remove ../feature-scratch

# Force remove (ignore uncommitted changes)
/worktree remove -f ../old-worktree
```

## Arguments

$ARGUMENTS

## Execute

Use the worktree skill.

Parse the action and options from arguments:

1. **No arguments**: Enter interactive mode - ask user to select action
2. **action = "list"**: Show all worktrees with status
3. **action = "add"**: Create worktree
   - If branch provided: use that branch
   - If `-b` flag: create new branch
   - Apply `--base` if provided (default: main)
   - Apply `--path` if provided (default: auto-generate from config)
4. **action = "remove"**: Remove worktree
   - If `-f` flag: force remove
   - Otherwise: check for changes and confirm
5. **action = "info"**: Show current worktree information
