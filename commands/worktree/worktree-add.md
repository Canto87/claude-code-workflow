---
description: Create new worktree for a branch
allowed-tools: Bash, Read, AskUserQuestion
---

# /worktree-add [branch] [options]

Create a new git worktree for parallel branch development.

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `-b, --branch` | Create new branch instead of checking out existing | - |
| `--base <branch>` | Base branch for new branch (with -b) | main |
| `--path <path>` | Custom directory path | auto-generated |

## Examples

```bash
# Checkout existing branch
/worktree-add feature/auth

# Create new branch from main
/worktree-add -b feature/new-feature

# Create new branch from dev
/worktree-add -b feature/new --base dev

# Custom path
/worktree-add feature/auth --path ../my-custom-path
```

## Auto-generated Path

Default: `../{branch-name-sanitized}`
- `feature/auth` → `../feature-auth`
- `fix/bug-123` → `../fix-bug-123`

## Arguments

$ARGUMENTS

## Execute

1. Parse options from arguments:
   - Check for `-b` or `--branch` flag
   - Extract `--base` value (default: main)
   - Extract `--path` value (default: auto-generate)

2. If no branch argument provided:
   ```bash
   git fetch --all --prune
   git branch -a | head -30
   ```
   Ask user to select or enter branch name.

3. Generate directory path if not specified:
   ```
   base_dir: ..
   path: {base_dir}/{branch.replace('/', '-')}
   ```

4. Ask user to confirm path.

5. Create worktree:
   - For existing branch:
     ```bash
     git worktree add /path/to/worktree branch-name
     ```
   - For new branch (with -b):
     ```bash
     git worktree add -b new-branch /path/to/worktree origin/{base}
     ```

6. Show success message with path and next steps.
