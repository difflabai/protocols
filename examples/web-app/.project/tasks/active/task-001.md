---
id: task-001
title: Implement JWT Refresh Token Rotation
status: working
assignee:
  type: user
  id: carol
priority: high
tags: [auth, security]
blocked_by: []
blocks: [task-002]
context_id: sprint-42
---

# Implement JWT Refresh Token Rotation

## Description

Implement refresh token rotation as designed in the auth refactor conversation
(2024-01-15). Access tokens have a 15-minute TTL. Refresh tokens rotate on
each use and are stored server-side in PostgreSQL with family tracking for
theft detection.

## Acceptance Criteria

- [ ] Refresh tokens rotate on each use, returning a new token pair
- [ ] Access token TTL is 15 minutes
- [ ] Old refresh tokens are invalidated after rotation
- [ ] Reuse of a rotated refresh token invalidates the entire token family
- [ ] Token family is tracked via `family_id` column in the refresh_tokens table
- [ ] Integration tests cover rotation, expiry, and reuse-detection scenarios

## Messages

**alice** (2024-01-16 09:00): Carol, please implement refresh token rotation
per the design we discussed yesterday. The domain types and port interface are
already in place from the conversation session.

**carol** (2024-01-16 09:30): Got it. I will start with the PostgreSQL adapter
for refresh token storage, then build the rotation logic, then wire up the
HTTP handler. Targeting PR by end of day tomorrow.

## Artifacts

- Conversation: `.project/conversations/2024-01-15-auth-refactor.md`
- Decision record: `.project/memory/decisions.md` (JWT Authentication section)
