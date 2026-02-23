---
name: project-decisions
description: >
  Architectural decision records for TaskFlow. Consult when making architectural
  choices or when understanding why past decisions were made.
tags: [architecture, decisions]
writable: false
---

# Architectural Decisions

## 2023-09-10: PostgreSQL as Primary Database

**Context:** The initial prototype used SQLite for simplicity. As the team grew
and multi-user concurrent access became a requirement, SQLite's write-locking
limitations became a bottleneck.

**Decision:** Migrate to PostgreSQL for all environments including local
development (via Docker).

**Alternatives considered:**
- MySQL -- viable but team had stronger PostgreSQL expertise.
- CockroachDB -- overkill for current scale; revisit if we need multi-region.

**Status:** Implemented. All environments use PostgreSQL 16.

---

## 2023-10-05: Hexagonal Architecture for Backend

**Context:** Early code mixed HTTP handler logic with database queries and
business rules, making testing difficult and changes risky.

**Decision:** Adopt hexagonal architecture (ports and adapters) to enforce
separation of concerns. Domain logic has zero external dependencies.

**Consequences:**
- More files and interfaces upfront.
- Significantly easier to test domain logic in isolation.
- Swapping adapters (e.g., database, external APIs) requires no domain changes.

**Status:** Implemented. All new code follows this pattern; legacy code is
migrated as it is touched.

---

## 2024-01-15: JWT Authentication with RS256

**Context:** The original session-cookie auth worked but complicated our plans
for a mobile client and third-party API access.

**Decision:** Switch to JWT-based authentication using RS256 signing. Access
tokens have a 15-minute TTL. Refresh tokens rotate on each use and are stored
server-side in PostgreSQL.

**Alternatives considered:**
- HS256 -- simpler but doesn't support public key verification by other services.
- OAuth2 with external provider -- adds operational complexity we don't need yet.

**Status:** Implemented. See `src/server/adapters/auth/`.

---

## 2024-03-20: TanStack Query for Server State

**Context:** The frontend was managing API data with a combination of useState,
useEffect, and a hand-rolled cache. This led to stale data bugs and duplicated
fetching logic across components.

**Decision:** Adopt TanStack Query (React Query) as the standard for all
server-state management. Local-only state remains in useState/useContext.

**Consequences:**
- Automatic cache invalidation and refetching.
- Eliminated most loading/error boilerplate.
- Query keys must be managed carefully to avoid cache collisions.

**Status:** Implemented. Migration from manual fetching is complete.
