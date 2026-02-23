---
name: staging-environment
description: >
  Staging deployment for pre-production testing. Reference when discussing
  deployment, testing in staging, or debugging environment-specific issues.
url: https://staging.taskflow.example.com
type: deployment
tags: [infrastructure, staging, aws]
---

# Staging Environment

## Summary

The staging environment mirrors production infrastructure and is deployed
automatically from the `staging` branch via GitHub Actions. It runs on AWS
ECS Fargate with a dedicated RDS PostgreSQL instance. Data is reset weekly
from a sanitized production snapshot.

## How to Work With It

- **Deploy:** Merge to the `staging` branch or run `gh workflow run deploy-staging`.
- **Access:** VPN required. Credentials are stored in the 1Password vault
  named "Engineering."
- **Database:** Separate from production. Reset every Monday from a sanitized
  production snapshot. Safe for destructive testing.
- **Logs:** Available at `https://logs.taskflow.example.com/staging` (Datadog).
- **Feature flags:** Managed via LaunchDarkly; staging has its own environment.
- **Limitations:** Email sending is stubbed; outbound emails are captured in
  Mailhog at `https://staging.taskflow.example.com:8025`.
