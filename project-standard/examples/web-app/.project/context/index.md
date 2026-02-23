---
name: context-files
description: >
  Project files available for AI context loading. Includes local documents
  and fetchable remote content. Browse when you need reference material
  for implementation work.
auto_include:
  patterns: ["docs/**/*.md", "openapi.yaml"]
  exclude: ["node_modules/**", "dist/**"]
  max_file_size: 1MB
---

# Context Files

Files in this directory (and matched by `auto_include` patterns from the
project root) are available for loading into AI sessions when relevant.

Context files differ from resources: context items have loadable content that
can be pulled into an AI session, while resources are external references
that exist for awareness only.

## Available Context

- **api-spec.md** -- Companion descriptor for the fetchable OpenAPI specification.
  Points to the raw YAML hosted on GitHub.
