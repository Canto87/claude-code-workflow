# Changelog Template

Use this template when generating or updating CHANGELOG.md.

## Format

Based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- {NEW_FEATURES}

### Changed
- {CHANGES_TO_EXISTING}

### Deprecated
- {SOON_TO_BE_REMOVED}

### Removed
- {REMOVED_FEATURES}

### Fixed
- {BUG_FIXES}

### Security
- {SECURITY_FIXES}

## [{VERSION}] - {DATE}

### Added
- {FEATURE_DESCRIPTION}

### Changed
- {CHANGE_DESCRIPTION}

### Fixed
- {FIX_DESCRIPTION}

[Unreleased]: {REPO_URL}/compare/v{VERSION}...HEAD
[{VERSION}]: {REPO_URL}/compare/v{PREV_VERSION}...v{VERSION}
```

## Entry Format

Each entry should:
- Start with a verb (Add, Change, Fix, Remove, etc.)
- Be concise but descriptive
- Include relevant context
- Link to issues/PRs when applicable

### Good Examples

```markdown
### Added
- User authentication with JWT tokens (#123)
- Rate limiting for API endpoints (10 req/min for auth, 100 req/min for API)
- Password reset via email functionality

### Changed
- Upgrade Go version from 1.21 to 1.22
- Improve error messages for validation failures
- Refactor user service to use repository pattern

### Fixed
- Token refresh not invalidating old tokens (#145)
- Race condition in concurrent session creation
- Memory leak in connection pool management

### Security
- Fix SQL injection vulnerability in search endpoint
- Update dependencies with known vulnerabilities
```

### Bad Examples (Avoid)

```markdown
### Added
- stuff
- new feature
- JWT

### Fixed
- bug
- fixed it
- things
```

## Category Guidelines

### Added
New features or capabilities

```markdown
- User registration with email verification
- OAuth2 integration (Google, GitHub)
- API rate limiting
```

### Changed
Changes to existing functionality

```markdown
- Increase password minimum length from 6 to 8 characters
- Update token expiration from 1 hour to 15 minutes
- Improve database query performance
```

### Deprecated
Features that will be removed in future versions

```markdown
- Legacy /v1/auth endpoints (use /v2/auth instead)
- Password-only authentication (OAuth required in next major version)
```

### Removed
Features that were removed

```markdown
- Support for Node.js 14
- Deprecated /legacy API endpoints
- Unused database tables (old_users, temp_sessions)
```

### Fixed
Bug fixes

```markdown
- Token not refreshing when expired (#234)
- Incorrect error message on failed login
- Memory leak in WebSocket connections
```

### Security
Security-related changes

```markdown
- Patch XSS vulnerability in user profile
- Update bcrypt cost factor from 10 to 12
- Add CSRF protection to forms
```

## Version Numbering

Follow Semantic Versioning:
- MAJOR: Breaking changes
- MINOR: New features (backwards compatible)
- PATCH: Bug fixes (backwards compatible)

```
1.0.0 → 1.0.1 (bug fix)
1.0.1 → 1.1.0 (new feature)
1.1.0 → 2.0.0 (breaking change)
```

## Example: Full Feature Entry

When a feature like "user-auth" is complete:

```markdown
## [1.2.0] - 2024-01-18

### Added
- User authentication system with JWT tokens
  - Login endpoint (`POST /api/auth/login`)
  - Signup endpoint (`POST /api/auth/signup`)
  - Token refresh endpoint (`POST /api/auth/refresh`)
  - Logout endpoint (`POST /api/auth/logout`)
- Session management with automatic token rotation
- Rate limiting for authentication endpoints (10 requests/minute)
- Account lockout after 5 failed login attempts

### Changed
- Database schema updated with `users` and `sessions` tables
- API responses now include standard error format

### Security
- Passwords hashed with bcrypt (cost factor 12)
- JWT tokens signed with RS256
- Refresh tokens stored securely in Redis with expiration

### Dependencies
- Added `golang-jwt/jwt/v5` for JWT handling
- Added `redis/go-redis/v9` for session storage
```
