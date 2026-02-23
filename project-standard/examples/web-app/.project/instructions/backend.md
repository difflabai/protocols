---
name: backend
description: >
  Backend development conventions for Go services. Covers hexagonal
  architecture, REST API patterns, database access, and error handling.
  USE WHEN working on src/server/**, src/api/**, or any .go files.
applies_to: ["src/server/**", "**/*.go"]
priority: 100
activation: auto
tags: [backend, go, api]
---

# Backend Development Standards

## Hexagonal Architecture

All backend code follows hexagonal (ports and adapters) architecture:

- **Domain** (`domain/`): Pure business logic. No imports from adapters or
  external packages. Domain types define the core models.
- **Ports** (`ports/`): Interfaces that the domain depends on. Includes both
  driven ports (e.g., `ContactRepository`) and driving ports (e.g.,
  `ContactService`).
- **Adapters** (`adapters/`): Implementations of ports. HTTP handlers,
  PostgreSQL repositories, external API clients.

Dependencies always point inward: adapters depend on ports, ports depend on
domain. Never import adapter code from domain or ports.

## REST API Patterns

- Use Chi router for HTTP routing.
- Group routes by resource: `/api/v1/contacts`, `/api/v1/deals`.
- Return JSON responses with consistent envelope:
  ```json
  { "data": {}, "meta": { "page": 1, "total": 42 } }
  ```
- Use appropriate HTTP status codes: 200 OK, 201 Created, 400 Bad Request,
  404 Not Found, 422 Unprocessable Entity, 500 Internal Server Error.
- Validate request bodies using struct tags and a validation library.

## Database Access

- Use `sqlc` for type-safe SQL queries. Write SQL in `queries/` directory.
- Repositories implement port interfaces and accept `*sql.DB` or `*sql.Tx`.
- Use transactions for multi-step writes.
- Migrations live in `migrations/` and use golang-migrate.

## Error Handling

- Define domain-level error types (e.g., `ErrNotFound`, `ErrConflict`).
- Adapters translate domain errors to HTTP status codes.
- Wrap errors with context using `fmt.Errorf("doing X: %w", err)`.
- Never expose internal error details to API consumers.

## Build and Test

```bash
go build ./...
go test ./... -race -cover
go vet ./...
```
