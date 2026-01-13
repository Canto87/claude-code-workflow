# User Authentication System

> JWT-based user authentication and session management system

## Overview

An authentication system that provides user login, signup, and token refresh functionality.
Implements stateless authentication using JWT (JSON Web Token),
and satisfies both security and user experience with refresh tokens.

## System Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│  Auth API   │────▶│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   Redis     │
                    │  (Session)  │
                    └─────────────┘
```

## Implementation Phases

| Rank | Phase | Feature | Difficulty | Impact | Status |
|------|-------|---------|------------|--------|--------|
| 1 | Phase 1 | Basic Auth (Login/Signup) | Medium | High | Not implemented |
| 2 | Phase 2 | JWT Token Management | Medium | High | Not implemented |
| 3 | Phase 3 | Session Management | Low | Medium | Not implemented |
| 4 | Phase 4 | Social Login | High | Medium | Not implemented |

## Existing System Utilization

### Reusable Components
- `internal/database/` - DB connection management
- `internal/config/` - Configuration loading

### New Components to Implement
- `internal/auth/` - Authentication logic
- `internal/auth/jwt.go` - JWT handling
- `internal/auth/session.go` - Session management

## Data Model

### SQL Schema

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    refresh_token TEXT UNIQUE NOT NULL,
    expires_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Go Types

```go
type User struct {
    ID           int64
    Email        string
    PasswordHash string
    CreatedAt    time.Time
    UpdatedAt    time.Time
}

type Session struct {
    ID           int64
    UserID       int64
    RefreshToken string
    ExpiresAt    time.Time
}
```

## Configuration

```yaml
auth:
  jwt_secret: "${JWT_SECRET}"
  access_token_ttl: 15m
  refresh_token_ttl: 7d
  bcrypt_cost: 12
```

## Implementation File List

```
internal/auth/
├── types.go        # User, Session types
├── store.go        # DB storage
├── jwt.go          # JWT generation/verification
├── session.go      # Session management
├── handler.go      # HTTP handlers
└── middleware.go   # Auth middleware
```
