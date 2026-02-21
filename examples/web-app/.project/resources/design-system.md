---
name: design-system
description: >
  Figma design system containing UI components, color tokens, typography
  scales, and layout patterns. Reference when building or modifying frontend
  components to ensure consistency with design specifications.
url: https://figma.com/file/abc123/TaskFlow-Design-System
type: design
tags: [frontend, design, figma]
---

# Design System

## Summary

The TaskFlow design system is maintained in Figma and serves as the source of
truth for all UI decisions. It contains component specifications, color
palettes, typography scales, spacing tokens, and responsive layout patterns.

## How to Work With It

- **Component mapping:** Figma components correspond to React components in
  `src/client/src/components/ui/`. Names match between Figma and code
  (e.g., "Button/Primary" maps to `Button` with `variant="primary"`).
- **Design tokens:** Exported from Figma to `src/client/src/styles/tokens.css`
  as CSS custom properties. Run `npm run sync-tokens` to pull latest values.
- **Adding new components:** Check the Figma library first for an existing
  design before creating a new component. If no design exists, coordinate
  with Bob Martinez (frontend lead) before implementing.
- **Spacing and sizing:** All spacing uses a 4px base unit. Reference the
  spacing scale in the design system's "Foundations" page.
- **Accessibility:** The design system includes contrast-checked color
  combinations. Use the documented pairings to maintain WCAG AA compliance.
