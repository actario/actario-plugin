# Actario for ChatGPT and Codex

Actario connects ChatGPT to the user's saved sessions through the hosted
OAuth-protected MCP server. The bundled skills cover saved work, memory,
reports, decks, masked shares, end-of-day review, current-chat capture limits,
and agent-message limits.

The ChatGPT package uses only the hosted MCP server and cannot capture the
current conversation. The Codex desktop package adds the local Actario CLI MCP
server and the acta-capture-chat skill. Neither package reads files that the
user has not asked Actario to capture.

## Install from a Codex marketplace

The Codex desktop package in `actario/actario-plugin` includes local capture.
Add that repository as a plugin marketplace, then install Actario.
The CLI equivalent is:

```sh
codex plugin marketplace add actario/actario-plugin --sparse .agents/plugins --sparse plugins/actario-codex
codex plugin add actario@actario-plugins
```

To try this checkout before publishing the marketplace package, build the
Codex-local package first, then add the app repository marketplace:

```sh
npm run pack:codex
codex plugin marketplace add .
codex plugin add actario@actario-dev
```

After installing, connect the Actario account when prompted. The MCP server
uses OAuth; no Actario password or API token is stored in this package.

## Test in ChatGPT

For a personal test, add `https://actario.app/api/mcp` as a custom MCP server
in ChatGPT and complete the Actario sign-in/approval flow. For public
distribution, submit the generated `actario-chatgpt-<version>.zip` through the
OpenAI Plugins Directory review process.

## Build the package

From the Actario application repository:

```sh
npm run pack:chatgpt
```

This creates `_publish/actario-chatgpt/` and
`actario-chatgpt-<version>.zip` for ChatGPT. For Codex desktop, run
`npm run pack:codex`; it creates `_publish/actario-codex/` with the local CLI
server and capture skill. The marketplace publishing build copies both
packages into the Actario plugin repository.
