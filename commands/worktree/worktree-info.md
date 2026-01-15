---
description: Show current worktree information
allowed-tools: Bash, Read
---

# /worktree-info

Display current worktree details and navigation help.

## Output Format

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

## Arguments

$ARGUMENTS

## Execute

1. Get current info:
   ```bash
   pwd
   git branch --show-current
   git status --short
   ```

2. Get all worktrees:
   ```bash
   git worktree list
   ```

3. Display formatted output with:
   - Current path and branch
   - Status (clean or N changes)
   - List of other worktrees
   - Navigation tips
