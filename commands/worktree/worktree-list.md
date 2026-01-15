---
description: List all git worktrees with status
allowed-tools: Bash, Read
---

# /worktree-list

Show all git worktrees with path, branch, and change status.

## Output Format

```
Git Worktrees:

  # | Path                              | Branch       | Status
----+-----------------------------------+--------------+---------
  1 | /Users/user/project/main          | main         | clean
  2 | /Users/user/project/feature-auth  | feature/auth | 2 changes
  3 | /Users/user/project/fix-bug       | fix/bug-123  | clean

Current: #1 (main)
```

## Status Values
- `clean` - No uncommitted changes
- `N changes` - N uncommitted files

## Arguments

$ARGUMENTS

## Execute

1. Get worktree list:
```bash
git worktree list
```

2. For each worktree, check status:
```bash
git -C /path/to/worktree status --short | wc -l
```

3. Display formatted table with current worktree highlighted.
