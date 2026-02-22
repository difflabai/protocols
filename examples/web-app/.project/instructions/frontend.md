---
name: frontend
description: >
  React frontend conventions for the client application. Covers component
  patterns, state management, styling, and API integration.
  USE WHEN working on src/client/**, or any .tsx/.ts files.
applies_to: ["src/client/**", "**/*.tsx"]
priority: 100
activation: auto
tags: [frontend, react, typescript]
---

# Frontend Development Standards

## Component Patterns

- Use functional components with hooks exclusively. No class components.
- Colocate component files: `ComponentName/index.tsx`, `ComponentName.test.tsx`,
  `ComponentName.module.css`.
- Keep components small and focused. Extract logic into custom hooks.
- Use `React.memo` only when profiling shows a measurable performance benefit.

## State Management

- **Server state**: Use TanStack Query (React Query) for all API data.
  Define query keys in `src/client/src/api/queryKeys.ts`.
- **Local state**: Use `useState` for component-scoped state. Lift state only
  when two siblings need the same data.
- **Global client state**: Use React Context sparingly, only for truly global
  concerns (theme, auth session). Avoid using Context as a state manager.

## Styling

- Use CSS Modules for component-scoped styles.
- Design tokens are defined in `src/client/src/styles/tokens.css` and imported
  as CSS custom properties.
- Follow the design system spacing scale: 4px base unit (0.25rem increments).
- Responsive breakpoints: `sm: 640px`, `md: 768px`, `lg: 1024px`, `xl: 1280px`.

## API Integration

- All API calls go through the generated client in `src/client/src/api/client.ts`.
- Use TanStack Query mutations for write operations.
- Handle loading, error, and empty states in every data-fetching component.

## Build and Lint

```bash
npm run dev          # Start dev server
npm run build        # Production build
npm run lint         # ESLint
npm run typecheck    # TypeScript type checking
```
