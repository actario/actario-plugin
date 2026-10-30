# Actario plugins

This repository serves **Actario** plugins for Claude desktop, Claude Code
and Codex, and the one-line installers that bring their own Node — nothing to
install first.

## Install (no Node needed)

- **Claude desktop:** download `actario-win-x64.plugin`,
  `actario-mac-arm64.plugin` or `actario-mac-x64.plugin` from the
  [latest release](https://github.com/actario/actario-plugin/releases/latest)
  and upload it on the plugins page.
- **Claude Code, Codex, ChatGPT desktop (Codex mode):** in a terminal

  ```sh
  curl -fsSL https://actario.app/install.sh | sh      # macOS, Linux
  ```

  ```powershell
  irm https://actario.app/install.ps1 | iex           # Windows PowerShell
  ```

  The installer ([`install.sh`](install.sh), [`install.ps1`](install.ps1))
  downloads `actario-runtime-<platform>` from the latest release, checks it
  against `SHA256SUMS.txt`, unpacks it into `~/.actario-app`, and installs the
  plugin into Claude Code and Codex from a local marketplace there. Run it
  again to update.

Actario captures AI conversations, redacts them on the user's computer, and
distils them into decisions, facts, and open questions. The OpenAI plugin
connects ChatGPT and Codex to saved Actario sessions through the hosted MCP
server. Capturing a conversation still requires the Actario CLI/plugin on a
computer.

## Install from this marketplace (needs Node 20+)

### Codex

Add this repository as a plugin marketplace, then install Actario:

```sh
codex plugin marketplace add actario/actario-plugin --sparse .agents/plugins --sparse plugins/actario-codex
codex plugin add actario@actario-plugins
```

Connect your Actario account when prompted. The plugin uses OAuth with
`https://actario.app/api/mcp` and runs the local CLI MCP server for capture;
it does not store your Actario password or API token in the package.

### Claude Code

```sh
/plugin marketplace add actario/actario-plugin
/plugin install actario@actario
```

Then link the computer to Actario:

```text
link my machine to Actario
```

Installed this way the Claude plugin runs `npx -y @actario/cli mcp`, so it
requires Node 20 or newer. Full Claude plugin documentation:
[`plugins/actario/README.md`](plugins/actario/README.md).

## Repository layout

```text
install.sh, install.ps1             one-line installers (no Node needed)
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
