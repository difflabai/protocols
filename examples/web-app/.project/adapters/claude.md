---
name: claude
description: >
  Adapter mapping .project/ conventions to Claude Code native format.
  Used by tooling to synchronize between .project/ and .claude/ directories.
provider: anthropic
tool: claude-code
mapping:
  instructions:
    output: "../.claude/rules/"
    transform: generate
  agents:
    output: "../.claude/agents/"
    transform: generate
  memory:
    output: "../CLAUDE.md"
    transform: generate
sync: bidirectional
---

# Claude Adapter

This adapter describes how `.project/` content maps to Claude Code's native
conventions.

## Mapping Details

| .project/ source | Claude Code target | Notes |
|------------------|--------------------|-------|
| `instructions/index.md` | `.claude/rules/index.md` | Body content copied as rule file |
| `instructions/*.md` | `.claude/rules/*.md` | Each instruction becomes a rule |
| `agents/*.md` | `.claude/agents/*.md` | Agent definitions mapped directly |
| `memory/*.md` | `CLAUDE.md` | Memory entries appended to project CLAUDE.md |

## Synchronization

When `sync: bidirectional` is set, changes made in `.claude/` conventions can
be synced back to `.project/`. The adapter tooling handles conflict resolution
using the strategy defined in `PROJECT.md` hierarchy settings.

## Usage

Adapter synchronization is run via tooling commands, not automatically. Teams
that use Claude Code alongside other providers can run the sync to keep both
formats current.
