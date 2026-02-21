---
name: extensions
description: >
  Installed extensions and marketplace configuration. Browse to see what
  extensions are active and where to find new ones.
registries:
  - id: project-central
    url: https://registry.projectstandard.dev/v1
  - id: company-internal
    url: https://extensions.taskflow.example.com/v1
    auth:
      type: bearer
      token_env: INTERNAL_REGISTRY_TOKEN
---

# Extensions

## Installed

- **soc2-compliance** v1.2.0 -- SOC2 compliance rules and audit checks.
  Validates that PRs include security considerations and that sensitive data
  handling follows compliance requirements.

## Marketplace

Extensions can be installed from the registries configured in the frontmatter.
The `project-central` registry hosts community extensions. The
`company-internal` registry hosts proprietary extensions for the organization.
