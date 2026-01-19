# API Documentation Template

Use this template when generating API documentation.

## Structure

```markdown
# {FEATURE_NAME} API

> {BRIEF_DESCRIPTION}

## Base URL

```
{BASE_URL}
```

## Authentication

{AUTHENTICATION_DESCRIPTION}

## Endpoints

{FOR_EACH_ENDPOINT}
### {METHOD} {PATH}

{DESCRIPTION}

**Authentication:** {AUTH_REQUIRED}

#### Request

{IF_PATH_PARAMS}
**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
{FOR_EACH_PATH_PARAM}
| `{NAME}` | {TYPE} | {REQUIRED} | {DESCRIPTION} |
{END_FOR}
{END_IF}

{IF_QUERY_PARAMS}
**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
{FOR_EACH_QUERY_PARAM}
| `{NAME}` | {TYPE} | {REQUIRED} | {DEFAULT} | {DESCRIPTION} |
{END_FOR}
{END_IF}

{IF_REQUEST_BODY}
**Request Body:**

```json
{REQUEST_BODY_EXAMPLE}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
{FOR_EACH_FIELD}
| `{NAME}` | {TYPE} | {REQUIRED} | {DESCRIPTION} |
{END_FOR}
{END_IF}

#### Response

**Success Response (200):**

```json
{SUCCESS_RESPONSE_EXAMPLE}
```

{IF_ERROR_RESPONSES}
**Error Responses:**

| Code | Description | Response |
|------|-------------|----------|
{FOR_EACH_ERROR}
| {CODE} | {DESCRIPTION} | `{RESPONSE}` |
{END_FOR}
{END_IF}

#### Example

```bash
curl -X {METHOD} {FULL_URL} \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {TOKEN}" \
  -d '{REQUEST_BODY}'
```

---
{END_FOR}

## Error Codes

| Code | Name | Description |
|------|------|-------------|
{FOR_EACH_ERROR_CODE}
| {CODE} | {NAME} | {DESCRIPTION} |
{END_FOR}

## Rate Limits

{RATE_LIMIT_INFO}
```

## Example Output

```markdown
# User Auth API

> JWT-based authentication API for user management

## Base URL

```
https://api.example.com/v1
```

## Authentication

Most endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <access_token>
```

## Endpoints

### POST /auth/signup

Create a new user account.

**Authentication:** Not required

#### Request

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Valid email address |
| `password` | string | Yes | Min 8 characters |
| `name` | string | No | Display name |

#### Response

**Success Response (201):**

```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2024-01-15T10:00:00Z"
}
```

**Error Responses:**

| Code | Description | Response |
|------|-------------|----------|
| 400 | Invalid email format | `{"error": "invalid_email", "message": "Email format is invalid"}` |
| 409 | Email already exists | `{"error": "email_exists", "message": "Email already registered"}` |

#### Example

```bash
curl -X POST https://api.example.com/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "securePassword123"}'
```

---

### POST /auth/login

Authenticate user and receive tokens.

**Authentication:** Not required

#### Request

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Registered email |
| `password` | string | Yes | User password |

#### Response

**Success Response (200):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

**Error Responses:**

| Code | Description | Response |
|------|-------------|----------|
| 401 | Invalid credentials | `{"error": "invalid_credentials", "message": "Email or password is incorrect"}` |
| 429 | Too many attempts | `{"error": "rate_limited", "message": "Too many login attempts"}` |

#### Example

```bash
curl -X POST https://api.example.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "securePassword123"}'
```

---

## Error Codes

| Code | Name | Description |
|------|------|-------------|
| 400 | Bad Request | Invalid request format or parameters |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Error | Server error |

## Rate Limits

- **Authentication endpoints:** 10 requests per minute
- **API endpoints:** 100 requests per minute
- Rate limit headers included in responses:
  - `X-RateLimit-Limit`
  - `X-RateLimit-Remaining`
  - `X-RateLimit-Reset`
```
