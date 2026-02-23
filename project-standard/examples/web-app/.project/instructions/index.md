---
name: defaults
description: >
  Base project instructions loaded for every session. Covers code style,
  commit conventions, PR guidelines, and general development patterns.
  ALWAYS LOADED.
activation: always
---

# Default Instructions

## Code Style

- Write clear, self-documenting code. Prefer descriptive names over comments.
- Keep functions short and focused on a single responsibility.
- Use consistent formatting enforced by project linters (gofmt for Go,
  Prettier for TypeScript).

## Commit Conventions

Follow Conventional Commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`

Scopes: `api`, `client`, `db`, `auth`, `infra`

Examples:
- `feat(api): add contact search endpoint`
- `fix(client): resolve stale cache on deal update`
- `refactor(db): extract repository interface`

## Pull Request Guidelines

- PRs should address a single concern and include tests.
- Title follows the same Conventional Commits format.
- Include a description explaining **why**, not just what.
- Link related issues using `Closes #123` syntax.
- All CI checks must pass before merging.
- Require at least one approval from a team member.

## General Patterns

- Never commit secrets or credentials. Use environment variables.
- Prefer composition over inheritance in both Go and React code.
- Handle errors explicitly; do not swallow errors silently.
- Log at appropriate levels: `debug` for development, `info` for operations,
  `error` for failures requiring attention.
- All new features require tests before merging.
