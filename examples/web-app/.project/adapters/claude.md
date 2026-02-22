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
  skills:
    output: "../.claude/skills/"
    transform: generate
  marketplace:
    output: "../.claude/marketplace.json"
    transform: generate
  plugins:
    output: "../.claude/plugins/"
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
| `extensions/*/skills/*/index.md` | `.claude/skills/*/SKILL.md` | Skill prompt mapped to SKILL.md |
| `extensions/index.md` registries | `.claude/marketplace.json` | Registry entries become marketplace config |
| `extensions/*/index.md` | `.claude/plugins/*/` | Extension manifests become plugins |

## Skills

Extension-provided skills map to `.claude/skills/<name>/SKILL.md`. The skill
body (prompt) becomes the SKILL.md content. Supporting files in the skill
directory are copied alongside.

## Marketplace

Extension registries in `extensions/index.md` map to entries in
`.claude/marketplace.json`. Each registry becomes a marketplace source
that Claude Code can use to discover and install skills and plugins.

## Plugins

Extensions that provide instructions, agents, or hooks map to
`.claude/plugins/<name>/` with a `.claude-plugin/plugin.json` manifest
generated from the extension frontmatter.

## Synchronization

When `sync: bidirectional` is set, changes made in `.claude/` conventions can
be synced back to `.project/`. The adapter tooling handles conflict resolution
using the strategy defined in `PROJECT.md` hierarchy settings.

## Usage

Adapter synchronization is run via tooling commands, not automatically. Teams
that use Claude Code alongside other providers can run the sync to keep both
formats current.
