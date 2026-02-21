---
id: conv-20240115-auth
title: Authentication System Refactor
summary: >
  Refactored authentication from session cookies to JWT with refresh token
  rotation. Decided on RS256 signing, 15-minute access token TTL, and
  server-side refresh token storage in PostgreSQL.
date: 2024-01-15
participants: [alice, carol]
provider: anthropic
model: claude-sonnet-4-6
tags: [auth, security, jwt]
format: markdown
---

# Authentication System Refactor

## Context

Instructions loaded: backend, testing
Memory consulted: project-decisions
Files referenced: src/server/adapters/auth/handler.go, src/server/domain/auth.go

## Conversation

**alice** (2024-01-15 09:00):
We need to refactor our authentication from session cookies to JWT. The mobile
team is starting next quarter and they need token-based auth. Carol and I have
discussed the high-level approach but I want to work through the implementation
details.

**Assistant** (2024-01-15 09:01):
I can help with that. Based on the hexagonal architecture, I'd suggest defining
the auth domain types first, then building outward. A few initial questions:
What signing algorithm are you considering, and do you need refresh token
support from day one?

**alice** (2024-01-15 09:03):
RS256 so other services can verify tokens with the public key. Yes, refresh
tokens from day one. Carol is concerned about token theft so we want rotation.

**Assistant** (2024-01-15 09:04):
Good call on both. Here is the approach I'd recommend:

1. Define domain types: `AccessToken`, `RefreshToken`, `TokenPair`, `Claims`
2. Create port interface: `TokenService` with `Issue`, `Verify`, `Refresh`
3. Implement RS256 adapter using `golang-jwt/jwt/v5`
4. Store refresh tokens server-side in PostgreSQL with family tracking
5. Rotate refresh tokens on each use; invalidate the entire family if reuse
   is detected

For the access token TTL, 15 minutes is standard. Refresh tokens can be longer,
say 7 days, since they are stored server-side and can be revoked.

**carol** (2024-01-15 09:10):
The family-based invalidation is important. If we detect a refresh token being
reused, it means it was stolen. We should invalidate all tokens in that family
and force re-authentication.

**Assistant** (2024-01-15 09:11):
Agreed. I will structure the refresh token table with a `family_id` column.
Each rotation creates a new token in the same family. If a token that has
already been rotated is presented again, we invalidate every token sharing
that `family_id`.

**alice** (2024-01-15 09:15):
Let's go with this approach. Can you start with the domain types and port
interface? I want to review those before we build the adapters.

## Outcomes

- **Created:** `src/server/domain/auth.go`, `src/server/ports/token_service.go`
- **Created:** `src/server/adapters/auth/jwt_handler.go`, `src/server/adapters/auth/refresh.go`
- **Modified:** `src/server/adapters/auth/middleware.go`
- **Created:** `src/server/adapters/auth/handler_test.go`, `src/server/adapters/auth/refresh_test.go`
- **Migration:** `migrations/20240115_add_refresh_tokens.sql`
- **Decisions recorded:** RS256 signing, 15-min access TTL, 7-day refresh TTL,
  family-based token invalidation on reuse detection
