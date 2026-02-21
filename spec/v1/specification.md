# The `.project` Standard

## Cross-Provider AI Project Protocol Specification

**Version:** 1.0.0-draft
**Status:** Draft
**Date:** 2026-02-21
**License:** Apache-2.0

---

## 1. Abstract

AI coding tools --- Claude Code, OpenAI Codex, Cursor, Windsurf, Gemini, and others --- each define their own project configuration formats (`.claude/`, `.codex/`, `.cursor/`, `.windsurf/`). The AGENTS.md standard (Linux Foundation) provides a cross-tool markdown file for coding agent instructions, but it lacks structure for memory, conversations, files, tasks, agents, and extensibility.

The `.project` standard defines a **vendor-neutral directory structure** that provides the rich, structured project context of proprietary AI project systems in a format that works across all providers. It lives in a git repository (or subtree), supports multi-user collaboration, hierarchical overrides, marketplace extensions, and A2A-compatible task management.

This specification uses a **markdown-first** approach: every file in `.project/` is authored as markdown with YAML frontmatter. Tools parse the structured frontmatter; humans read and write natural markdown. A **three-tier progressive disclosure** model ensures that tools load only what they need, when they need it, keeping context windows efficient.

The only required file is `PROJECT.md`. Everything else is optional and added as needed.

---

## 2. Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [BCP 14](https://www.rfc-editor.org/bcp/bcp14) [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) [RFC 8174](https://datatracker.ietf.org/doc/html/rfc8174) when, and only when, they appear in capitalized form, as shown here.

Additional terms used throughout this specification:

**Frontmatter** --- A block of YAML metadata delimited by `---` lines at the beginning of a markdown file.

**Body** --- The markdown content following the frontmatter delimiter in a file.

**Catalog** --- The collection of Tier 1 metadata (name and description) for all items in a directory, used for discovery.

**Implementor** --- A tool, IDE, agent, or platform that reads and/or writes `.project/` directories.

**Session** --- A single interaction context between a user and an AI tool, from startup to termination.

**Activation** --- The process by which an item's full content (Tier 2) is loaded into the current session context.

---

## 3. Overview and Design Principles

### 3.1 Markdown-First

Every component in `.project/` is authored as **markdown with YAML frontmatter**. This is the universal file format:

```markdown
---
name: some-item
description: What this is and when to use it.
---

# Body Content

Free-form markdown content goes here. This is the actual substance ---
instructions, knowledge, notes, whatever the item contains.
```

The rationale for this approach:

- **Frontmatter** carries structured metadata (name, description, tags, configuration). Tools parse this for automation.
- **Body** carries the actual content in flexible markdown. Humans read and write this naturally.
- **No standalone YAML or JSON files are required** --- even index files and the project manifest use this pattern.
- Additional structured data MAY appear in frontmatter when needed, but the specification never mandates rigid schemas for body content.
- Tools that need structured data parse frontmatter; the body is always free-form.
- Additional frontmatter fields beyond those defined in this specification are ALWAYS allowed. Implementors MUST NOT reject files containing unrecognized frontmatter fields.

### 3.2 Progressive Disclosure

Every component separates description from content using a three-tier loading model, inspired by the [agentskills.io](https://agentskills.io) pattern:

| Tier | What Loads | When | Token Budget |
|------|-----------|------|------------|
| **Tier 1: Catalog** | `name` + `description` from frontmatter | At session startup for ALL items | ~50-100 tokens per item |
| **Tier 2: Content** | Full body of the activated item | When determined to be relevant | < 5,000 tokens recommended |
| **Tier 3: References** | Linked files, scripts, external data | When explicitly needed during execution | Unbounded |

**Tier 1 discovery**: Implementors scan directories and read only YAML frontmatter from each `.md` file to build a catalog. No index file is required --- the frontmatter IS the index.

**Optional `index.md`**: Directories MAY include an `index.md` file whose frontmatter lists entries with names and descriptions as a pre-built catalog (avoiding the need to scan many individual files). The body of `index.md` can contain any useful overview text.

**The `description` field** SHOULD explain both what the item contains AND when it should be loaded (usage triggers). This dual purpose allows tools to match items to the current context without loading the full content.

**Content is never loaded eagerly** except for items marked `activation: always` (such as `index.md`) and the `PROJECT.md` manifest.

### 3.3 Context vs Resources

The standard distinguishes between two categories of linked content:

**Context** (`context/` directory) --- Content likely to be pulled into AI context:
- Local files (documentation, specifications, diagrams) that tools can read directly
- Fetchable remote content (URLs that can be downloaded or scraped)
- These items participate in Tier 2 and Tier 3 loading --- they get loaded when relevant

**Resources** (`resources/` directory) --- Purely external references:
- Links to systems, dashboards, artifacts, deployments, repositories
- Things an AI cannot (or should not) fetch --- they exist for human reference or for the AI to know about
- Each resource has an optional summary and usage notes
- These items are **Tier 1 only by default** --- their name, description, summary, and usage notes ARE the content; there is nothing further to load

### 3.4 Convention Over Configuration

The standard follows predictable conventions to minimize required configuration:

- File names serve as identifiers when `name` is not specified in frontmatter.
- Files prefixed with `_` have special meaning (`index.md`, `index.md`, `local.md`).
- Subdirectories within a system directory provide organizational grouping.
- Default behaviors are always the most common use case.

### 3.5 Flexibility Over Strictness

The standard prioritizes practical adoption over rigid conformance:

- JSON schemas are provided as OPTIONAL tooling aids, not requirements.
- Additional frontmatter fields are always permitted.
- Body content is always free-form markdown.
- Implementors SHOULD be lenient in what they accept and strict in what they produce.

---

## 4. Directory Structure

A conforming `.project/` directory MUST contain a `PROJECT.md` file. All other directories and files are OPTIONAL and added as needed.

```
.project/
  PROJECT.md                         # [REQUIRED] Project manifest

  instructions/                      # [OPTIONAL] Project instructions
    index.md                     #   Base instructions (always loaded)
    <topic>.md                       #   Domain-specific instructions
    local.md                        #   Personal overrides (gitignored)

  memory/                            # [OPTIONAL] Persistent knowledge
    index.md                        #   Optional catalog and overview
    <topic>.md                       #   Knowledge files
    entities/                        #   Structured entity data
      <entity>.md

  conversations/                     # [OPTIONAL] Conversation archives
    index.md                        #   Catalog with format configuration
    <conversation>.md                #   Individual conversations

  context/                           # [OPTIONAL] Files for AI context
    index.md                        #   Catalog of context files
    <file>.<ext>                     #   Local files (any format)
    <descriptor>.md                  #   Metadata for local or remote files

  resources/                         # [OPTIONAL] External references
    index.md                        #   Catalog of external resources
    <resource>.md                    #   Individual resource descriptions

  tasks/                             # [OPTIONAL] Task management
    index.md                        #   Task board overview
    active/                          #   Tasks in progress
      <task>.md
    completed/                       #   Finished tasks
      <task>.md

  agents/                            # [OPTIONAL] Agent definitions
    index.md                        #   Agent catalog
    <agent>.md                       #   Individual agent definitions

  extensions/                        # [OPTIONAL] Plugins and compliance
    index.md                        #   Registry and marketplace config
    <extension>/                     #   Extension directories

  adapters/                          # [OPTIONAL] Provider-specific mappings
    <provider>.md                    #   Mapping configuration per provider

  users/                             # [OPTIONAL] Multi-user configuration
    index.md                        #   Role definitions and policies
    <user>.local.md                  #   Per-user overrides (gitignored)

  hooks/                             # [OPTIONAL] Lifecycle scripts
    on-session-start.sh              #   Executed at session startup
    on-session-end.sh                #   Executed at session teardown
```

### 4.1 Directory Naming

The root directory MUST be named `.project`. The leading dot follows the established convention for tool configuration directories (`.git/`, `.github/`, `.vscode/`).

### 4.2 File Naming Conventions

- All markdown files within `.project/` MUST use the `.md` extension.
- File names SHOULD use lowercase kebab-case (e.g., `auth-refactor.md`, `staging-environment.md`).
- Files prefixed with `_` (underscore) have special semantics defined by this specification:
  - `index.md` --- Optional directory catalog and overview.
  - `index.md` --- Content that is always loaded (activation: always implied).
  - `local.md` --- Personal overrides that MUST be gitignored.
- Files with a `.local.md` suffix SHOULD be gitignored.

### 4.3 Minimal Conformance

A minimal conforming `.project/` directory contains only:

```
.project/
  PROJECT.md
```

All other structure is added progressively as the project needs it.

---

## 5. PROJECT.md Manifest

### 5.1 Purpose

`PROJECT.md` is the **only required file** in a `.project/` directory. It serves as:

1. The **project manifest** identifying the project and its configuration.
2. The **entry point** for implementors discovering and loading the `.project/` directory.
3. A **human-readable overview** of the project in its body content.

Implementors MUST load `PROJECT.md` in full (both frontmatter and body) at session startup.

### 5.2 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `spec` | string | The `.project` standard version. MUST be a semver-compatible string. For this version: `"1.0"`. |

#### Recommended Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Human-readable project name. |
| `description` | string | Project description. SHOULD be 1-3 sentences. |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Reverse-domain project identifier (e.g., `com.example.my-app`). |
| `version` | string | Project version (semver recommended). |
| `license` | string | SPDX license identifier. |
| `repository` | object | Repository metadata. See [5.3](#53-repository-object). |
| `providers` | object | Provider preferences. See [5.4](#54-providers-object). |
| `agents_md` | object | AGENTS.md reconciliation config. See [Section 19](#19-agentsmd-reconciliation). |
| `hierarchy` | object | Hierarchical override config. See [Section 16](#16-hierarchical-override). |
| `conversations` | object | Conversation system config. See [Section 8](#8-conversations-system). |

### 5.3 Repository Object

```yaml
repository:
  type: git                          # Version control system
  url: https://github.com/org/repo   # Repository URL
  branch: main                       # Default branch
  subtree: /                         # Root path (for monorepos)
```

All fields within `repository` are OPTIONAL.

### 5.4 Providers Object

```yaml
providers:
  preferred: anthropic               # Preferred provider identifier
  supported: [anthropic, openai, google]  # List of supported providers
```

All fields within `providers` are OPTIONAL and purely informational. Implementors MAY use `preferred` as a hint for default model selection.

### 5.5 Body Content

The body of `PROJECT.md` is free-form markdown providing a project overview. Since `PROJECT.md` is loaded eagerly, this content SHOULD be concise --- ideally under 2,000 tokens. It SHOULD contain information useful to both human developers and AI tools.

### 5.6 Complete Example

```markdown
---
spec: "1.0"

name: "Acme CRM"
description: >
  A customer relationship management application built with a Go backend
  and React frontend. Deployed on AWS using ECS Fargate.

id: com.acme.crm
version: "2.4.1"
license: MIT

repository:
  type: git
  url: https://github.com/acme-corp/crm
  branch: main

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

# Acme CRM

A customer relationship management application for small and medium businesses.

## Architecture

- **Backend**: Go 1.22 with Chi router, hexagonal architecture
- **Frontend**: React 18 with TypeScript, Vite build system
- **Database**: PostgreSQL 16 with pgx driver
- **Infrastructure**: AWS ECS Fargate, RDS, CloudFront

## Quick Start

```bash
# Backend
cd server && go run ./cmd/api

# Frontend
cd client && npm run dev
```

## Key Directories

- `server/` --- Go backend services
- `client/` --- React frontend application
- `infrastructure/` --- Terraform IaC definitions
- `docs/` --- Project documentation
```

### 5.7 Mapping to Existing Standards

| `.project` | Claude Code | Codex | Cursor | AGENTS.md |
|------------|------------|-------|--------|-----------|
| `PROJECT.md` | `.claude/settings.json` + `CLAUDE.md` | `AGENTS.md` header | `.cursor/config.json` | Top-level `AGENTS.md` |

---

## 6. Instructions System

### 6.1 Purpose

The `instructions/` directory contains project instructions that guide AI behavior. Instructions are prescriptive --- they tell the AI what to do and how to do it. This is analogous to:

- Claude Code's `CLAUDE.md` and `.claude/rules/` files
- Codex's `AGENTS.md` sections
- Cursor's `.cursorrules` and `.cursor/rules/` files
- AGENTS.md instruction blocks

Use instructions for coding standards, architectural guidelines, testing requirements, deployment procedures, and workflow preferences.

### 6.2 File Format

Each instruction file is a markdown file with YAML frontmatter:

```markdown
---
name: backend
description: >
  Backend development conventions for Go services. Covers hexagonal
  architecture, REST API patterns, database access, and testing.
  USE WHEN working on server/**, api/**, or any .go files.
applies_to: ["server/**", "api/**", "**/*.go"]
priority: 100
activation: auto
tags: [backend, go, api]
---

# Backend Development Standards

## Architecture

This project uses hexagonal architecture. All business logic lives in
the `domain/` package with no external dependencies...

## API Conventions

- Use RESTful resource naming
- Return consistent error envelopes: `{ "error": { "code": "...", "message": "..." } }`
- All endpoints require authentication except `/health` and `/ready`

## Testing

- Run tests: `go test ./... -race -cover`
- Minimum coverage: 80% for domain packages
- Use table-driven tests for all handler functions
```

### 6.3 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | What this instruction covers AND when it should be loaded. |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Identifier. Defaults to filename without extension. |
| `applies_to` | string[] | Glob patterns for file paths that trigger activation. |
| `priority` | integer | Loading priority (higher loads first). Default: `0`. |
| `activation` | string | One of: `always`, `auto`, `manual`. Default: `auto`. |
| `tags` | string[] | Categorical tags for filtering and matching. |

### 6.4 Activation Modes

| Mode | Behavior |
|------|----------|
| `always` | Content is loaded at session startup. Used for base instructions. |
| `auto` | Content is loaded when `description` or `applies_to` match the current context. This is the default. |
| `manual` | Content is loaded only when explicitly requested by the user or another instruction. |

### 6.5 Special Files

#### `index.md`

The `index.md` file, if present, MUST be treated as having `activation: always` regardless of its frontmatter. It contains base instructions that apply to all interactions.

```markdown
---
name: defaults
description: Base project instructions that always apply.
---

# Project Defaults

- Use TypeScript for all new code
- Write tests before implementation
- Use conventional commits for all commit messages
- Never commit secrets or credentials
```

#### `local.md`

The `local.md` file contains personal instruction overrides. It MUST be listed in `.gitignore` (see [Section 20](#20-gitignore-conventions)). It is loaded after all other instructions at the highest priority, allowing individual developers to customize behavior without affecting the team.

```markdown
---
name: local
description: Personal instruction overrides.
---

# My Preferences

- Use verbose variable names; I prefer readability over brevity
- Always explain your reasoning before making changes
- Run the full test suite after every change, not just affected tests
```

### 6.6 Loading Behavior

- **Tier 1**: Implementors MUST scan the `instructions/` directory at session startup and read frontmatter from each `.md` file. This builds the instruction catalog.
- **Tier 2**: When the implementor determines an instruction is relevant (via `description` matching, `applies_to` glob matching against active files, or `tags` matching), it MUST load the full body.
- **Tier 3**: Instructions MAY reference external files. These are loaded on demand during execution.

### 6.7 Priority Resolution

When multiple instructions are active, they are applied in this order (lowest priority first, highest last):

1. AGENTS.md fallback content (if enabled) --- priority -1 (implicit)
2. Instructions sorted by `priority` field (ascending)
3. `local.md` --- always applied last (implicit highest priority)

When instructions conflict, the higher-priority instruction wins. Implementors SHOULD warn when detecting contradictory instructions at the same priority level.

### 6.8 Mapping to Existing Standards

| `.project` | Claude Code | Codex | Cursor | AGENTS.md |
|------------|------------|-------|--------|-----------|
| `instructions/index.md` | Root `CLAUDE.md` | Root `AGENTS.md` | `.cursorrules` | Root `AGENTS.md` |
| `instructions/<topic>.md` | `.claude/rules/<topic>.md` | Subdirectory `AGENTS.md` | `.cursor/rules/<topic>.mdc` | Subdirectory `AGENTS.md` |
| `instructions/local.md` | `.claude/settings.local.json` | N/A | N/A | N/A |
| `applies_to` | `globs` in `.claude/rules/` | Directory scoping | `globs` in `.cursor/rules/` | Directory scoping |

---

## 7. Memory System

### 7.1 Purpose

The `memory/` directory stores persistent knowledge --- facts, decisions, discovered patterns, and entity data. Memory is **descriptive** (what is known) as opposed to instructions which are **prescriptive** (what to do).

Use memory for:
- Architectural decision records (ADRs)
- Discovered project patterns and conventions
- Entity information (team members, APIs, services)
- Learned facts about the codebase
- Historical context that informs future work

This is analogous to:
- Claude Code's memory entries in `CLAUDE.md`
- Cursor's `@memories` feature
- Windsurf's cascade memories

### 7.2 File Format

```markdown
---
name: project-decisions
description: >
  Architectural decision records. Consult when making architectural
  choices or when understanding why past decisions were made.
tags: [architecture, decisions]
writable: false
---

# Architectural Decisions

## 2024-06-15: Switch from SQLite to PostgreSQL

**Context**: Application needed multi-user concurrent access. SQLite's
write locking caused timeouts under load.

**Decision**: Migrate all environments to PostgreSQL 16.

**Consequences**: More operational complexity, but eliminates concurrency
bottlenecks and enables advanced query features (JSONB, full-text search).

**Status**: Implemented

## 2024-08-01: Adopt Hexagonal Architecture

**Context**: Business logic was tangled with HTTP handlers and database
queries, making testing difficult and changes risky.

**Decision**: Refactor to hexagonal architecture with domain, ports,
and adapters packages.

**Status**: In progress (server/domain/ complete, adapters migrating)
```

### 7.3 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | What knowledge this file contains AND when to consult it. |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Identifier. Defaults to filename without extension. |
| `tags` | string[] | Categorical tags for discovery. |
| `writable` | boolean | Whether AI tools MAY append to this file. Default: `false`. |
| `activation` | string | One of: `always`, `auto`, `manual`. Default: `auto`. |

### 7.4 Writable Memory

When `writable: true`, implementors MAY append new entries to the file's body during a session. This enables AI tools to record discoveries, decisions, and patterns as they work.

Implementors MUST:
- Only append to the body; never modify existing content.
- Include a date or timestamp with each appended entry.
- Respect any structure established in the existing body content.

Implementors SHOULD:
- Confirm with the user before writing to memory in interactive sessions.
- Use a consistent format matching existing entries in the file.

### 7.5 External Memory Sources

Memory files MAY reference external knowledge sources using resource descriptor fields:

```markdown
---
name: confluence-docs
description: >
  Product requirements from Confluence. Consult when working on
  feature implementation or understanding business rules.
type: url
url: https://wiki.example.com/spaces/PRODUCT
auth:
  type: bearer
  token_env: CONFLUENCE_TOKEN
refresh: daily
---

This Confluence space contains all product requirement documents (PRDs),
feature specifications, and business rule definitions. Navigate to the
"Current Sprint" section for active work items.
```

When a memory file includes `type: url`, the URL content becomes the Tier 3 data. The file body provides context and navigation hints. See [Section 17](#17-security-model) for auth handling.

### 7.6 Entity Subdirectory

The `memory/entities/` subdirectory is a conventional location for structured entity data --- team members, APIs, services, and other reference information:

```markdown
---
name: team
description: >
  Team member directory. Reference when assigning tasks,
  understanding code ownership, or routing questions.
tags: [team, people]
---

# Engineering Team

## Alice Chen — Backend Lead
- GitHub: @alicec
- Expertise: Go, PostgreSQL, distributed systems
- Owns: server/domain/, server/adapters/db/

## Bob Martinez — Frontend Lead
- GitHub: @bobm
- Expertise: React, TypeScript, accessibility
- Owns: client/src/components/, client/src/hooks/
```

### 7.7 Loading Behavior

- **Tier 1**: Frontmatter scanned at startup. The catalog provides knowledge topics and when to consult them.
- **Tier 2**: Full body loaded when the implementor determines the knowledge is relevant to the current task.
- **Tier 3**: External URLs fetched only when needed and permitted by auth configuration.

### 7.8 Mapping to Existing Standards

| `.project` | Claude Code | Codex | Cursor | AGENTS.md |
|------------|------------|-------|--------|-----------|
| `memory/` files | Facts in `CLAUDE.md` | N/A | `@memories` | N/A |
| `memory/entities/` | N/A | N/A | N/A | N/A |
| `writable: true` | Auto-updated `CLAUDE.md` | N/A | Auto memories | N/A |

---

## 8. Conversations System

### 8.1 Purpose

The `conversations/` directory archives past AI conversations. This provides:

- **Continuity**: Resume context from previous sessions.
- **Knowledge**: Past conversations contain decisions, solutions, and rationale.
- **Collaboration**: Team members can review what was discussed and decided.

Use conversations when projects benefit from persistent conversation history across sessions or team members.

This is analogous to:
- Claude Projects' conversation history
- Cursor's chat history (local only)
- ChatGPT's conversation archive

### 8.2 Format Configuration

The default conversation format is configured in `PROJECT.md`:

```yaml
conversations:
  default_format: markdown    # markdown | jsonl | provider-native
```

Individual conversations MAY override this with their own `format` field.

### 8.3 File Format (Markdown)

```markdown
---
id: conv-20240115-auth
title: Authentication System Refactor
summary: >
  Refactored authentication from session cookies to JWT with refresh
  token rotation. Decided on RS256 signing with 15-minute access token
  TTL. Created jwt_handler.go and refresh.go.
date: 2024-01-15
participants: [alice]
provider: anthropic
model: claude-sonnet-4-6
tags: [auth, security, jwt]
format: markdown
---

# Authentication System Refactor

## Session Context

**Instructions loaded**: backend, security
**Memory consulted**: project-decisions
**Files referenced**: server/auth/handler.go, server/auth/middleware.go

## Conversation

**User** (2024-01-15 09:00):
I need to refactor our authentication system from session cookies to JWT.
What approach do you recommend?

**Assistant** (2024-01-15 09:01):
For your Go backend with the hexagonal architecture, I recommend...

**User** (2024-01-15 09:15):
Let's go with RS256 and add refresh token rotation.

**Assistant** (2024-01-15 09:15):
Good choice. Here's the implementation plan...

## Outcomes

- **Created**: server/auth/jwt_handler.go, server/auth/refresh.go
- **Modified**: server/auth/middleware.go, server/auth/handler_test.go
- **Decisions**: RS256 signing, refresh token rotation, 15-minute access TTL
- **Follow-up**: Need to implement token revocation (see task-001)
```

### 8.4 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Conversation title. |
| `summary` | string | Summary of what was discussed and decided. This is the Tier 1 descriptor. |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique conversation identifier. Defaults to filename. |
| `date` | string | ISO 8601 date or datetime of the conversation. |
| `participants` | string[] | User identifiers who participated. |
| `provider` | string | AI provider used (e.g., `anthropic`, `openai`). |
| `model` | string | Model identifier used. |
| `tags` | string[] | Categorical tags. |
| `format` | string | Content format of this conversation. Overrides project default. |

### 8.5 Alternative Formats

While markdown is the RECOMMENDED default, conversations MAY use other formats:

**JSONL** (`format: jsonl`): Each line is a JSON object representing a message. Suitable for programmatic access and streaming.

```jsonl
{"role":"user","content":"Refactor auth to JWT","timestamp":"2024-01-15T09:00:00Z"}
{"role":"assistant","content":"I recommend RS256 with refresh...","timestamp":"2024-01-15T09:01:00Z"}
```

**Provider-native** (`format: provider-native`): Opaque format from the original provider. The frontmatter still provides the Tier 1 summary; the body is provider-specific.

Implementors MUST always support reading frontmatter regardless of the body format. Implementors SHOULD support the markdown format. Support for other formats is OPTIONAL.

### 8.6 Loading Behavior

- **Tier 1**: Frontmatter scanned at startup. The `summary` field provides enough context to determine relevance without loading the full conversation.
- **Tier 2**: Full conversation body loaded only when the implementor determines the conversation is relevant to the current task.
- **Tier 3**: Files referenced within the conversation are loaded on demand.

Implementors SHOULD NOT eagerly load conversation bodies. A project with hundreds of archived conversations should add only a few thousand tokens to the Tier 1 catalog.

### 8.7 Mapping to Existing Standards

| `.project` | Claude Code | Codex | Cursor | AGENTS.md |
|------------|------------|-------|--------|-----------|
| `conversations/` | Claude Projects history | N/A | Chat history (local) | N/A |

---

## 9. Context System

### 9.1 Purpose

The `context/` directory contains files that are **likely to be loaded into AI context** --- local documents, specifications, diagrams, configuration files, and fetchable remote content.

The key distinction from `resources/` (Section 10): context files have loadable content that tools can read and include in the AI's working context. Resources are external references that exist for awareness only.

Use context for:
- Architecture diagrams
- API specifications (OpenAPI, GraphQL schemas)
- Design documents
- Configuration file templates
- Any file the AI should be able to read when relevant

This is analogous to:
- Claude Projects' uploaded files
- Cursor's `@docs` and `@files` features
- Codex's referenced documentation

### 9.2 Local Files

Any file placed in the `context/` directory is available for AI context loading. Files MAY be any format --- markdown, YAML, JSON, images, PDFs, etc.

For non-markdown files, an optional companion `.md` file provides the Tier 1 description:

```
context/
  architecture.png              # The actual diagram
  architecture.md               # Metadata and description (optional)
  api-spec.yaml                 # OpenAPI specification
  api-spec.md                   # Metadata and description (optional)
  design-principles.md          # Markdown file (self-describing)
```

### 9.3 Companion Metadata Files

When a non-markdown file needs Tier 1 metadata, a companion `.md` file provides it:

```markdown
---
name: architecture-diagram
description: >
  System architecture overview diagram showing service boundaries,
  data flow, and deployment topology. Reference when discussing
  system design or adding new services.
file: architecture.png
mime_type: image/png
---

The architecture follows a hexagonal pattern with three main services:
API Gateway, Domain Service, and Data Service. The API Gateway handles
all external traffic and routes to the appropriate domain service.
```

The `file` field links the metadata to its companion file. If `file` is not specified, the implementor SHOULD look for a non-markdown file with the same base name.

### 9.4 Auto-Include Patterns

The `index.md` file MAY specify patterns to automatically include files from the project repository (outside `.project/`) as context:

```markdown
---
name: context-files
description: Project files available for AI context loading.
auto_include:
  patterns: ["docs/**/*.md", "openapi.yaml", "*.proto"]
  exclude: ["node_modules/**", "vendor/**", "dist/**"]
  max_file_size: 1MB
---

# Context Files

Files in this directory and matched by auto_include patterns are
available for loading into AI sessions when relevant.
```

#### Auto-Include Fields

| Field | Type | Description |
|-------|------|-------------|
| `auto_include.patterns` | string[] | Glob patterns (relative to repo root) to include. |
| `auto_include.exclude` | string[] | Glob patterns to exclude from auto-include. |
| `auto_include.max_file_size` | string | Maximum file size for auto-included files. Default: `1MB`. |

Auto-included files are discovered at Tier 1 using their file path as the name and file extension as context. They do not have descriptions unless a companion `.md` file is provided within the `context/` directory.

### 9.5 Remote Fetchable Content

Context entries MAY reference remote content that can be fetched:

```markdown
---
name: api-spec
description: >
  OpenAPI 3.0 specification for the public REST API.
  USE WHEN working on API endpoints, client generation, or documentation.
type: url
url: https://raw.githubusercontent.com/acme-corp/crm/main/openapi.yaml
refresh: daily
mime_type: application/yaml
---
```

#### Remote Content Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | MUST be `url` for remote content. |
| `url` | string | URL to fetch content from. |
| `refresh` | string | Cache refresh interval: `session`, `daily`, `weekly`, `manual`. Default: `session`. |
| `mime_type` | string | MIME type of the content. Helps implementors handle the content correctly. |
| `auth` | object | Authentication configuration. See [Section 17](#17-security-model). |

### 9.6 Loading Behavior

- **Tier 1**: Frontmatter from `.md` files is scanned. For non-markdown files without companion metadata, the file name and extension serve as the catalog entry.
- **Tier 2**: File content is loaded when the implementor determines relevance.
- **Tier 3**: Remote URLs are fetched only when explicitly needed and cached according to `refresh` policy.

Implementors SHOULD respect `max_file_size` to prevent loading very large files into context.

### 9.7 Mapping to Existing Standards

| `.project` | Claude Code | Codex | Cursor | AGENTS.md |
|------------|------------|-------|--------|-----------|
| `context/` files | Claude Projects files | N/A | `@docs`, `@files` | N/A |
| `auto_include` | N/A | N/A | `.cursor/include` | N/A |

---

## 10. Resources System

### 10.1 Purpose

The `resources/` directory holds references to **external systems that are NOT loaded into AI context**. These exist for awareness --- so the AI knows about the project's ecosystem, tooling, and infrastructure without needing to fetch or process the external content.

The key distinction from `context/` (Section 9):
- **`context/`** items have loadable content (Tiers 1, 2, and 3)
- **`resources/`** items are **Tier 1 only by default** --- their name, description, summary, and usage notes ARE the content

Use resources for:
- Deployment environments (staging, production URLs)
- CI/CD pipelines
- Design systems and Figma files
- Monitoring dashboards
- External service documentation
- Third-party integrations

### 10.2 File Format

```markdown
---
name: staging-environment
description: Staging deployment for pre-production testing.
url: https://staging.myapp.example.com
type: deployment
tags: [infrastructure, staging]
---

# Staging Environment

## Summary

The staging environment mirrors production and is deployed automatically
from the `staging` branch via GitHub Actions.

## How to Work With It

- **Deploy**: Merge to `staging` branch or run `gh workflow run deploy-staging`
- **Access**: VPN required, credentials in 1Password vault "Engineering"
- **Database**: Separate from production, reset weekly from sanitized prod snapshot
- **Logs**: Available at the centralized logging dashboard
```

### 10.3 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | What this resource is. |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Identifier. Defaults to filename without extension. |
| `url` | string | URL to the external resource. |
| `type` | string | Resource category (e.g., `deployment`, `design`, `ci`, `monitoring`, `documentation`). |
| `tags` | string[] | Categorical tags. |

### 10.4 Body Content

The body of a resource file SHOULD contain:

- **Summary**: A concise description of what the resource is and does.
- **How to Work With It**: Practical instructions for interacting with the resource.

This content is the primary value of the resource entry --- it gives the AI (and human developers) the knowledge needed to work with external systems without fetching them.

### 10.5 Loading Behavior

Resources are **Tier 1 only by default**:

- **Tier 1**: Frontmatter scanned at startup, providing awareness of external systems.
- **Tier 2**: Body content MAY be loaded when the resource is relevant. Since the body contains summary and usage notes (not external content), this is lightweight.
- **Tier 3**: Not applicable. The `url` is for human reference or AI awareness, not for fetching.

Implementors MUST NOT automatically fetch resource URLs. If a resource URL needs to be accessed, the user must explicitly request it.

### 10.6 Example: CI Pipeline

```markdown
---
name: ci-pipeline
description: GitHub Actions CI/CD pipeline configuration and status.
url: https://github.com/acme-corp/crm/actions
type: ci
tags: [ci, github-actions, deployment]
---

# CI/CD Pipeline

## Summary

The project uses GitHub Actions for continuous integration and deployment.
All pushes trigger the test suite; merges to `main` trigger production
deployment.

## Workflows

- **ci.yml**: Runs on all pushes. Lints, tests, builds.
- **deploy-staging.yml**: Runs on merge to `staging`. Deploys to staging.
- **deploy-production.yml**: Runs on merge to `main`. Deploys to production.
- **security-scan.yml**: Runs weekly. SAST and dependency scanning.

## How to Work With It

- Check pipeline status before merging PRs
- If CI fails, check the Actions tab for logs
- To skip CI on documentation-only changes, include `[skip ci]` in commit message
```

### 10.7 Mapping to Existing Standards

| `.project` | Claude Code | Codex | Cursor | AGENTS.md |
|------------|------------|-------|--------|-----------|
| `resources/` | N/A | N/A | N/A | N/A |

The resources system is a novel addition. No existing AI coding tool provides a structured way to reference external systems.

---

## 11. Tasks System

### 11.1 Purpose

The `tasks/` directory provides lightweight, file-based task management compatible with the [A2A (Agent-to-Agent) protocol](https://github.com/google/A2A). Tasks track work items that can be assigned to humans or AI agents.

Use tasks for:
- Sprint work items
- Implementation tasks derived from conversations
- Agent-to-agent work delegation
- Simple project management without external tools

### 11.2 Directory Structure

```
tasks/
  index.md                    # Task board overview and configuration
  active/                      # Tasks currently in progress
    task-001.md
    task-002.md
  completed/                   # Finished tasks
    task-000.md
```

Tasks SHOULD be organized into subdirectories by status. The conventional subdirectory names are `active/` and `completed/`, but implementors MUST use the `status` field in frontmatter as the authoritative state, not the directory location.

### 11.3 File Format

```markdown
---
id: task-001
title: Implement JWT Refresh Token Rotation
status: working
assignee:
  type: user
  id: alice
priority: high
tags: [auth, security]
blocked_by: []
blocks: [task-002]
context_id: sprint-42
created: 2024-01-16
updated: 2024-01-17
---

# Implement JWT Refresh Token Rotation

## Description

Implement refresh token rotation as decided in the auth refactor
conversation (conv-20240115-auth). Access tokens should have a
15-minute TTL. Refresh tokens rotate on each use with the previous
token invalidated immediately.

## Acceptance Criteria

- [ ] Refresh tokens rotate on each use
- [ ] Access token TTL is configurable, defaults to 15 minutes
- [ ] Old refresh tokens are invalidated immediately
- [ ] Token rotation is atomic (no race conditions)
- [ ] Comprehensive test coverage for rotation edge cases

## Messages

**alice** (2024-01-16 09:00):
Implement refresh token rotation per the design doc. Priority is
correctness over performance.

**code-reviewer** (2024-01-16 14:30):
Started implementation. Created the RotateRefreshToken domain method
and working on the adapter layer.

## Artifacts

- PR #142: https://github.com/acme-corp/crm/pull/142
- Design doc: See conversation conv-20240115-auth
```

### 11.4 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Task title. |
| `status` | string | A2A-compatible status. See [11.5](#115-status-values). |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique task identifier. Defaults to filename. |
| `assignee` | object | Who is working on this task. See [11.6](#116-assignee-object). |
| `priority` | string | One of: `critical`, `high`, `medium`, `low`. |
| `tags` | string[] | Categorical tags. |
| `blocked_by` | string[] | IDs of tasks that block this one. |
| `blocks` | string[] | IDs of tasks that this one blocks. |
| `context_id` | string | A2A `contextId` for grouping related tasks. |
| `created` | string | ISO 8601 date when the task was created. |
| `updated` | string | ISO 8601 date when the task was last updated. |

### 11.5 Status Values

Task status values align with the A2A protocol:

| Status | Description |
|--------|-------------|
| `submitted` | Task has been created but not started. |
| `working` | Task is actively being worked on. |
| `input_required` | Task is blocked waiting for additional input. |
| `completed` | Task has been finished successfully. |
| `failed` | Task could not be completed. |
| `canceled` | Task was abandoned. |

### 11.6 Assignee Object

```yaml
assignee:
  type: user           # user | agent
  id: alice            # User ID or agent name
```

When `type` is `agent`, the `id` SHOULD reference an agent defined in the `agents/` directory.

### 11.7 Body Content

The task body SHOULD contain:

- **Description**: What needs to be done.
- **Acceptance Criteria**: How to verify completion (checklist recommended).
- **Messages**: A2A-compatible message log between participants.
- **Artifacts**: Links to deliverables (PRs, documents, deployments).

### 11.8 Loading Behavior

- **Tier 1**: Frontmatter scanned to build a task board (id, title, status, assignee, priority).
- **Tier 2**: Full task body loaded when working on a specific task.
- **Tier 3**: Referenced artifacts and linked conversations loaded on demand.

### 11.9 Mapping to Existing Standards

| `.project` | A2A Protocol | Claude Code | Linear/Jira |
|------------|-------------|------------|-------------|
| `tasks/` | Task objects | N/A | Issues/tickets |
| `status` | `Task.status` | N/A | Status field |
| `assignee` | `Task.assignee` | N/A | Assignee field |
| `messages` | `Task.messages[]` | N/A | Comments |
| `artifacts` | `Task.artifacts[]` | N/A | Attachments |
| `context_id` | `Task.contextId` | N/A | Sprint/epic |

---

## 12. Agents System

### 12.1 Purpose

The `agents/` directory defines AI agents with specific roles, capabilities, and constraints. Agent definitions describe what an agent does, what tools it can use, and what instructions it should follow.

Use agents for:
- Specialized roles (code reviewer, security auditor, documentation writer)
- Automated workflows (PR review, test generation)
- A2A-compatible agent definitions
- Team-specific AI configurations

This is analogous to:
- Claude Code's custom slash commands and agent configurations
- Cursor's agent mode configurations
- A2A Agent Cards

### 12.2 File Format

```markdown
---
name: code-reviewer
description: >
  Reviews code for quality, security, and convention adherence.
  USE WHEN reviewing PRs, before merging, or when code quality
  feedback is needed.
capabilities: [code-review, security-audit, style-check]
provider:
  preferred: anthropic
  model: claude-sonnet-4-6
permissions:
  read: ["server/**", "client/**", "tests/**"]
  write: []
  tools: [read_file, search, git_diff, git_log]
mcp_servers: [github, linear]
tags: [review, quality]
---

# Code Reviewer

You are an expert code reviewer for the Acme CRM project. Your reviews
focus on four areas:

## 1. Security

- Check for OWASP Top 10 vulnerabilities
- Verify input validation on all user-facing endpoints
- Ensure secrets are never hardcoded

## 2. Performance

- Flag N+1 query patterns
- Check for unbounded data loading
- Verify pagination on list endpoints

## 3. Conventions

- Verify hexagonal architecture boundaries
- Check that domain logic has no infrastructure imports
- Ensure error handling follows project conventions

## 4. Testing

- Verify test coverage for new code paths
- Check that tests are deterministic (no time-dependent assertions)
- Flag missing edge case tests

Always provide actionable feedback with suggested code corrections.
Never approve PRs with security issues, regardless of other factors.
```

### 12.3 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Agent identifier. |
| `description` | string | What this agent does AND when to invoke it. |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `capabilities` | string[] | What this agent can do (maps to A2A skills). |
| `provider` | object | Preferred AI provider and model. |
| `permissions` | object | File access and tool permissions. See [12.4](#124-permissions-object). |
| `mcp_servers` | string[] | MCP servers this agent requires. |
| `tags` | string[] | Categorical tags. |
| `instructions` | string[] | Names of instruction files to load for this agent. |

### 12.4 Permissions Object

```yaml
permissions:
  read: ["server/**", "client/**"]    # Glob patterns for readable files
  write: ["server/auth/**"]           # Glob patterns for writable files
  tools: [read_file, search, git_diff] # Allowed tool names
  deny_tools: [execute_command]        # Explicitly denied tools
```

Permissions are **advisory**. Implementors SHOULD enforce them but the specification acknowledges that enforcement capability varies across tools.

### 12.5 Body Content

The agent body contains the agent's **system instructions** --- the prompt content that defines the agent's behavior and personality. This is loaded as Tier 2 content when the agent is invoked.

### 12.6 Loading Behavior

- **Tier 1**: Frontmatter scanned at startup. The catalog tells the system (and user) what agents are available and when to use them.
- **Tier 2**: Full agent body loaded when the agent is invoked.
- **Tier 3**: Additional referenced files (templates, checklists, examples) loaded during agent execution.

### 12.7 Mapping to Existing Standards

| `.project` | A2A Protocol | Claude Code | Cursor |
|------------|-------------|------------|--------|
| Agent `name` | `AgentCard.name` | N/A | N/A |
| `description` | `AgentCard.description` | N/A | N/A |
| `capabilities` | `AgentCard.skills` | N/A | N/A |
| `permissions` | N/A | `.claude/settings.json` permissions | N/A |
| Body content | N/A | Custom instructions | Agent mode config |

---

## 13. Extensions System

### 13.1 Purpose

The `extensions/` directory provides a plugin system for adding reusable functionality to a `.project/` directory. Extensions can provide instructions, memory, agents, and validation rules that are packaged for sharing across projects.

Use extensions for:
- Compliance rules (SOC2, HIPAA, GDPR)
- Organization-wide coding standards
- Industry-specific patterns
- Shared agent definitions
- Custom validation and linting

### 13.2 Registry Configuration

The `index.md` file configures extension registries and lists installed extensions:

```markdown
---
name: extensions
description: Installed extensions and marketplace configuration.
registries:
  - id: public
    url: https://registry.projectstandard.dev/v1
  - id: company
    url: https://extensions.acme-corp.com/v1
    auth:
      type: bearer
      token_env: ACME_REGISTRY_TOKEN
---

# Extensions

## Installed

- **soc2-compliance** v1.2.0 --- SOC2 compliance rules and audit checks
- **acme-standards** v3.0.1 --- Acme Corp engineering standards
```

### 13.3 Extension Manifest

Each installed extension has a directory containing its own manifest:

```markdown
---
name: soc2-compliance
version: "1.2.0"
description: >
  SOC2 Type II compliance rules. Adds security-focused instructions,
  audit logging requirements, and access control validation.
author: Project Standard Community
license: Apache-2.0
provides:
  instructions: [security-baseline, audit-logging, access-control]
  agents: [security-auditor]
permissions:
  read: ["**"]
  write: []
  tools: [read_file, search]
---

# SOC2 Compliance Extension

This extension provides security-focused instructions and an automated
security auditor agent aligned with SOC2 Type II requirements.

## What It Adds

- **security-baseline**: Baseline security instructions for all code
- **audit-logging**: Requirements for audit log instrumentation
- **access-control**: Access control validation rules
- **security-auditor**: Agent that reviews code for SOC2 compliance
```

### 13.4 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Extension identifier (unique within registry). |
| `version` | string | Semver version string. |
| `description` | string | What this extension provides. |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `author` | string | Extension author or organization. |
| `license` | string | SPDX license identifier. |
| `provides` | object | What the extension contributes (instructions, agents, memory). |
| `permissions` | object | Permissions the extension requires. |
| `dependencies` | object | Other extensions this one depends on. |

### 13.5 Loading Behavior

- **Tier 1**: Extension manifests are scanned. The `provides` field tells the system what additional instructions and agents are available.
- **Tier 2**: Extension-provided instructions and agents are loaded using the same activation rules as project-level items.
- **Tier 3**: Extension resources loaded on demand.

Extension-provided items SHOULD have lower priority than project-level items, allowing projects to override extension defaults.

### 13.6 Mapping to Existing Standards

| `.project` | Claude Code | Codex | Cursor |
|------------|------------|-------|--------|
| `extensions/` | N/A | N/A | N/A |

The extensions system is a novel addition. No existing AI coding tool provides a structured extension mechanism.

---

## 14. Adapters System

### 14.1 Purpose

The `adapters/` directory contains provider-specific mapping files that describe how `.project/` content maps to native tool formats. Adapters enable bidirectional synchronization between `.project/` and provider-specific directories.

Use adapters when:
- The project needs to support multiple AI tools simultaneously
- Team members use different tools and need consistent configuration
- Automating the generation of provider-native config from `.project/`

### 14.2 File Format

```markdown
---
name: claude
provider: anthropic
tool: claude-code
mapping:
  instructions:
    output: "../.claude/rules/"
    transform: generate
  memory:
    output: "../CLAUDE.md"
    transform: append
    section: "## Memory"
  agents:
    output: "../.claude/agents/"
    transform: generate
sync: bidirectional
---

# Claude Code Adapter

This adapter maps .project/ content to Claude Code's native format.

## Mapping Details

### Instructions

Each `.project/instructions/<name>.md` generates a corresponding
`.claude/rules/<name>.md` file. The `applies_to` field maps to Claude's
`globs` field in the rule frontmatter.

### Memory

Memory entries are appended to the root `CLAUDE.md` file under a
`## Memory` section. Writable memory entries map to Claude's native
memory feature.

### Agents

Agent definitions generate `.claude/agents/<name>.md` files with
Claude-specific formatting for custom commands.
```

### 14.3 Frontmatter Fields

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Adapter identifier (typically the provider name). |
| `provider` | string | Provider identifier (e.g., `anthropic`, `openai`, `google`). |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `tool` | string | Specific tool within the provider (e.g., `claude-code`, `codex-cli`). |
| `mapping` | object | How each `.project/` system maps to native format. |
| `sync` | string | Sync direction: `generate` (`.project/` to native), `import` (native to `.project/`), `bidirectional`. Default: `generate`. |

### 14.4 Mapping Object

Each key in `mapping` corresponds to a `.project/` system directory:

```yaml
mapping:
  <system>:
    output: <path>         # Output path (relative to .project/)
    transform: <mode>      # generate | append | merge
    section: <string>      # For append mode: target section heading
    template: <path>       # Optional template for generation
```

### 14.5 Loading Behavior

Adapters are NOT loaded during normal AI sessions. They are configuration for tooling that synchronizes `.project/` with provider-native formats. Implementors MAY use adapter definitions to:

- Generate native configuration files from `.project/` content.
- Import native configuration into `.project/` format.
- Keep both formats synchronized on file changes.

### 14.6 Mapping to Existing Standards

| `.project` Adapter | Generates |
|-------------------|-----------|
| `claude.md` | `.claude/rules/`, `CLAUDE.md`, `.claude/agents/` |
| `codex.md` | `AGENTS.md` (Codex format) |
| `cursor.md` | `.cursor/rules/`, `.cursorrules` |
| `windsurf.md` | `.windsurf/rules/` |

---

## 15. Multi-User System

### 15.1 Purpose

The `users/` directory supports multi-user projects where different team members need different configurations, permissions, or preferences.

### 15.2 User Index

The `index.md` file defines roles and team configuration:

```markdown
---
name: users
description: Team member configuration and roles.
roles:
  admin:
    permissions: { read: ["**"], write: ["**"], manage: true }
  developer:
    permissions: { read: ["**"], write: ["server/**", "client/**"] }
  reviewer:
    permissions: { read: ["**"], write: [] }
default_role: developer
conflict_resolution: last-writer-wins
---

# Team Configuration

## Roles

- **admin**: Full access, can modify .project/ configuration
- **developer**: Read all, write to source directories
- **reviewer**: Read-only access for code review
```

### 15.3 Frontmatter Fields

#### Optional Fields (in `index.md`)

| Field | Type | Description |
|-------|------|-------------|
| `roles` | object | Role definitions with permissions. |
| `default_role` | string | Role assigned to unspecified users. |
| `conflict_resolution` | string | Strategy for concurrent edits: `last-writer-wins`, `merge`, `lock`. Default: `last-writer-wins`. |

### 15.4 Per-User Override Files

Individual users create `<username>.local.md` files for personal overrides:

```markdown
---
name: alice
role: admin
preferences:
  verbose: true
  auto_memory: true
custom_instructions: |
  I prefer detailed explanations with examples.
  Always show test output when running tests.
---

# Alice's Preferences

Personal notes and preferences that override team defaults.
```

Per-user files with the `.local.md` suffix MUST be listed in `.gitignore` (see [Section 20](#20-gitignore-conventions)). They are loaded only when the corresponding user is identified in the current session.

### 15.5 User Identification

This specification does not mandate a user identification mechanism. Implementors MAY identify the current user via:
- Environment variables (e.g., `USER`, `LOGNAME`)
- Git configuration (`git config user.name`)
- Provider-specific authentication
- Explicit session configuration

### 15.6 Loading Behavior

- **Tier 1**: `index.md` frontmatter loaded to understand roles and policies.
- **Tier 2**: Current user's `.local.md` file loaded at session startup.
- **Tier 3**: Not applicable.

---

## 16. Hierarchical Override

### 16.1 Purpose

`.project/` directories can nest within a repository to support monorepo structures. A child `.project/` directory inherits from and overrides its ancestors, providing scoped configuration for sub-projects.

### 16.2 Discovery

When an implementor starts a session, it MUST:

1. Search for a `.project/PROJECT.md` file starting from the current working directory.
2. Walk up the directory tree until a `.project/PROJECT.md` is found or the filesystem root is reached.
3. If the found `PROJECT.md` has `hierarchy.inherit: true`, continue walking up to discover parent `.project/` directories.

### 16.3 Configuration

Hierarchical behavior is configured in `PROJECT.md`:

```yaml
hierarchy:
  merge: nearest-wins     # Merge strategy
  inherit: true           # Whether to inherit from parent .project/
  max_depth: 3            # Maximum ancestor levels to traverse
```

### 16.4 Merge Strategies

| Strategy | Behavior |
|----------|----------|
| `nearest-wins` | Child values completely replace parent values for the same key. This is the default. |
| `deep-merge` | Child values are deep-merged with parent values. Arrays are concatenated; objects are merged recursively. |
| `replace` | Child `.project/` completely replaces parent. No inheritance. |

### 16.5 Merge Order

When multiple `.project/` directories are in scope, they are merged in order from most distant ancestor to nearest descendant. The nearest (most specific) `.project/` has the highest priority.

**Example**: In a monorepo with:

```
/repo/.project/PROJECT.md          # Root project
/repo/services/api/.project/PROJECT.md   # API sub-project
```

If the working directory is `/repo/services/api/`, the merge order is:
1. `/repo/.project/` (base)
2. `/repo/services/api/.project/` (override)

### 16.6 Per-System Merge Behavior

| System | Merge Behavior |
|--------|---------------|
| `instructions/` | Child instructions override parent instructions with the same `name`. New instructions are added. `index.md` from each level is loaded (child after parent). |
| `memory/` | Merged. Child entries with the same `name` override parent entries. |
| `conversations/` | Not merged. Each `.project/` has its own conversations. |
| `context/` | Merged. Child `auto_include` patterns override parent patterns. |
| `resources/` | Merged. Child entries with the same `name` override parent entries. |
| `tasks/` | Not merged. Tasks belong to their specific `.project/` level. |
| `agents/` | Merged. Child agents with the same `name` override parent definitions. |
| `extensions/` | Merged. Child extensions are added to parent extensions. |
| `adapters/` | Child adapters override parent adapters for the same provider. |

---

## 17. Security Model

### 17.1 Principles

The `.project/` security model follows these principles:

1. **No inline secrets**: Secrets MUST NEVER appear directly in `.project/` files.
2. **Environment variable references**: All credentials use environment variable indirection.
3. **Gitignore by convention**: Sensitive files follow naming patterns that are gitignored.
4. **Minimal permissions**: Extensions and agents declare required permissions explicitly.

### 17.2 Secret References

When a field requires a secret value (API tokens, passwords, keys), it MUST use an environment variable reference:

```yaml
auth:
  type: bearer
  token_env: CONFLUENCE_TOKEN    # References $CONFLUENCE_TOKEN
```

```yaml
auth:
  type: basic
  username_env: API_USER         # References $API_USER
  password_env: API_PASSWORD     # References $API_PASSWORD
```

```yaml
auth:
  type: header
  header: X-API-Key
  value_env: API_KEY             # References $API_KEY
```

The `_env` suffix convention indicates the field value is an environment variable name, not the secret itself. Implementors MUST resolve these by reading the named environment variable at runtime.

### 17.3 Auth Object

The `auth` object is used in memory, context, and extension registry configurations:

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Auth type: `bearer`, `basic`, `header`, `oauth2`. |
| `token_env` | string | Environment variable for bearer token. |
| `username_env` | string | Environment variable for username (basic auth). |
| `password_env` | string | Environment variable for password (basic auth). |
| `header` | string | Custom header name (header auth). |
| `value_env` | string | Environment variable for header value. |

### 17.4 File-Level Security

Files with these naming patterns MUST be treated as sensitive:

| Pattern | Purpose |
|---------|---------|
| `local.md` | Personal overrides |
| `*.local.md` | Per-user configurations |
| `*.secret.*` | Any file marked as secret |

These patterns MUST be included in `.gitignore` (see [Section 20](#20-gitignore-conventions)).

### 17.5 Extension Sandboxing

Extensions MUST declare their required permissions in their manifest frontmatter:

```yaml
permissions:
  read: ["server/**", "client/**"]
  write: []
  tools: [read_file, search]
```

Implementors SHOULD enforce extension permissions when the tool platform supports it. At minimum, implementors MUST present extension permissions to the user for review when installing extensions.

### 17.6 Validation Rules

Implementors SHOULD validate the following security invariants:

1. No frontmatter field contains a value that looks like a secret (high-entropy strings, known credential patterns).
2. Files matching sensitive patterns are listed in `.gitignore`.
3. Extension permissions do not exceed what the extension's `description` and `provides` fields justify.

---

## 18. Loading Protocol

This section defines the **normative algorithm** that implementors MUST follow when loading a `.project/` directory. This is the core interoperability contract of the specification.

### 18.1 Algorithm

```
PROCEDURE LoadProject(working_directory):

  // Phase 1: Discovery
  1. LET project_dirs = []
  2. LET dir = working_directory
  3. WHILE dir != filesystem_root:
       IF exists(dir + "/.project/PROJECT.md"):
         PREPEND dir + "/.project/" TO project_dirs
         LET manifest = parse_frontmatter(dir + "/.project/PROJECT.md")
         IF manifest.hierarchy.inherit != true:
           BREAK
       dir = parent(dir)
  4. IF project_dirs is empty:
       RETURN (no .project/ found; implementor MAY fall back to AGENTS.md)

  // Phase 2: Manifest Loading
  5. FOR EACH project_dir IN project_dirs (ancestor to descendant):
       LOAD full PROJECT.md (frontmatter + body)
       MERGE configuration using hierarchy.merge strategy

  // Phase 3: Catalog Building (Tier 1)
  6. FOR EACH system_directory IN [instructions, memory, conversations,
       context, resources, tasks, agents, extensions]:
       IF system_directory exists:
         IF index.md exists AND has catalog in frontmatter:
           USE frontmatter catalog entries
         ELSE:
           SCAN all *.md files in directory (including subdirectories)
           READ only frontmatter from each file
         BUILD catalog: [{name, description, ...metadata}] per item

  // Phase 4: Always-On Loading (Tier 2, immediate)
  7. IF instructions/index.md exists:
       LOAD full body
  8. FOR EACH item with activation: always:
       LOAD full body

  // Phase 5: Context Matching
  9. GIVEN current context (active files, user query, task):
       FOR EACH catalog entry:
         EVALUATE relevance:
           - Match description keywords against current context
           - Match applies_to patterns against active file paths
           - Match tags against current task/query
         IF relevant:
           ADD to activation set

  // Phase 6: Tier 2 Loading
  10. FOR EACH item IN activation set:
        LOAD full body (frontmatter + markdown content)
        TOTAL Tier 2 budget SHOULD stay under 50,000 tokens

  // Phase 7: AGENTS.md Reconciliation
  11. IF AGENTS.md exists at repository root:
        IF manifest.agents_md.fallback == true:
          LOAD AGENTS.md content as base-priority instructions
          (loaded AFTER all .project/instructions/, at lowest priority)

  // Phase 8: Resource Awareness
  12. LOAD resources/ Tier 1 catalog (frontmatter only)
      PRESENT resource names, descriptions, and summaries for awareness
      DO NOT fetch resource URLs

  // Phase 9: Session Lifecycle
  13. IF hooks/on-session-start.sh exists:
        EXECUTE hook script
```

### 18.2 Token Budgets

Implementors SHOULD respect the following token budget guidelines:

| Phase | Budget | Notes |
|-------|--------|-------|
| Tier 1 Catalog (all items) | < 5,000 tokens | ~50-100 tokens per item |
| PROJECT.md body | < 2,000 tokens | Loaded eagerly |
| `index.md` body | < 3,000 tokens | Loaded eagerly |
| Individual Tier 2 item | < 5,000 tokens | Per activated item |
| Total Tier 2 | < 50,000 tokens | All activated items combined |
| Tier 3 | Unbounded | Loaded on demand, user-approved |

These are guidelines, not hard limits. Implementors MAY adjust based on the context window size of the underlying model.

### 18.3 Caching

Implementors SHOULD cache Tier 1 catalogs for the duration of a session. Implementors MAY cache Tier 2 content. Cached content SHOULD be invalidated when the underlying file is modified (via filesystem watch or similar mechanism).

Remote content (Tier 3 URLs) MUST be cached according to the `refresh` policy specified in the file's frontmatter.

### 18.4 Error Handling

Implementors MUST handle the following error conditions gracefully:

| Condition | Required Behavior |
|-----------|-------------------|
| Missing `PROJECT.md` | Report that no `.project/` was found. MAY fall back to AGENTS.md. |
| Missing `spec` field | Treat as spec version `"1.0"`. SHOULD warn. |
| Malformed frontmatter | Skip the file. SHOULD warn. |
| Missing referenced file | Continue without the file. SHOULD warn. |
| Circular `blocked_by` in tasks | Detect and warn. Do not infinite loop. |
| File exceeds token budget | Truncate or skip. SHOULD warn. |

---

## 19. AGENTS.md Reconciliation

### 19.1 Background

[AGENTS.md](https://github.com/anthropics/agents-md) (Linux Foundation) is a cross-tool standard for coding agent instructions. It provides a single markdown file at the repository root with project instructions.

The `.project` standard is a superset of AGENTS.md --- it provides everything AGENTS.md does plus memory, conversations, context, resources, tasks, agents, extensions, and more. This section defines how the two coexist.

### 19.2 Relationship

`.project/` is **primary**. When a `.project/` directory is present, it is the authoritative source of project configuration. AGENTS.md serves two purposes:

1. **Pointer**: AGENTS.md can point tools to the `.project/` directory.
2. **Fallback**: AGENTS.md content can serve as base instructions for tools that do not support `.project/`.

### 19.3 Configuration

AGENTS.md reconciliation is configured in `PROJECT.md`:

```yaml
agents_md:
  pointer: true         # AGENTS.md should contain a pointer to .project/
  fallback: true        # Load AGENTS.md content as base instructions
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `pointer` | boolean | `true` | Whether AGENTS.md should point to `.project/`. |
| `fallback` | boolean | `true` | Whether to load AGENTS.md content as base instructions. |

### 19.4 Pointer Pattern

When `agents_md.pointer` is `true`, the AGENTS.md file SHOULD begin with a comment pointing to `.project/`:

```markdown
<!-- .project standard: https://github.com/anthropics/project-spec -->
<!-- Tools supporting .project/ should load from .project/ first -->
<!-- Content below is fallback for tools that only support AGENTS.md -->

# Project Instructions

This project uses the .project standard for AI configuration.
See the `.project/` directory for full project context including
instructions, memory, conversations, and more.

## Coding Standards

...fallback instruction content for non-.project tools...
```

### 19.5 Loading Order

When both `.project/` and AGENTS.md are present and `agents_md.fallback` is `true`:

1. Load all `.project/instructions/` per the Loading Protocol (Section 18).
2. Load AGENTS.md content as an instruction with implicit priority `-1` (lowest).
3. If any `.project/` instruction conflicts with AGENTS.md content, the `.project/` instruction wins.

When `agents_md.fallback` is `false`, AGENTS.md is ignored entirely during `.project/` loading.

### 19.6 Generation

Implementors MAY provide tooling to generate or update AGENTS.md from `.project/instructions/` content, ensuring the fallback content stays in sync with the primary instructions.

---

## 20. Gitignore Conventions

### 20.1 Required Patterns

A repository using `.project/` MUST include the following patterns in its `.gitignore` (or the `.project/` directory's own `.gitignore`):

```gitignore
# .project local and sensitive files
.project/local.md
.project/**/local.md
.project/**/*.local.md
.project/**/*.secret.*
.project/users/*.local.md
```

### 20.2 Recommended Patterns

The following patterns are RECOMMENDED:

```gitignore
# .project cached and generated content
.project/.cache/
.project/**/.cache/
```

### 20.3 Full Example

```gitignore
# === .project standard ===

# Personal overrides (never committed)
.project/local.md
.project/**/local.md
.project/**/*.local.md
.project/users/*.local.md

# Sensitive files
.project/**/*.secret.*

# Cache and generated files
.project/.cache/
.project/**/.cache/

# Provider-generated native configs (if using adapters)
# Uncomment if native configs are generated from .project/
# .claude/rules/
# .cursorrules
```

---

## 21. Versioning and Migration

### 21.1 Spec Version

The `spec` field in `PROJECT.md` frontmatter identifies the `.project` standard version:

```yaml
spec: "1.0"
```

The version string follows semantic versioning principles:
- **Major version** changes indicate breaking changes to the directory structure, required fields, or loading protocol.
- **Minor version** changes indicate backwards-compatible additions (new optional fields, new system directories).

### 21.2 Compatibility

Implementors MUST:
- Support the `spec` version they claim to implement.
- Gracefully handle `spec` versions they do not recognize (SHOULD warn, MUST NOT crash).
- Ignore unrecognized directories, files, and frontmatter fields (forward compatibility).

Implementors SHOULD:
- Support reading older `spec` versions when possible.
- Provide migration tooling when breaking changes occur.

### 21.3 Migration Path

When a new major version of the spec is released, the specification MUST include:
- A detailed list of breaking changes.
- A migration guide with before/after examples.
- Tooling recommendations for automated migration.

---

## Appendix A: Frontmatter Field Reference

This appendix provides a consolidated reference of all frontmatter fields defined by this specification. All fields not listed as REQUIRED are OPTIONAL. Additional fields not listed here are always permitted.

### A.1 Common Fields

These fields MAY appear in any `.project/` markdown file:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Item identifier. Defaults to filename without extension. |
| `description` | string | What this item is AND when to use it. |
| `tags` | string[] | Categorical tags for filtering and matching. |
| `activation` | string | `always`, `auto`, or `manual`. Default: `auto`. |

### A.2 PROJECT.md Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `spec` | string | REQUIRED | Standard version (e.g., `"1.0"`). |
| `name` | string | Recommended | Project name. |
| `description` | string | Recommended | Project description. |
| `id` | string | Optional | Reverse-domain identifier. |
| `version` | string | Optional | Project version. |
| `license` | string | Optional | SPDX license identifier. |
| `repository` | object | Optional | Repository metadata. |
| `providers` | object | Optional | Provider preferences. |
| `agents_md` | object | Optional | AGENTS.md reconciliation. |
| `hierarchy` | object | Optional | Hierarchical override config. |
| `conversations` | object | Optional | Conversation config. |

### A.3 Instruction Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | REQUIRED | Coverage description and usage triggers. |
| `name` | string | Optional | Identifier. |
| `applies_to` | string[] | Optional | File glob patterns that trigger activation. |
| `priority` | integer | Optional | Loading priority (higher = later). Default: `0`. |
| `activation` | string | Optional | `always`, `auto`, `manual`. Default: `auto`. |
| `tags` | string[] | Optional | Categorical tags. |

### A.4 Memory Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | REQUIRED | Knowledge description and consultation triggers. |
| `name` | string | Optional | Identifier. |
| `tags` | string[] | Optional | Categorical tags. |
| `writable` | boolean | Optional | AI can append entries. Default: `false`. |
| `type` | string | Optional | `url` for external sources. |
| `url` | string | Optional | External source URL. |
| `auth` | object | Optional | Authentication config. |
| `refresh` | string | Optional | Cache policy: `session`, `daily`, `weekly`, `manual`. |

### A.5 Conversation Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | REQUIRED | Conversation title. |
| `summary` | string | REQUIRED | Summary of discussion and decisions. |
| `id` | string | Optional | Unique identifier. |
| `date` | string | Optional | ISO 8601 date or datetime. |
| `participants` | string[] | Optional | User identifiers. |
| `provider` | string | Optional | AI provider used. |
| `model` | string | Optional | Model identifier. |
| `tags` | string[] | Optional | Categorical tags. |
| `format` | string | Optional | Body format: `markdown`, `jsonl`, `provider-native`. |

### A.6 Context Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | REQUIRED | What this content is and when to load it. |
| `name` | string | Optional | Identifier. |
| `file` | string | Optional | Companion file path (for metadata files). |
| `mime_type` | string | Optional | MIME type of content. |
| `type` | string | Optional | `url` for remote content. |
| `url` | string | Optional | Remote content URL. |
| `auth` | object | Optional | Authentication config. |
| `refresh` | string | Optional | Cache policy. |

### A.7 Context Index Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `auto_include.patterns` | string[] | Optional | Glob patterns to auto-include from repo. |
| `auto_include.exclude` | string[] | Optional | Glob patterns to exclude. |
| `auto_include.max_file_size` | string | Optional | Max file size. Default: `1MB`. |

### A.8 Resource Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | REQUIRED | What this resource is. |
| `name` | string | Optional | Identifier. |
| `url` | string | Optional | Resource URL. |
| `type` | string | Optional | Resource category. |
| `tags` | string[] | Optional | Categorical tags. |

### A.9 Task Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | REQUIRED | Task title. |
| `status` | string | REQUIRED | A2A status value. |
| `id` | string | Optional | Unique identifier. |
| `assignee` | object | Optional | `{type, id}` assignment. |
| `priority` | string | Optional | `critical`, `high`, `medium`, `low`. |
| `tags` | string[] | Optional | Categorical tags. |
| `blocked_by` | string[] | Optional | Blocking task IDs. |
| `blocks` | string[] | Optional | Blocked task IDs. |
| `context_id` | string | Optional | A2A context grouping ID. |
| `created` | string | Optional | ISO 8601 creation date. |
| `updated` | string | Optional | ISO 8601 last update date. |

### A.10 Agent Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | REQUIRED | Agent identifier. |
| `description` | string | REQUIRED | Agent purpose and invocation triggers. |
| `capabilities` | string[] | Optional | Agent capabilities (A2A skills). |
| `provider` | object | Optional | Preferred provider and model. |
| `permissions` | object | Optional | File and tool permissions. |
| `mcp_servers` | string[] | Optional | Required MCP servers. |
| `tags` | string[] | Optional | Categorical tags. |
| `instructions` | string[] | Optional | Instruction files to load. |

### A.11 Extension Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | REQUIRED | Extension identifier. |
| `version` | string | REQUIRED | Semver version. |
| `description` | string | REQUIRED | What the extension provides. |
| `author` | string | Optional | Author or organization. |
| `license` | string | Optional | SPDX license. |
| `provides` | object | Optional | What the extension contributes. |
| `permissions` | object | Optional | Required permissions. |
| `dependencies` | object | Optional | Extension dependencies. |

### A.12 Adapter Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | REQUIRED | Adapter identifier. |
| `provider` | string | REQUIRED | Provider identifier. |
| `tool` | string | Optional | Specific tool name. |
| `mapping` | object | Optional | System-to-native mapping config. |
| `sync` | string | Optional | Sync direction. Default: `generate`. |

---

## Appendix B: Mapping to Existing Standards

This appendix provides a comprehensive mapping between `.project/` and existing AI tool configuration formats.

### B.1 Claude Code (Anthropic)

| `.project/` | Claude Code Equivalent |
|------------|----------------------|
| `PROJECT.md` | `.claude/settings.json` + root `CLAUDE.md` |
| `instructions/index.md` | Root `CLAUDE.md` |
| `instructions/<topic>.md` | `.claude/rules/<topic>.md` |
| `instructions/local.md` | `.claude/settings.local.json` |
| `instructions.applies_to` | `.claude/rules/*.md` `globs` field |
| `memory/` | Facts section of `CLAUDE.md` |
| `agents/<agent>.md` | `.claude/agents/<agent>.md` |
| `conversations/` | Claude Projects history |
| `context/` | Claude Projects uploaded files |

### B.2 OpenAI Codex

| `.project/` | Codex Equivalent |
|------------|-----------------|
| `PROJECT.md` | Root `AGENTS.md` header |
| `instructions/index.md` | Root `AGENTS.md` body |
| `instructions/<topic>.md` | Subdirectory `AGENTS.md` |
| `instructions.applies_to` | Directory-scoped `AGENTS.md` |

### B.3 Cursor

| `.project/` | Cursor Equivalent |
|------------|------------------|
| `PROJECT.md` | `.cursor/config.json` |
| `instructions/index.md` | `.cursorrules` |
| `instructions/<topic>.md` | `.cursor/rules/<topic>.mdc` |
| `instructions.applies_to` | `.cursor/rules/*.mdc` `globs` field |
| `context/` | `@docs`, `@files` |
| `memory/` | `@memories` |

### B.4 AGENTS.md (Linux Foundation)

| `.project/` | AGENTS.md Equivalent |
|------------|---------------------|
| `PROJECT.md` | Top-level `AGENTS.md` metadata |
| `instructions/index.md` | Root `AGENTS.md` body |
| `instructions/<topic>.md` | Subdirectory `AGENTS.md` files |
| `instructions.applies_to` | Directory scoping |

### B.5 A2A Protocol (Google)

| `.project/` | A2A Equivalent |
|------------|---------------|
| `agents/<agent>.md` | Agent Card |
| `agents.capabilities` | `AgentCard.skills` |
| `agents.description` | `AgentCard.description` |
| `tasks/<task>.md` | Task object |
| `tasks.status` | `Task.status` |
| `tasks.assignee` | `Task.assignee` |
| Task messages (body) | `Task.messages[]` |
| Task artifacts (body) | `Task.artifacts[]` |
| `tasks.context_id` | `Task.contextId` |

---

*This specification is maintained at [https://github.com/anthropics/project-spec](https://github.com/anthropics/project-spec). Contributions and feedback are welcome via GitHub Issues and Pull Requests.*
