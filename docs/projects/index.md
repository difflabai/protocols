---
sidebar_position: 1
---

# The `.project` Standard

A vendor-neutral directory structure for AI project context. Works across Claude, Codex, Cursor, Windsurf, Gemini, and any tool that supports the standard.

**Status:** v1.0.0-draft

## What It Does

`.project/` gives AI tools structured access to your project's instructions, memory, conversations, files, tasks, agents, and more — in a single, portable format that lives in your git repo.

Think of it as **Claude Projects meets AGENTS.md**, but vendor-neutral and extensible.

## Quick Start

Create a `.project/PROJECT.md` file in your repo:

```markdown
---
spec: "1.0"
name: "My Application"
description: >
  A web application for managing customer relationships.
  Built with Go backend and React frontend.
---

# My Application

Overview of the project for humans and AI alike.
```

That's it. One file makes a valid `.project/` directory. If your repo already uses a `.project` file (e.g., Eclipse), use `.aiproject/` instead — the spec supports both names.

Add more as needed:

```
.project/
  PROJECT.md              # Required — project manifest
  instructions/           # How to work on this project
  memory/                 # Persistent knowledge (decisions, patterns)
  conversations/          # Conversation history
  context/                # Files for AI context (docs, specs)
  resources/              # External links (dashboards, deployments)
  tasks/                  # A2A-compatible task management
  agents/                 # Agent definitions
  skills/                 # Invocable commands and workflows
  extensions/             # Structural additions
```

## Design Principles

**Markdown-first.** Every file is markdown with YAML frontmatter. No JSON or YAML files required. Humans write markdown; tools parse frontmatter.

**Progressive disclosure.** Following the [agentskills.io](https://agentskills.io) pattern, every item has lightweight metadata (name + description) scanned at startup, with full content loaded only when relevant. This keeps context windows efficient.

**Context vs resources.** `context/` holds files that get loaded into AI context. `resources/` holds external links (deployments, dashboards, design systems) with summaries — they exist for awareness, not fetching.

**Flexible over strict.** JSON schemas are optional tooling aids. Extra frontmatter fields are always allowed. Body content is free-form.

## AGENTS.md Reconciliation

`.project/` is the primary source. If your repo also has an AGENTS.md file, it should point to `.project/` for tools that support the standard, with fallback instructions for tools that only read AGENTS.md. Instructions from `.project/` load first; AGENTS.md content merges as base-priority.

## Resources

- [Full Specification](specification) — the complete standard
- [Example Project](https://github.com/difflabai/protocols/tree/main/examples/web-app/.project) — a working example
- [JSON Schemas](https://github.com/difflabai/protocols/tree/main/schemas/v1) — optional frontmatter validation

## Related Standards

- [AGENTS.md](https://agents.md/) — Cross-tool coding agent instructions (Linux Foundation)
- [Agent Skills](https://agentskills.io/) — Portable skill packaging standard
- [A2A Protocol](https://a2a-protocol.org/) — Agent-to-agent communication (Google/Linux Foundation)
- [MCP](https://modelcontextprotocol.io/) — Model Context Protocol for tool integration (Anthropic)
