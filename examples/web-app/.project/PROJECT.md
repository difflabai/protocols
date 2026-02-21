---
spec: "1.0"

name: "TaskFlow"
description: >
  A CRM web application for managing customer relationships, sales pipelines,
  and team collaboration. Built with a Go backend and React frontend, deployed
  on AWS with PostgreSQL for persistence.

id: com.taskflow.crm
version: "2.1.0"
license: MIT

repository:
  type: git
  url: https://github.com/taskflow/taskflow-crm
  branch: main
  subtree: /

providers:
  preferred: anthropic
  supported: [anthropic, openai, google]

agents_md:
  pointer: true
  fallback: true

hierarchy:
  merge: nearest-wins
  inherit: true

conversations:
  default_format: markdown
---

# TaskFlow CRM

TaskFlow is a customer relationship management application designed for small
to mid-size sales teams. It provides contact management, deal tracking, task
assignment, and reporting.

## Architecture

The application follows hexagonal architecture on the backend:

- **Domain layer**: Core business logic in `src/server/domain/`
- **Port layer**: Interfaces in `src/server/ports/`
- **Adapter layer**: HTTP handlers, database repos in `src/server/adapters/`
- **Frontend**: React SPA in `src/client/` communicating via REST API

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Go 1.22, Chi router, sqlc |
| Frontend | React 18, TypeScript, TanStack Query |
| Database | PostgreSQL 16 |
| Auth | JWT (RS256) with refresh token rotation |
| Hosting | AWS ECS Fargate, RDS, CloudFront |
| CI/CD | GitHub Actions |

## Getting Started

```bash
# Backend
cd src/server && go run ./cmd/api

# Frontend
cd src/client && npm run dev

# Full stack (Docker Compose)
docker compose up
```

## Key Directories

```
src/
  server/          # Go backend
    cmd/api/       # Entry point
    domain/        # Business logic
    ports/         # Interfaces
    adapters/      # HTTP, DB, external services
  client/          # React frontend
    src/
      components/  # UI components
      hooks/       # Custom hooks
      pages/       # Route pages
      api/         # API client layer
```
