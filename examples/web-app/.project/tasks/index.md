---
name: tasks
description: >
  Task board for tracking work items. Tasks follow A2A-compatible status
  values. Browse to see current work in progress, blocked items, and
  completed work.
---

# Task Board

This directory tracks work items for the TaskFlow project. Tasks use
A2A-compatible status values: `working`, `completed`, `failed`, `canceled`,
and `input_required`.

## Structure

- **active/** -- Tasks currently in progress or awaiting input.
- **completed/** -- Finished tasks kept for historical reference.

## Current Status

| Task | Title | Status | Assignee |
|------|-------|--------|----------|
| task-001 | Implement refresh token rotation | working | carol |
| task-000 | Set up project infrastructure | completed | alice |
