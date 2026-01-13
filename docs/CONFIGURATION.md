# Configuration Guide

Detailed configuration options for each skill's `config.yaml` file.

## Independent Skill Configuration

Each skill has its own config file:

```
.claude/skills/
├── plan-feature/
│   └── config.yaml    # plan-feature specific
└── init-impl/
    └── config.yaml    # init-impl specific
```

## plan-feature Configuration

### Full Structure

```yaml
# plan-feature/config.yaml
project:
  name: "my-project"
  language: go

paths:
  source: "internal"
  apps: "apps"
  plans: "docs/plans"

integrations:
  - label: "Database"
    description: "Database layer"
    path: "internal/database"

storage:
  - label: "SQLite"
    description: "Lightweight DB"
    recommended: true
```

### Section Details

#### project

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Project name |
| `language` | enum | go, typescript, python, java, rust, other |

#### paths

| Field | Default | Description |
|-------|---------|-------------|
| `source` | `src` | Source code path |
| `apps` | `apps` | Application entry points |
| `plans` | `docs/plans` | Design docs output path |

**Recommended source paths by language:**

| Language | source | Reason |
|----------|--------|--------|
| Go | `internal` | Go module convention |
| TypeScript | `src` | Common TS structure |
| Python | `src` | src-layout pattern |

#### integrations

Displayed as options in the "System Integration" Q&A question.

```yaml
integrations:
  - label: "Database"           # Display name (required)
    description: "DB layer"     # Description (optional)
    path: "internal/database"   # Path (required)
```

**Maximum 3 items** are displayed (AskUserQuestion limit).

#### storage

Displayed as options in the "Storage" Q&A question.

```yaml
storage:
  - label: "SQLite"             # Display name (required)
    description: "Lightweight DB" # Description (optional)
    recommended: true           # Show as recommended (optional)
```

---

## init-impl Configuration

### Full Structure

```yaml
# init-impl/config.yaml
paths:
  plans: "docs/plans"
  checklists: "docs/checklists"
  commands: ".claude/commands"

build:
  command: "go build ./..."
  test: "go test ./..."
  run: "./bin/{app}"
```

### Section Details

#### paths

| Field | Default | Description |
|-------|---------|-------------|
| `plans` | `docs/plans` | Design docs input path |
| `checklists` | `docs/checklists` | Checklist output path |
| `commands` | `.claude/commands` | Slash commands output path |

#### build

| Field | Description | Example |
|-------|-------------|---------|
| `command` | Build command | `go build ./...` |
| `test` | Test command | `go test ./...` |
| `run` | Run command pattern | `./bin/{app}` |

The `{app}` placeholder is replaced with the feature name.

**Default values by language:**

| Language | build | test | run |
|----------|-------|------|-----|
| Go | `go build ./...` | `go test ./...` | `./bin/{app}` |
| TypeScript | `npm run build` | `npm test` | `npm run start:{app}` |
| Python | `python -m build` | `pytest` | `python -m {app}` |

---

## When No Config File Exists

Skills use the following defaults:

### plan-feature Defaults
```yaml
project:
  name: "project"
  language: other

paths:
  source: "src"
  apps: "apps"
  plans: "docs/plans"

integrations: []

storage:
  - label: "SQLite"
    recommended: true
  - label: "PostgreSQL"
  - label: "In-memory"
  - label: "File-based"
```

### init-impl Defaults
```yaml
paths:
  plans: "docs/plans"
  checklists: "docs/checklists"
  commands: ".claude/commands"
```
