# Actario

Capture your AI conversations into Actario: redacted on your own machine,
uploaded as a faithful record, and summarised topic by topic by your own
agent.

## What you get

- **A skill** — say "save this conversation to Actario" in any chat and Claude
  writes a faithful record, uploads it, then cuts it into topic segments —
  each with a short summary anchored to the turns it covers — and writes it
  up as a **note page**: a progress summary of the whole session (goal, what
  was done stage by stage, where it stopped, what is left), with debugging
  and trial-and-error condensed to their outcome. Editable on the web,
  exportable as Markdown, every section linked back to the conversation.
  Both are written by your own agent, on your own subscription, from the
  redacted record.
- **Six tools**, served by a program on your own machine:

  | tool | what it does |
  |---|---|
  | `link` | sign in and link this machine to your workspace (once) |
  | `capture` | scan, redact, score, pack, upload |
  | `list_runs` | what is in a captured batch — no content |
  | `read_run` | one conversation's turns |
  | `submit_daf` | validate the topic summaries and note page, redact them, upload them |
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
- **An Actario account.** Linking signs you in through the browser; no token to copy.

Nothing else. The CLI is fetched from npm on first run; there is no checkout
to clone and no path to configure.

## Setup

1. Install the plugin.
2. In any chat: **"link my machine to Actario"**. A browser tab opens: sign in,
   check the code, pick a workspace, approve. On a machine without a browser
   Claude shows a URL and a code to approve from any device. The machine is
   registered as a source under its hostname.
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
