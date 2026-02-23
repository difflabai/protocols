---
name: ci-pipeline
description: >
  GitHub Actions CI/CD pipeline configuration. Reference when modifying build
  steps, debugging CI failures, or understanding the deployment process.
url: https://github.com/taskflow/taskflow-crm/actions
type: ci-cd
tags: [infrastructure, ci, github-actions]
---

# CI/CD Pipeline

## Summary

The project uses GitHub Actions for continuous integration and deployment. The
pipeline runs on every push and pull request, executing linting, type checking,
unit tests, integration tests, and build verification. Deployment to staging
is automatic on merge to the `staging` branch; production deployment requires
a manual approval step after merging to `main`.

## How to Work With It

- **Workflow files:** Located in `.github/workflows/`. The primary workflow is
  `ci.yml` for PR checks and `deploy.yml` for deployments.
- **PR checks:** All of the following must pass before merging:
  - `lint` -- gofmt, golangci-lint, ESLint, Prettier
  - `typecheck` -- Go vet, TypeScript compiler
  - `test-backend` -- Go tests with race detector and coverage
  - `test-frontend` -- Vitest with coverage
  - `build` -- Docker image build verification
- **Deployment flow:**
  1. Merge to `staging` triggers automatic deployment to staging environment.
  2. Merge to `main` triggers a deployment that pauses for manual approval.
  3. After approval, the Docker image is built, pushed to ECR, and deployed
     to ECS Fargate.
- **Secrets:** Stored in GitHub repository secrets. Never reference secrets
  directly; use the `${{ secrets.NAME }}` syntax in workflow files.
- **Debugging failures:** Check the Actions tab on GitHub. Each job produces
  logs. Integration test failures include database logs from the testcontainer.
