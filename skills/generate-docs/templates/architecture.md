# Architecture Documentation Template

Use this template when generating architecture diagrams.

## Structure

```markdown
# {FEATURE_NAME} Architecture

> {BRIEF_DESCRIPTION}

## Overview

{OVERVIEW_TEXT}

## Component Diagram

```mermaid
graph {DIRECTION}
    subgraph {SUBGRAPH_NAME}
        {COMPONENT_DEFINITIONS}
    end

    {CONNECTIONS}
```

## Sequence Diagrams

### {FLOW_NAME}

```mermaid
sequenceDiagram
    {PARTICIPANTS}

    {SEQUENCE_STEPS}
```

## Data Flow

```mermaid
flowchart LR
    {DATA_FLOW_NODES}
```

## Components

| Component | Responsibility | Dependencies |
|-----------|---------------|--------------|
{FOR_EACH_COMPONENT}
| {NAME} | {RESPONSIBILITY} | {DEPENDENCIES} |
{END_FOR}

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
{FOR_EACH_TECH}
| {LAYER} | {TECH} | {PURPOSE} |
{END_FOR}
```

## Example Output

```markdown
# User Auth Architecture

> JWT-based authentication system with session management

## Overview

The authentication system provides secure user authentication using JWT tokens.
It consists of a stateless API layer backed by PostgreSQL for user data and Redis
for session/token management.

## Component Diagram

```mermaid
graph TB
    subgraph Client
        WEB[Web Application]
        MOB[Mobile App]
    end

    subgraph API["API Layer"]
        GW[API Gateway]
        AUTH[Auth Service]
        MW[Auth Middleware]
    end

    subgraph Storage
        PG[(PostgreSQL)]
        RD[(Redis)]
    end

    WEB --> GW
    MOB --> GW
    GW --> MW
    MW --> AUTH
    AUTH --> PG
    AUTH --> RD
```

## Sequence Diagrams

### User Login Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant G as API Gateway
    participant A as Auth Service
    participant P as PostgreSQL
    participant R as Redis

    C->>G: POST /auth/login
    G->>A: Forward request
    A->>P: Find user by email
    P-->>A: User record
    A->>A: Verify password (bcrypt)
    A->>A: Generate JWT tokens
    A->>R: Store refresh token
    R-->>A: OK
    A-->>G: Tokens + user info
    G-->>C: 200 OK (tokens)
```

### Token Refresh Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant G as API Gateway
    participant A as Auth Service
    participant R as Redis

    C->>G: POST /auth/refresh
    G->>A: Forward request
    A->>R: Validate refresh token
    R-->>A: Token valid
    A->>A: Generate new access token
    A->>R: Update refresh token
    R-->>A: OK
    A-->>G: New tokens
    G-->>C: 200 OK (tokens)
```

### Protected Resource Access

```mermaid
sequenceDiagram
    participant C as Client
    participant G as API Gateway
    participant M as Auth Middleware
    participant S as Service

    C->>G: GET /api/resource
    Note over C,G: Authorization: Bearer <token>
    G->>M: Validate token
    M->>M: Verify JWT signature
    M->>M: Check expiration
    alt Token Valid
        M->>S: Forward request
        S-->>G: Response
        G-->>C: 200 OK
    else Token Invalid
        M-->>G: 401 Unauthorized
        G-->>C: 401 Unauthorized
    end
```

## Data Flow

```mermaid
flowchart LR
    A[User Input] --> B[API Gateway]
    B --> C{Auth Required?}
    C -->|Yes| D[Middleware]
    C -->|No| E[Service]
    D --> F{Token Valid?}
    F -->|Yes| E
    F -->|No| G[401 Error]
    E --> H[Database]
    H --> I[Response]
```

## Components

| Component | Responsibility | Dependencies |
|-----------|---------------|--------------|
| API Gateway | Request routing, rate limiting | - |
| Auth Middleware | Token validation | Redis |
| Auth Service | User management, token generation | PostgreSQL, Redis |
| User Store | User CRUD operations | PostgreSQL |
| Token Manager | JWT generation, validation | Redis |

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| API | Go + Chi Router | HTTP handling |
| Authentication | JWT (RS256) | Stateless auth |
| Password | bcrypt | Secure hashing |
| Database | PostgreSQL | User data |
| Cache | Redis | Sessions, tokens |
| Validation | go-playground/validator | Input validation |
```
