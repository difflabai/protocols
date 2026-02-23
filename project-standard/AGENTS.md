<!-- .project standard: https://protocols.difflab.ai -->
<!-- Tools supporting .project/ should load from .project/ first -->
<!-- Content below is fallback for tools that only support AGENTS.md -->

# .project Standard — Loading Protocol

This repository uses the **`.project` standard** for AI project configuration.
The `.project/` directory is the authoritative source. Load from it using the
protocol below.

## Quick Start

Only `PROJECT.md` is required. Everything else is optional — scan what exists.

## Progressive Loading (3 tiers)

### Tier 1 — Catalog (session startup, ~50-100 tokens/item)

Read **only YAML frontmatter** (`name` + `description`) from every `.md` file
in each subdirectory. This builds a lightweight catalog for relevance matching
without loading full content.

Directories to scan:

| Directory | Contains |
|-----------|----------|
| `instructions/` | Coding standards, conventions, guidelines |
| `memory/` | Persistent facts, decisions, entity data |
| `conversations/` | Archived chat history |
| `context/` | Files and URLs to pull into sessions |
| `resources/` | External references (dashboards, deploys) — Tier 1 only |
| `tasks/` | A2A-compatible task tracking |
| `agents/` | Specialized agent definitions |
| `skills/` | Invocable commands and workflows |

### Tier 2 — Full Content (on relevance match, <5K tokens/item)

When a catalog entry's `description` or `tags` match the current context (active
files, user query, task), load its full markdown body.

**Always load immediately:**
- `PROJECT.md` (full manifest)
- `instructions/index.md` (base instructions)
- Any item with `activation: always` in frontmatter

**Budget:** Total Tier 2 content should stay under ~50K tokens.

### Tier 3 — External References (on demand, unbounded)

Linked files, scripts, and remote URLs referenced in Tier 2 content. Load only
when explicitly needed during execution.

## Loading Procedure

```
1. DISCOVER  Walk up from CWD looking for .project/PROJECT.md
             (also check .aiproject/ for Eclipse compatibility)
2. MANIFEST  Load PROJECT.md — project identity, config, provider settings
3. CATALOG   Scan each subdirectory, read frontmatter only → build catalog
4. EAGER     Load instructions/index.md + all activation:always items
5. MATCH     Evaluate catalog descriptions against current context
6. ACTIVATE  Load matched items' full body content
7. FALLBACK  If agents_md.fallback is true, load AGENTS.md at lowest priority
```

## Key Conventions

- **Frontmatter** = structured YAML metadata (name, description, tags, config)
- **Body** = free-form markdown content (instructions, knowledge, prompts)
- **`index.md`** in any directory = always-loaded base content for that system
- **`local.md`** = personal overrides, gitignored
- **`applies_to`** field = glob patterns scoping an instruction to specific files
- Skills live in `skills/<name>/index.md` — map to provider SKILL.md format
- Agents live in `agents/<name>.md` — map to provider agent definitions

## Provider Adapter Scripts

Symlink scripts that map `.project/` to provider-native paths:

```
project-standard/scripts/adapt-claude.sh   →  CLAUDE.md, .claude/rules/, .claude/agents/, .claude/skills/
project-standard/scripts/adapt-codex.sh    →  AGENTS.md, .agents/skills/
project-standard/scripts/adapt-gemini.sh   →  GEMINI.md, .gemini/skills/
```

Each script also has a `.ps1` PowerShell equivalent for native Windows support.
Run with `--clean` (bash) or `-Clean` (PowerShell) to remove symlinks.

## Specification

Full spec: `project-standard/spec/v1/specification.md`
Website: https://protocols.difflab.ai
