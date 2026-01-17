# Q&A Template

Question format for interactive requirements gathering.

**Rules:**
- All questions include "Generate design docs" option
- AskUserQuestion: Max 4 options
- To modify previous answer: Select "Other" then input

---

## Step 1: Check Configuration

Read `config.yaml` from the skill folder:

```yaml
# Defaults (when no config file exists)
project:
  name: "my-project"
  language: other

paths:
  source: "src"
  apps: "apps"
  plans: "docs/plans"

integrations: []  # Define per project

storage:
  - label: "SQLite"
    description: "Lightweight embedded DB"
    recommended: true
  - label: "PostgreSQL"
    description: "Production DB"
  - label: "Memory only"
    description: "Resets on restart"
  - label: "File-based"
    description: "JSON/YAML files"
```

---

## Step 2: Basic Information (Required)

### Question 1: Feature Name Confirmation

```json
{
  "questions": [{
    "header": "Feature Name",
    "question": "Converting '{user mentioned feature}' to snake_case gives '{converted_name}'. Is this correct?",
    "options": [
      {"label": "Yes, correct", "description": "Proceed with this name"},
      {"label": "Use different name", "description": "Enter manually"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ],
    "multiSelect": false
  }]
}
```

### Question 2: Core Goal

```json
{
  "questions": [{
    "header": "Core Goal",
    "question": "What is the most important goal for this feature?",
    "options": [
      {"label": "Real-time processing", "description": "Needs immediate response"},
      {"label": "Batch processing", "description": "Process periodically in bulk"},
      {"label": "Data collection", "description": "Gather and store information"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ],
    "multiSelect": false
  }]
}
```

---

## Step 3: Codebase Analysis

No questions - automatic analysis:

```bash
# Paths determined by config
ls -la {config.paths.source}/
ls -la {config.paths.apps}/
cat CLAUDE.md  # Read if exists
```

**Config-based component exploration:**
- Reference `integrations` items from `config.yaml`
- If no config, analyze directory structure and recommend

---

## Interim Summary 1

```
📋 Information collected so far:
- Feature name: {feature_name}
- Core goal: {goal}
- Related modules: {modules}

Continue with more questions?
```

---

## Step 4: Architecture Questions

### Question 3: System Integration (multiSelect)

**When integrations exist in config:**
```json
{
  "questions": [{
    "header": "Integration",
    "question": "Which existing systems need integration?",
    "multiSelect": true,
    "options": [
      // Dynamically generated from config.integrations (max 3)
      {"label": "{integration.label}", "description": "{integration.description} ({integration.path})"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**When no integrations in config (default):**
```json
{
  "questions": [{
    "header": "Integration",
    "question": "Which existing systems need integration?",
    "multiSelect": true,
    "options": [
      {"label": "Database", "description": "Needs DB integration"},
      {"label": "External API", "description": "Call external services"},
      {"label": "None", "description": "New independent module"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 4: Data Storage

```json
{
  "questions": [{
    "header": "Data Storage",
    "question": "How should data be stored? (Select 'Other' to modify previous answer)",
    "multiSelect": false,
    "options": [
      // Dynamically generated from config.storage or use defaults
      {"label": "SQLite (Recommended)", "description": "Lightweight embedded DB"},
      {"label": "Memory only", "description": "Resets on restart"},
      {"label": "File-based", "description": "Save as JSON/YAML files"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 5: API Endpoints

```json
{
  "questions": [{
    "header": "API",
    "question": "Do you need externally accessible API? (Select 'Other' to modify previous answer)",
    "multiSelect": false,
    "options": [
      {"label": "Yes, REST API", "description": "Add HTTP endpoints"},
      {"label": "No", "description": "Internal use only"},
      {"label": "Redo previous question", "description": "Modify previous answer"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

---

## Interim Summary 2

```
📋 Information collected so far:
- Feature name: {feature_name}
- Core goal: {goal}
- Integration: {systems}
- Storage: {storage}
- API: {api}

Continue with functional design questions?
```

---

## Step 5: Functional Design (Required)

### Question 8: Core Use Cases

```json
{
  "questions": [{
    "header": "Use Cases",
    "question": "What are the core use cases for this feature?",
    "multiSelect": true,
    "options": [
      {"label": "CRUD operations", "description": "Create, Read, Update, Delete"},
      {"label": "Data processing", "description": "Transform, aggregate, analyze"},
      {"label": "User interaction", "description": "Forms, validation, feedback"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**Follow-up if "Other" selected:**
- Ask user to describe specific use cases
- Format: "As a {user}, I want to {action} so that {benefit}"

### Question 9: Interface Specification

```json
{
  "questions": [{
    "header": "Interface",
    "question": "How detailed should the interface specification be?",
    "multiSelect": false,
    "options": [
      {"label": "Detailed spec", "description": "Define each endpoint with request/response"},
      {"label": "Standard patterns", "description": "Use RESTful conventions"},
      {"label": "Minimal", "description": "Define during implementation"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**If "Detailed spec" selected, follow-up:**
```json
{
  "questions": [{
    "header": "Endpoints",
    "question": "Which operations need explicit interface definition?",
    "multiSelect": true,
    "options": [
      {"label": "List/Query", "description": "GET with filters, pagination"},
      {"label": "Create", "description": "POST with validation rules"},
      {"label": "Update/Delete", "description": "PUT/PATCH/DELETE operations"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 10: Error Handling Strategy

```json
{
  "questions": [{
    "header": "Errors",
    "question": "How should errors be handled?",
    "multiSelect": false,
    "options": [
      {"label": "Comprehensive", "description": "Define error codes, messages, recovery"},
      {"label": "Standard pattern", "description": "Follow project's existing error handling"},
      {"label": "Basic", "description": "Standard HTTP status codes only"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

**If "Comprehensive" selected, include in design:**
- Error code taxonomy (e.g., E001, E002)
- User-facing error messages
- Recovery/retry strategies
- Logging requirements

### Question 11: Security & Validation (Optional)

```json
{
  "questions": [{
    "header": "Security",
    "question": "What security and validation requirements apply?",
    "multiSelect": true,
    "options": [
      {"label": "Authentication", "description": "Login required for access"},
      {"label": "Authorization", "description": "Role-based permissions"},
      {"label": "Input validation", "description": "Strict input sanitization"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

---

## Interim Summary 3

```
📋 Functional Design Summary:
- Use cases: {use_cases}
- Interface: {interface_level}
- Error handling: {error_strategy}
- Security: {security_requirements}

Continue with optional questions or generate design docs?
```

---

## Step 6: Details (Optional)

### Question 12: Priority

```json
{
  "questions": [{
    "header": "Priority",
    "question": "Should we separate MVP (minimum features) from extensions?",
    "multiSelect": false,
    "options": [
      {"label": "Yes, in phases", "description": "Implement in phases"},
      {"label": "No, all at once", "description": "All features together"},
      {"label": "Redo previous question", "description": "Modify previous answer"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

### Question 13: Scheduling

```json
{
  "questions": [{
    "header": "Scheduling",
    "question": "Are there tasks that need to run periodically? (Select 'Other' to modify previous answer)",
    "multiSelect": false,
    "options": [
      {"label": "Yes, cron schedule", "description": "Run at fixed times"},
      {"label": "Yes, event-based", "description": "Run on specific conditions"},
      {"label": "No", "description": "Manual execution only"},
      {"label": "Generate design docs", "description": "Start design with current info"}
    ]
  }]
}
```

---

## Special Behaviors

### When "Other" selected then "redo previous question" entered
- Show previous question again
- Ignore previous answer and collect new one

### When "Generate design docs" selected
- Generate documents immediately with current information
- Use reasonable defaults for missing information
