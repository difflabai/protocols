# Protocols

Open standards and protocols for AI development, supported by [Differential AI Lab](https://difflab.ai).

**Live site**: https://protocols.difflab.ai

## Standards

### [The `.project` Standard](project-standard/spec/v1/specification.md)

A vendor-neutral directory structure for AI project context. Works across Claude, Codex, Cursor, Windsurf, Gemini, and any tool that supports the standard. (`.aiproject/` is supported as an alternative name for repos where `.project` conflicts with existing tooling.)

- [Full Specification](project-standard/spec/v1/specification.md)
- [Example Project](project-standard/examples/web-app/.project/)
- [JSON Schemas](project-standard/schemas/v1/) (optional validation)

## Development

```bash
npm install
npm start
```

The site is built with [Docusaurus](https://docusaurus.io/) and deployed to GitHub Pages automatically on push to `main`.
