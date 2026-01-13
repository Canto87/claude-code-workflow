# Customization Guide

How to customize skill templates for your project.

## Independent Skill Structure

```
.claude/skills/
├── plan-feature/
│   ├── SKILL.md          # Skill definition
│   ├── config.yaml       # Skill config (edit here)
│   ├── questions.md      # Q&A template
│   └── templates/
│       ├── overview.md
│       └── phase.md
│
└── init-impl/
    ├── SKILL.md          # Skill definition
    ├── config.yaml       # Skill config (edit here)
    └── templates/
        ├── checklist.md
        ├── status.md
        └── phase.md
```

## Customization Points

### 1. Edit Config File (Most Common)

Most customizations can be done by editing `config.yaml`:

**plan-feature/config.yaml:**
```yaml
integrations:
  - label: "Brain"
    description: "AI conversation system"
    path: "internal/brain"
  - label: "Memory"
    description: "Long-term memory"
    path: "internal/memory"
```

**init-impl/config.yaml:**
```yaml
build:
  command: "make build"
  test: "make test"
  run: "make run-{app}"
```

### 2. Modify Q&A Questions

Edit questions/options in `plan-feature/questions.md`:

```markdown
### Question 2: Core Goal

{
  "questions": [{
    "options": [
      {"label": "Real-time processing", ...},
      {"label": "My project-specific option", "description": "Description"},  # Add
      {"label": "Design documentation", ...}
    ]
  }]
}
```

**Note**: Maximum 4 options per question.

### 3. Modify Code Templates

Edit language-specific examples in `plan-feature/templates/phase.md`:

```markdown
## Implementation

### 1. {Component}

**Go Example:**
```go
// Customize for your project style
type {TypeName} struct {
    cfg *config.Config  // Project common pattern
    log *zap.Logger     // Logging library
}
```
```

### 4. Change Checklist Format

Edit `init-impl/templates/checklist.md`:

```markdown
### Checklist

**Basic format:**
- [ ] Item

**GitHub Issues integration:**
- [ ] #123 - Item description

**With time estimates:**
- [ ] [2h] Item description
```

### 5. Modify Phase Commands

Add workflows in `init-impl/templates/phase.md`:

```markdown
## On Completion

1. Update checklist
2. Run tests
3. **Request code review**  # Add
4. **Update documentation** # Add
```

## Managing Updates

To receive upstream updates after customizing:

```bash
# Manual merge
git fetch upstream
git merge upstream/main --no-commit
# Resolve conflicts and commit
```

## Tips

1. **Config first**: Check if `config.yaml` can solve it before editing templates
2. **Minimal changes**: Only modify what's necessary to ease future updates
3. **Document**: Record your changes in project documentation
