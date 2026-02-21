<!-- This project uses the .project standard (https://github.com/difflabai/protocols) -->
<!-- Tools supporting .project/ should load from .project/instructions/ first -->
<!-- The content below serves as fallback for tools that only read AGENTS.md -->

# TaskFlow CRM -- Project Instructions

This project uses the `.project/` standard for structured AI project
configuration. If your tool supports `.project/`, load instructions from
`.project/instructions/` instead of this file.

## Fallback Instructions

The following is a summary of project conventions for tools that only read
AGENTS.md.

### Code Style

- Write clear, self-documenting code with descriptive names.
- Use consistent formatting: gofmt for Go, Prettier for TypeScript.
- Follow Conventional Commits: `<type>(<scope>): <description>`.

### Backend (Go)

- Hexagonal architecture: domain, ports, adapters.
- Dependencies point inward. Domain code has no external imports.
- Use Chi router, sqlc for database queries, golang-migrate for migrations.
- Wrap errors with context: `fmt.Errorf("doing X: %w", err)`.

### Frontend (React/TypeScript)

- Functional components with hooks only.
- TanStack Query for server state, useState for local state.
- CSS Modules for styling with design tokens from `tokens.css`.

### Testing

- Every feature and bug fix requires tests.
- Backend: table-driven tests, integration tests with testcontainers.
- Frontend: Vitest with React Testing Library, MSW for API mocking.

### General

- Never commit secrets. Use environment variables.
- All CI checks must pass before merging.
- PRs require at least one approval.
