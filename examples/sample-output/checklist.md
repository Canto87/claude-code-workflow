# User Authentication Checklist

> JWT-based user authentication and session management system

## Current Progress

- **Current Phase**: Phase 1 (Basic Auth)
- **Last Update**: 2024-01-15
- **Next Task**: Create `internal/auth/types.go`
- **Overall Progress**: 0/4 Phases completed

---

## Phase 1: Basic Auth

**Document**: `docs/plans/user_auth/01_BASIC_AUTH.md`
**Status**: ⏳ Waiting
**Difficulty**: Medium | **Impact**: High

### Goal
Implement login and signup API

### Checklist
- [ ] Create `internal/auth/types.go`
- [ ] Create `internal/auth/store.go`
- [ ] Implement signup API
- [ ] Implement login API
- [ ] Password hashing (bcrypt)
- [ ] Write test code

### Testing
```bash
go build ./...
go test ./internal/auth/...
curl -X POST http://localhost:8080/auth/signup -d '{"email":"test@test.com","password":"test123"}'
```

### Session Notes
<!-- Record progress from each session -->

---

## Phase 2: JWT Token Management

**Document**: `docs/plans/user_auth/02_JWT.md`
**Status**: ⏳ Waiting
**Difficulty**: Medium | **Impact**: High

### Goal
Implement JWT access token and refresh token

### Checklist
- [ ] Create `internal/auth/jwt.go`
- [ ] Access token generation/verification
- [ ] Refresh token generation/verification
- [ ] Token refresh API
- [ ] Auth middleware

### Testing
```bash
go test ./internal/auth/... -run TestJWT
```

### Session Notes

---

## Phase 3: Session Management

**Document**: `docs/plans/user_auth/03_SESSION.md`
**Status**: ⏳ Waiting
**Difficulty**: Low | **Impact**: Medium

### Goal
Implement session storage and logout

### Checklist
- [ ] Create `internal/auth/session.go`
- [ ] Create session DB table
- [ ] Logout API
- [ ] Session expiration handling

### Testing
```bash
go test ./internal/auth/... -run TestSession
```

### Session Notes

---

## Phase 4: Social Login

**Document**: `docs/plans/user_auth/04_SOCIAL.md`
**Status**: ⏳ Waiting
**Difficulty**: High | **Impact**: Medium

### Goal
Google, GitHub OAuth login

### Checklist
- [ ] Add OAuth configuration
- [ ] Implement Google login
- [ ] Implement GitHub login
- [ ] Account linking logic

### Testing
```bash
# Test in browser
open http://localhost:8080/auth/google
```

### Session Notes

---

## Completion Criteria

Each Phase completion requirements:
1. **Checklist 100% complete**
2. **Tests passing**
3. **No regression in previous Phase features**

## Related Commands

| Command | Description |
|---------|-------------|
| `/status` (project:user-auth) | Check current progress |
| `/phase1` ~ `/phase4` (project:user-auth) | Implement each Phase |
