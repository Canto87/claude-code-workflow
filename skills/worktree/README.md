# Git Worktree Skill

Manage git worktrees for parallel branch development.

## What is Git Worktree?

Git worktree allows you to check out multiple branches simultaneously in separate directories. This is useful when you need to:

- Work on a feature while reviewing a PR
- Run long tests on one branch while coding on another
- Compare implementations across branches
- Avoid stashing and switching branches constantly

## Quick Start

```bash
# List all worktrees
/worktree list

# Create worktree for existing branch
/worktree add feature/auth

# Create new branch and worktree
/worktree add -b feature/new-feature

# Show current worktree info
/worktree info

# Switch to another worktree
/worktree switch ../feature-auth

# Remove a worktree
/worktree remove ../feature-auth
```

## Commands

| Command | Description |
|---------|-------------|
| `/worktree` | Interactive mode |
| `/worktree list` | List all worktrees with status |
| `/worktree add <branch>` | Create worktree for branch |
| `/worktree add -b <branch>` | Create new branch + worktree |
| `/worktree remove <path>` | Remove worktree |
| `/worktree info` | Current worktree details |
| `/worktree switch` | Switch to another worktree (interactive) |
| `/worktree switch <path>` | Switch to specific worktree |

## Options

| Option | Description | Example |
|--------|-------------|---------|
| `-b` | Create new branch | `/worktree add -b feature/new` |
| `-f` | Force remove | `/worktree remove -f ../old` |
| `--base` | Base branch for new | `/worktree add -b new --base main` |
| `--path` | Custom directory | `/worktree add dev --path ../dev-work` |

## Configuration

Edit `.claude/skills/worktree/config.project.yaml` to customize:

```yaml
worktree:
  base_dir: ".."              # Where to create worktrees
  naming_pattern: "{branch}"  # Directory naming

branch:
  default_base: "dev"         # Default base for new branches
  auto_fetch: true            # Fetch before listing

safety:
  confirm_remove: true        # Confirm before removing
  check_uncommitted: true     # Check for changes
  protect_main: true          # Protect main worktree
```

## Directory Structure

After creating worktrees:

```
parent-directory/
├── main/           # Main worktree (current)
├── feature-auth/   # Worktree for feature/auth
└── fix-bug-123/    # Worktree for fix/bug-123
```

## Safety Features

1. **Change detection**: Shows uncommitted changes before removal
2. **Stash option**: Can preserve changes when removing
3. **Confirmation**: Requires confirmation for destructive actions
4. **Protection**: Can protect main worktree from deletion

## Tips

- Each worktree is fully independent - changes don't affect other worktrees
- Worktrees share the same `.git` database (saves disk space)
- Use `/worktree switch` to change Claude Code's working directory to another worktree
- Use `cd` to switch between worktrees in terminal
- Branches checked out in worktrees cannot be checked out elsewhere

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "branch already checked out" | Remove the other worktree first |
| "path already exists" | Choose different path or remove directory |
| Branch not found | Run `git fetch --all` first |
| Permission denied | Check directory permissions |
