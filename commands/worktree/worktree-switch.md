---
description: Switch Claude Code session to another worktree
allowed-tools: Bash, Read, AskUserQuestion
---

# /worktree-switch [path]

Switch Claude Code's working directory to another worktree.

## Examples

```bash
# Interactive (select from list)
/worktree-switch

# Direct path
/worktree-switch ../feature-auth
```

## What Happens

1. Working directory changes to target worktree
2. CLAUDE.md is loaded if present in target
3. All subsequent commands run in new directory

## Arguments

$ARGUMENTS

## Execute

1. If no path provided, show worktree list:
   ```bash
   git worktree list
   ```
   Ask user to select target worktree.

2. Verify worktree exists:
   ```bash
   test -d /path/to/worktree/.git || test -f /path/to/worktree/.git
   ```

3. Change working directory:
   ```bash
   cd /path/to/target/worktree
   ```

4. Load context if available:
   ```bash
   if [ -f CLAUDE.md ]; then
       cat CLAUDE.md
   fi
   git branch --show-current
   git status --short
   ```

5. Show success message:
   ```
   Switched to worktree!

   Path: /Users/user/project/feature-auth
   Branch: feature/auth
   Status: clean

   Context loaded from CLAUDE.md (if exists)

   You are now working in this worktree.
   All subsequent commands will run in this directory.
   ```

## Important Notes

- The `cd` command changes Claude Code's working directory for this session
- All subsequent file operations use the new path
- To return to original worktree, use `/worktree-switch` again
