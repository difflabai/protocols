# Protocols

Open standards and protocols for AI development, supported by [Differential AI Lab](https://difflab.ai).

**Live site**: https://protocols.difflab.ai

## Standards

### [The `.project` Standard](spec/v1/specification.md)

A vendor-neutral directory structure for AI project context. Works across Claude, Codex, Cursor, Windsurf, Gemini, and any tool that supports the standard.

- [Full Specification](spec/v1/specification.md)
- [Example Project](examples/web-app/.project/)
- [JSON Schemas](schemas/v1/) (optional validation)

## Development

```bash
npm install
npm start
```

The site is built with [Docusaurus](https://docusaurus.io/) and deployed to GitHub Pages automatically on push to `main`.
