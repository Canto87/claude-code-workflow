---
description: Remove a worktree safely
allowed-tools: Bash, Read, AskUserQuestion
---

# /worktree-remove [path] [options]

Safely remove a git worktree with uncommitted change detection.

## Options

| Option | Description |
|--------|-------------|
| `-f, --force` | Force remove, discard all uncommitted changes |

## Examples

```bash
# Safe remove (prompts if changes exist)
/worktree-remove ../feature-auth

# Force remove (discard changes)
/worktree-remove -f ../old-worktree

# Interactive (select from list)
/worktree-remove
```

## Safety Features

1. **Change detection**: Shows uncommitted changes before removal
2. **Stash option**: Can preserve changes when removing
3. **Confirmation prompt**: Requires confirmation for destructive actions

## Arguments

$ARGUMENTS

## Execute

1. Parse options:
   - Check for `-f` or `--force` flag
   - Extract path argument

2. If no path provided, show worktree list (excluding current):
   ```bash
   git worktree list
   ```
   Ask user to select which worktree to remove.

3. Check for uncommitted changes:
   ```bash
   git -C /path/to/target status --short
   git -C /path/to/target stash list
   ```

4. If changes exist (and not force):
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

5. Execute removal:
   - Normal:
     ```bash
     git worktree remove /path/to/worktree
     git worktree prune
     ```
   - Force:
     ```bash
     git worktree remove --force /path/to/worktree
     git worktree prune
     ```

6. Show success message:
   ```
   Worktree removed successfully!

   Removed: /path/to/worktree
   Branch: feature/auth (still exists locally)

   Note: The branch was NOT deleted. To delete:
     git branch -d feature/auth
   ```
