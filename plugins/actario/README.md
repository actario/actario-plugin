# Actario

Capture your AI conversations into Actario: redacted on your own machine,
distilled into decisions, facts and open questions, and held as **pending**
until you confirm them.

## What you get

- **A skill** — say "save this conversation to Actario" in any chat and Claude
  writes a faithful record, uploads it, then distils it into entries anchored
  to the turns they came from.
- **Six tools**, served by a program on your own machine:

  | tool | what it does |
  |---|---|
  | `link` | point this machine at your workspace (once) |
  | `capture` | scan, redact, score, pack, upload |
  | `list_runs` | what is in a captured batch — no content |
  | `read_run` | one conversation's turns |
  | `submit_daf` | validate an analysis and file it as pending |
  | `doctor` | which sources this machine has, and whether they parse |

## Why it runs on your machine

Your conversations are redacted **before anything leaves the machine**, by
rules no flag can switch off. That guarantee only means something if the
redaction happens where the data already is. So the server is a local program:
it reads your session files, redacts, scores, and uploads — and nothing
unredacted crosses the network.

It also means the tools work from a cloud session (Cowork) that could not
otherwise see your files or reach your API.

## Requirements

- **Node 20 or newer on your PATH.** The MCP server is
  `npx -y @actario/cli mcp`; with no Node the plugin installs cleanly and then
  has no tools, which looks like a broken plugin rather than a missing
  runtime. Check with `node --version`.
- **A workspace and a capture token**, from the web app's Settings page.

Nothing else. The CLI is fetched from npm on first run; there is no checkout
to clone and no path to configure.

## Setup

1. Install the plugin.
2. In any chat: **"link my machine to Actario"**, and give the API URL and
   token when asked. This validates the token before writing anything, and
   registers this machine as a source under its hostname.
3. Check it: **"run Actario's doctor"**.

If the tools do not appear straight away, the MCP server is announced but not
yet read; asking the client to refresh its tool list picks them up.

## Using it

> save this conversation to Actario

writes the record and uploads it.

> save and analyse this conversation

also reads the captured runs back, writes an analysis, and files it.

Everything filed is **pending**. Open the Inbox in the web app and confirm or
reject each claim against the source turns shown underneath it — that decision
is the only thing that lets a claim be given to another agent.

## What it will not do

- **Redact selectively.** Redaction is unconditional and happens in the
  pipeline, not in the skill. There is no "skip redaction" option here.
- **Confirm anything.** Nothing this plugin writes is trusted; a human
  confirms it in the Inbox.
- **Read your workspace.** These tools feed Actario. Reading back what is in
  it — other agents' decisions, context bundles — is a separate, read-only
  server.

## Where your data lives locally

Config, upload state and the pseudonym salt live in `~/.actario`
(`ACTARIO_HOME` overrides it). The salt never leaves the machine, and neither
does the pseudonym map: `actario unmask` reverses an export locally, which is
the only way it can be reversed at all.

## Licence

Apache-2.0. See `LICENSE`.
