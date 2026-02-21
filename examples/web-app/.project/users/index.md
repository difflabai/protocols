---
name: users
description: >
  User registry and role definitions. Consult when checking permissions,
  understanding team roles, or configuring per-user overrides.
roles:
  lead:
    description: Technical lead with full project configuration access.
    permissions: [read, write, configure, approve]
  engineer:
    description: Team member with standard development access.
    permissions: [read, write]
  reviewer:
    description: Code reviewer with read access and review capabilities.
    permissions: [read, review]
conflict_resolution: last-writer-wins
---

# Users

This directory manages user configuration for the TaskFlow project. Roles
define permission levels for project configuration changes. Per-user overrides
can be stored in `*.local.md` files (gitignored).

## Registered Users

| User | Role | Notes |
|------|------|-------|
| alice | lead | Tech lead, backend architect |
| bob | engineer | Frontend lead |
| carol | engineer | Full stack, security champion |
| david | engineer | Junior engineer |

## Per-User Overrides

Individual users can create `<username>.local.md` files in this directory to
store personal preferences (e.g., preferred editor settings, custom instruction
overrides). These files are gitignored and not shared with the team.
