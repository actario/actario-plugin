# Actario plugin marketplace

The Claude Code marketplace that serves the **Actario** plugin.

Actario captures your AI conversations, redacts them on your own machine, and
distils them into decisions, facts and open questions that stay **pending**
until you confirm them.

## Install

In Claude Code:

```
/plugin marketplace add actario/actario-plugin
/plugin install actario@actario
```

Then, in any chat:

```
link my machine to Actario
```

and give the API URL and capture token from your workspace's Settings page.
Verify with **"run Actario's doctor"**.

Full plugin documentation: [`plugins/actario/README.md`](plugins/actario/README.md).

## Requirements

**Node 20 or newer on your PATH.** The plugin's MCP server is
`npx -y @actario/cli mcp`. Without Node the plugin installs cleanly and then
serves no tools — which reads as a broken plugin rather than a missing
runtime. Check with `node --version` before filing anything.

## What is actually in this repository

Three config files and a skill. That is the whole plugin:

```
.claude-plugin/marketplace.json     this catalogue
plugins/actario/
  .claude-plugin/plugin.json        the plugin manifest
  .mcp.json                         npx -y @actario/cli mcp
  skills/actario-capture-chat/      the skill that drives the tools
  README.md
```

The program the plugin launches is [`@actario/cli`](https://www.npmjs.com/package/@actario/cli),
published separately on npm and fetched on first run. The Actario web
application, backend and database are not part of this repository.

## Updating

Claude Code refreshes marketplaces shortly after a session starts and updates
installed plugins in place; `/reload-plugins` activates a new version in the
current session. Updates are pinned to the `version` field in
`plugins/actario/.claude-plugin/plugin.json`, so a change only reaches
installed users when that field is bumped.

To force a refresh:

```
/plugin marketplace update actario
```

Note that `@actario/cli` is *not* pinned — `.mcp.json` says `npx -y @actario/cli`,
so every run picks up the latest published CLI regardless of the plugin
version.

## Desktop app

Claude Code's `/plugin` command is the documented path for adding a
marketplace. The Claude desktop app has a plugin browser for installing from
marketplaces that are already configured; the documentation does not describe
adding a marketplace from that UI.

## Licence

Apache-2.0 — see [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE). `@actario/cli`
is Apache-2.0 as well.
