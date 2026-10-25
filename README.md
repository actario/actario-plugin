# Actario plugins

This repository serves **Actario** plugins for Claude Code and Codex. The
Codex package includes the local capture skill and needs Node.js 20 or newer.

Actario captures AI conversations, redacts them on the user's computer, and
distils them into decisions, facts, and open questions. The OpenAI plugin
connects ChatGPT and Codex to saved Actario sessions through the hosted MCP
server. Capturing a conversation still requires the Actario CLI/plugin on a
computer.

## Install in Codex

Add this repository as a plugin marketplace, then install Actario:

```sh
codex plugin marketplace add actario/actario-plugin --sparse .agents/plugins --sparse plugins/actario-codex
codex plugin add actario@actario-plugins
```

Connect your Actario account when prompted. The plugin uses OAuth with
`https://actario.app/api/mcp` and runs the local CLI MCP server for capture;
it does not store your Actario password or API token in the package.

## Install in Claude Code

```sh
/plugin marketplace add actario/actario-plugin
/plugin install actario@actario
```

Then link the computer to Actario:

```text
link my machine to Actario
```

The Claude plugin runs `npx -y @actario/cli mcp`, so it requires Node 20 or
newer. Full Claude plugin documentation:
[`plugins/actario/README.md`](plugins/actario/README.md).

## Repository layout

```text
.claude-plugin/marketplace.json     Claude marketplace
plugins/actario/                    Claude plugin
.agents/plugins/marketplace.json   Codex marketplace
plugins/actario-codex/              Codex desktop plugin with local capture
plugins/actario-openai/             remote MCP package for OpenAI submission
```

The ChatGPT submission ZIP is generated separately from the Actario app
repository with `npm run pack:chatgpt` and submitted through the OpenAI plugin
review process.

## Licence

Apache-2.0 — see [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). `@actario/cli`
is Apache-2.0 as well.
