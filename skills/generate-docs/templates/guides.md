# Usage Guide Template

Use this template when generating usage guides.

## Structure

```markdown
# {FEATURE_NAME} Usage Guide

> {BRIEF_DESCRIPTION}

## Quick Start

### Prerequisites

{PREREQUISITES_LIST}

### Installation

{INSTALLATION_STEPS}

### Basic Usage

{BASIC_USAGE_EXAMPLE}

## Examples

{FOR_EACH_EXAMPLE}
### {EXAMPLE_TITLE}

{EXAMPLE_DESCRIPTION}

```{LANGUAGE}
{CODE_EXAMPLE}
```
{END_FOR}

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
{FOR_EACH_CONFIG}
| `{OPTION}` | {TYPE} | {DEFAULT} | {DESCRIPTION} |
{END_FOR}

## Troubleshooting

{FOR_EACH_ISSUE}
### {ISSUE_TITLE}

**Symptom:** {SYMPTOM}

**Cause:** {CAUSE}

**Solution:** {SOLUTION}
{END_FOR}

## FAQ

{FOR_EACH_FAQ}
### {QUESTION}

{ANSWER}
{END_FOR}
```

## Example Output

```markdown
# User Auth Usage Guide

> How to integrate authentication into your application

## Quick Start

### Prerequisites

- Go 1.21 or higher
- PostgreSQL 14+
- Redis 6+
- Valid SMTP server for email verification (optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/example/app.git
   cd app
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. **Run database migrations**
   ```bash
   make migrate-up
   ```

4. **Start the server**
   ```bash
   make run
   ```

### Basic Usage

```bash
# Create a new user
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "secure123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "secure123"}'

# Use the access token
curl http://localhost:8080/api/protected \
  -H "Authorization: Bearer <access_token>"
```

## Examples

### User Registration

Register a new user and handle the response.

```bash
# Register new user
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "SecurePass123!",
    "name": "John Doe"
  }'

# Response
{
  "id": 1,
  "email": "newuser@example.com",
  "name": "John Doe",
  "created_at": "2024-01-15T10:00:00Z"
}
```

### Login and Token Usage

Authenticate and use tokens for protected resources.

```bash
# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'

# Response
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 900
}

# Use access token
curl http://localhost:8080/api/users/me \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

### Token Refresh

Refresh expired access tokens.

```bash
# When access token expires, use refresh token
curl -X POST http://localhost:8080/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJSUzI1NiIs..."
  }'

# Response: new tokens
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

### Logout

Invalidate current session.

```bash
curl -X POST http://localhost:8080/api/auth/logout \
  -H "Authorization: Bearer <access_token>"

# Response: 204 No Content
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `JWT_SECRET` | string | (required) | Secret key for JWT signing |
| `JWT_ACCESS_TTL` | duration | `15m` | Access token lifetime |
| `JWT_REFRESH_TTL` | duration | `7d` | Refresh token lifetime |
| `BCRYPT_COST` | int | `12` | Bcrypt hashing cost |
| `MAX_LOGIN_ATTEMPTS` | int | `5` | Failed attempts before lockout |
| `LOCKOUT_DURATION` | duration | `15m` | Account lockout duration |

### Environment Variables

```bash
# .env file
JWT_SECRET=your-super-secret-key-change-in-production
JWT_ACCESS_TTL=15m
JWT_REFRESH_TTL=168h
BCRYPT_COST=12
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION=15m

# Database
DATABASE_URL=postgres://user:pass@localhost:5432/app?sslmode=disable

# Redis
REDIS_URL=redis://localhost:6379/0
```

## Troubleshooting

### Invalid Token Error

**Symptom:** API returns `401 Unauthorized` with "invalid token"

**Cause:** Token is expired, malformed, or was signed with different key

**Solution:**
1. Check if token is expired (decode JWT to see `exp` claim)
2. If expired, use refresh token to get new access token
3. If refresh token also invalid, user must login again
4. Verify `JWT_SECRET` matches between token generation and validation

### Account Locked

**Symptom:** Login returns `423 Locked` after multiple attempts

**Cause:** Too many failed login attempts triggered lockout

**Solution:**
1. Wait for lockout duration (default: 15 minutes)
2. Or reset via admin API: `POST /api/admin/users/{id}/unlock`
3. Check `LOCKOUT_DURATION` configuration if too long/short

### Token Not Refreshing

**Symptom:** Refresh endpoint returns `401` even with valid refresh token

**Cause:** Refresh token was invalidated (logout, password change, or expired)

**Solution:**
1. Check if user logged out from another device
2. Verify refresh token hasn't expired (7 days default)
3. If password was changed, all tokens are invalidated - must login again

### CORS Issues

**Symptom:** Browser blocks requests with CORS error

**Cause:** API not configured for your frontend origin

**Solution:**
1. Add your frontend URL to allowed origins:
   ```bash
   CORS_ORIGINS=http://localhost:3000,https://app.example.com
   ```
2. Ensure credentials mode is enabled if using cookies

## FAQ

### How long do tokens last?

Access tokens expire after 15 minutes by default. Refresh tokens last 7 days.
Configure via `JWT_ACCESS_TTL` and `JWT_REFRESH_TTL`.

### Can I use this with OAuth providers?

Yes! OAuth integration (Google, GitHub) is available. See the OAuth guide
for setup instructions.

### How are passwords stored?

Passwords are hashed using bcrypt with a configurable cost factor (default: 12).
We never store plain-text passwords.

### What happens when I change my password?

All existing sessions are invalidated. Users will need to login again on all devices.

### Is there rate limiting?

Yes. Authentication endpoints are limited to 10 requests/minute.
Regular API endpoints allow 100 requests/minute. Configure via `RATE_LIMIT_*` env vars.
```
