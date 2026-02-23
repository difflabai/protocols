---
name: testing
description: >
  Testing conventions and patterns for backend and frontend code. Covers
  unit tests, integration tests, and general testing philosophy.
  USE WHEN writing tests, reviewing test coverage, or setting up test infrastructure.
applies_to: ["**/*_test.go", "**/*.test.tsx", "**/*.test.ts"]
priority: 90
activation: auto
tags: [testing, quality]
---

# Testing Conventions

## General Philosophy

- Every new feature and bug fix requires tests before merging.
- Prefer integration tests that exercise real behavior over unit tests that
  mock everything.
- Tests should be deterministic: no flaky tests, no reliance on timing or
  external services in CI.

## Backend Tests (Go)

- Use the standard `testing` package. Avoid third-party assertion libraries
  unless the team agrees to adopt one.
- Table-driven tests for functions with multiple input/output cases.
- Integration tests use a real PostgreSQL instance via Docker (testcontainers).
- Name test files `*_test.go` adjacent to the code they test.
- Use `t.Helper()` in test utility functions.
- Run with race detector: `go test ./... -race -cover`.

Example pattern:

```go
func TestContactService_Create(t *testing.T) {
    tests := []struct {
        name    string
        input   domain.Contact
        wantErr bool
    }{
        {name: "valid contact", input: validContact(), wantErr: false},
        {name: "missing email", input: noEmailContact(), wantErr: true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // ...
        })
    }
}
```

## Frontend Tests (React)

- Use Vitest as the test runner with React Testing Library.
- Test user-visible behavior, not implementation details.
- Avoid testing internal component state directly.
- Mock API calls at the network layer using MSW (Mock Service Worker).
- Name test files `*.test.tsx` colocated with the component.

## Integration Tests

- Backend integration tests connect to a real PostgreSQL database spun up via
  testcontainers-go.
- Frontend integration tests use MSW to simulate the API layer.
- End-to-end tests (Playwright) live in `e2e/` and run against the full stack
  in CI.

## Coverage

- Aim for 80% line coverage on backend domain and port layers.
- Frontend coverage targets: 70% for components, 90% for utility functions.
- Coverage reports are generated in CI and posted as PR comments.
