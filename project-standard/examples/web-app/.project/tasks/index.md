---
name: tasks
description: >
  Task tracking for the TaskFlow project. Tasks are managed in external
  systems — GitHub Issues for public work items and ATS for agent-driven
  task orchestration.
systems:
  - name: github-issues
    type: github
    url: https://github.com/difflabai/protocols/issues
  - name: ats
    type: ats
    url: https://ats.example.com
    actor:
      type: agent
      id: claude-code
      name: Claude Code
---

# Task Tracking

This project tracks tasks in two external systems.

## GitHub Issues

Public work items, bugs, and feature requests are tracked in
[GitHub Issues](https://github.com/difflabai/protocols/issues).

## ATS

Agent-driven task orchestration uses ATS. The Claude Code agent
is configured as the default actor for automated task workflows.
