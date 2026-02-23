---
name: users
description: >
  User registry and role definitions. Consult when checking permissions,
  understanding team roles, or configuring per-user overrides.
roles:
  lead:
    permissions: { read: ["**"], write: ["**"], manage: true }
  engineer:
    permissions: { read: ["**"], write: ["server/**", "client/**"] }
  reviewer:
    permissions: { read: ["**"], write: [] }
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
