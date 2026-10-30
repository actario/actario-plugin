# Actario

Capture your AI conversations into Actario: redacted on your own machine,
uploaded as a faithful record, and summarised topic by topic by your own
agent.

## What you get

- **A skill** — say "save this conversation to Actario" in any chat and Claude
  writes a faithful record, uploads it, then cuts it into topic segments —
  each with a short summary anchored to the turns it covers — and writes it
  up as a **note page**: a progress summary of the whole session that leads
  with the conclusion (where it stopped, what is done, what is left), then
  each stage in one line, with its short bullet points and details a click
  away; debugging and trial-and-error are condensed to their outcome. Editable on the web,
  exportable as Markdown, every section linked back to the conversation.
  Both are written by your own agent, on your own subscription, from the
  redacted record.
- **Bringing conversations back** (0.1.7) — in a new chat, say "continue the
  LOPO conversation from Actario": Claude finds the run, downloads it to your
  machine, and starts from its note page, segments and latest turns, reading
  any stretch of the original when it needs to. Or "make me a memory of the
  B1 work this month": Claude downloads those runs and compacts them **here,
  with your own model**, into one memory — goal, status, what is left,
  conventions, files and commands — every line linked back to the turns it
  came from. It stays on your machine unless you ask to upload it.
- **Runs stay on their line** (0.1.8) — a chat in a Cowork / claude.ai
  Project is captured under that project's line, and a restored conversation
  that is captured again is offered the line it came from, so it shows up on
  the Acta page instead of the unbound queue.
- **Restore report** (0.2.9) — after bringing a conversation back, the
  agent answers in a few lines and writes the full report (where it stopped,
  done, not finished, the last four rounds verbatim, what was not brought
  back) as a Markdown file shown beside the chat.

  What comes back is the conversation, not the computer: file contents and
  diffs, attachments, tool output past 8 KB and the real values behind
  pseudonyms were never uploaded, so they are not restored.
- **Sharing** (0.1.9) — "share this conversation with Mei" or "make a link
  to the B1 memory for the team": a link `…/s/<token>` that people sign in to
  open, see on the web, or bring into their own chat. Masked by default, 30
  days, revocable, with a list of who opened it. Real values only when you
  ask, only to your organization or named people, and only from the machine
  that captured it: the content is encrypted there, and the key travels in the
  link's `#k=` part, which no server sees. Keys, tokens and the terms you list
  in `redaction_terms` are never shown. Organization admins can limit sharing.
- **Agent messages** (0.2, preview) — "tell the frontend agent the response
  shape changed" or "ask my desktop session to run the tests": one of your
  agents sends a note, request, command or handoff to another of your agents
  — another line of work, on this or another of your computers. Keys,
  tokens and your `redaction_terms` are masked on the sending computer;
  since 0.2.8 (CLI 0.2.7) Actario then keeps the message, encrypted with its
  own key, and **can read it**: you see and answer your messages on the web
  (Messages), and any computer linked to your account sends and reads, with
  no keys to approve. Messages from before then stay end-to-end encrypted
  and open only where they were sealed for. A command is never carried out
  without you approving it on the receiving side. Two commands:
  `/acta-send test-b 收到請回 pong` sends (add `request`, `command` or
  `handoff` after the line for another kind), and `/acta-inbox` lists this
  line's unread messages, numbered — then "open 2", "reply 2: …",
  "approve 2"; `/acta-inbox out` shows what this line sent and where each one
  is. In Claude Code, a new session starts with one line saying how many
  messages are waiting (counts only). Preview: your own agents only; your organisation and
  friends come later.

  Since 0.2.11 (CLI 0.2.8): **a message line is an Acta line** — the same
  list; a line that sends for the first time gets its Acta line (when your
  plan has room), and **renaming the line on Acta renames its address**, with
  the old name still delivered to it. **One conversation is one thread**:
  `send_message` takes the `thread` it continues (an agent keeps it for the
  conversation) and, without it, joins the latest thread between the same two
  lines from the last 12 hours; `new_thread` starts another. On the web you
  can now **start a conversation** between any two of your lines, ask a
  question or give a command, and write on a thread **as either side**.
  Since 0.2.12 (CLI 0.2.9) each message also carries the **title of the
  conversation that sent it** — the name the app shows for that chat, read
  from the session on your computer, nothing for the agent to fill in — and
  the web shows that title instead of the bare line name (the line is still
  the address).
- **ChatGPT and Codex** (0.2.11) — Actario also has a **hosted MCP server for
  ChatGPT**: `https://actario.app/api/mcp`, signed in with your Actario
  account (OAuth; nothing to paste). In ChatGPT it reads what you saved —
  overview, find and search, bring a session back, memories, shares, weekly
  reports, and download links for decks and reports — but it **cannot capture
  the ChatGPT conversation itself**: capturing still happens on a computer,
  through this plugin or the CLI. For a personal test, add that URL as a
  custom MCP server (connector) in ChatGPT; the ChatGPT app listing is in
  review. Codex desktop installs from the same marketplace
  (`codex plugin add actario@actario-plugins`) and adds local capture through
  the CLI. Nothing changes for Claude: this plugin still runs the CLI on your
  machine.
- **Search and slides** (0.2.5) — "which chat did we decide the autumn prices
  in?" searches your note pages, summaries and conversations (never tool
  output). "make a deck of the B1 work for my manager" has your agent write
  the story and renders a .pptx on your machine (`~/.actario/decks/`); the
  web's **Export PowerPoint** gives the note page as it is, for comparison.
- **Thirty-two tools**, served by a program on your own machine:

  | tool | what it does |
  |---|---|
  | `link` / `link_status` | sign in and link this machine to your workspace (once) |
  | `capture` | scan, redact, score, pack, upload |
  | `list_runs` | what is in a captured batch — no content |
  | `read_run` | one conversation's turns |
  | `submit_daf` | validate the topic summaries, note page and tags, redact them, upload them |
  | `suggest_line` | rank your lines against a conversation's tags, so it is filed on the right one |
  | `doctor` | which sources this machine has, and whether they parse |
  | `find_runs` | find your uploaded conversations by title, line or date — no content |
  | `search` | search note pages, summaries and conversation text — never tool output |
  | `make_deck` | render a slide deck your agent wrote to a .pptx on this machine |
  | `fetch_run` | bring one back into this chat |
  | `read_restored` | read part of it (real values only on the machine that captured it, on request) |
  | `fetch_memory_sources` | download the conversations a memory is built from |
  | `save_memory` | check a memory and save it (upload only if you ask) |
  | `load_memory` | load a memory saved earlier |
  | `create_share` / `list_shares` / `revoke_share` | share a conversation or memory, see your shares, stop one |
  | `open_share` | bring back something shared with you |
  | `fork_share` | copy a shared conversation into your workspace |
  | `message_identity` | your agent address and your lines of work |
  | `send_message` / `reply` | send a note, request, command or handoff to another of your agents; answer one |
  | `inbox` / `read_message` | what your other agents sent you; open one |
  | `set_message_state` / `message_status` | accept, decline, finish a message; follow one you sent |

## Which AI account is using it

Linking binds **this computer** to your Actario account. That alone would let
any Claude account on the computer act as you, so there is a second binding:
each AI account connects itself (OAuth, through the Actario connector), and
the plugin answers only a conversation that carries a pass from a connected
account — one bound to the same Actario account and workspace as the
computer. Switch to another Claude account and nothing answers it until that
account is connected too. Disconnecting an account stops its passes within a minute.

**One computer, several people.** If A and B take turns on the same
computer, each links it once to their own Actario account (`link`, browser
sign-in). Each gets a home of their own on the computer (the first in
`~/.actario`, the others in `~/.actario/profiles/`): their own token, salt,
redaction map, inbox, restored conversations and memories. Every call goes
to the home of the person whose Claude account issued the pass, so A's work
lands in A's workspace and B's in B's, and neither can reverse the other's
pseudonyms through the plugin. On such a computer `capture` takes only the
conversation at hand (`record`): the session folders on disk belong to the
computer's login, not to either person. This separates two people's data in
normal use; it is not a wall between two people who share one OS login —
separate OS accounts are that.

The connector also works on its own where the plugin cannot run (claude.ai on
the web, a phone): it finds and brings back conversations, loads memories and
manages masked shares. Capturing, real values and sealed shares stay on the
computer.

## Why it runs on your machine

Your conversations are redacted **before anything leaves the machine**, by
rules no flag can switch off. That guarantee only means something if the
redaction happens where the data already is. So the server is a local program:
it reads your session files, redacts, scores, and uploads — and nothing
unredacted crosses the network.

It also means the tools work from a cloud session (Cowork) that could not
otherwise see your files or reach your API.

## Requirements

- **An Actario account.** Linking signs you in through the browser; no token to copy.

Nothing else, if you install it one of these ways (2026-10-31) — each brings
its own Node:

- **Claude desktop:** download `actario-<your platform>.plugin` from
  <https://actario.app/docs> (or the latest release of this repository) and
  upload it on the plugins page.
- **Claude Code, Codex:** run the installer, which also installs the plugin
  into them:
  - macOS / Linux: `curl -fsSL https://actario.app/install.sh | sh`
  - Windows (PowerShell): `irm https://actario.app/install.ps1 | iex`

Installed straight from this marketplace (`/plugin install actario@actario`)
the server is `npx -y @actario/cli mcp`, which needs **Node 20 or newer on
your PATH**; without it the plugin installs cleanly and then has no tools.

## Setup

1. Install the plugin.
2. In any chat: **"link my machine to Actario"**. A browser tab opens: sign in,
   check the code, pick a workspace, approve. On a machine without a browser
   Claude shows a URL and a code to approve from any device. The machine is
   registered as a source under its hostname.
3. **Connect this AI account.** The plugin brings its connector with it: a
   server named `actario-account` appears in your connector list, waiting to
   be connected (Cowork / Claude desktop: the connectors menu in the chat box,
   or Settings → Connectors; Claude Code: `/mcp`). Press **Connect**
   (**Authenticate** in Claude Code), sign in to Actario and approve.
   **Do this once in every AI account you use**: the plugin on your computer
   answers only an account that has been connected, and checks it is
   connected to the same Actario account as the computer. Connected accounts
   are listed, and can be disconnected, under *Connected AI accounts* on the
   web.
   Where plugins do not reach (claude.ai in a browser), add it by hand as a
   custom connector with the URL `https://actario.app/api/mcp`
   (Settings → Connectors → Add custom connector).
   **No way to add a connector?** (an organization that does not let members
   add custom connectors, for instance.) If your Actario account has been
   allowed *local keys*, make one under *Connected AI accounts* on the web
   and save it on this computer — `actario key set` in a terminal, or paste it
   into a chat and ask Claude to save your Actario local key. The plugin then
   answers without the connector, for **any** AI account on this computer, so
   make one per computer and revoke it on the web when you stop using it.
4. Check it: **"run Actario's doctor"**.

If the tools do not appear straight away, the MCP server is announced but not
yet read; asking the client to refresh its tool list picks them up.

## Using it

> save this conversation to Actario

writes the record and uploads it.

> save and analyse this conversation

also reads the captured runs back, writes an analysis, and files it.

> continue the conversation about the LOPO split

(in a new chat) brings it back and tells you where it stopped.

> build a memory of the B1 work since September

downloads those conversations and compacts them on your machine.

> share this conversation with mei@example.com

makes a masked link only she can open (after signing in).

> tell the frontend agent the /runs response now has turns_count

sends it, encrypted, to your `frontend` line; that session sees it in its inbox.

Everything filed is **pending**. Open the Inbox in the web app and confirm or
reject each claim against the source turns shown underneath it — that decision
is the only thing that lets a claim be given to another agent.

## What it will not do

- **Redact selectively.** Redaction is unconditional and happens in the
  pipeline, not in the skill. There is no "skip redaction" option here.
  You can only add to it: words listed under `redaction_terms` in
  `~/.actario/config.json` (a client's name, a project codename; 3+
  characters each) are always replaced, like keys and tokens, and never
  shown again — not even in a share. Your home folder's account name in
  paths (`/Users/<name>`, `/home/<name>` and the Windows equivalent) is
  replaced too.
- **Confirm anything.** Nothing this plugin writes is trusted; a human
  confirms it in the Inbox.
- **Choose who sees your work.** Who a share goes to, and whether it shows
  real values, is asked of you each time — never assumed.
- **Let a message run itself.** A message from another agent is shown to you
  as that agent's words; a command waits for your approval. Who may send you
  commands is not something a tool can change.
- **Let an agent read your workspace.** Bringing a conversation back is done
  for you, with your own token. Agents reading other agents' work — decisions,
  context bundles — use a separate, read-only server with their own grants.

## Where your data lives locally

Config, upload state and the pseudonym salt live in `~/.actario`
(`ACTARIO_HOME` overrides it). Conversations brought back are under
`~/.actario/restore/`, memories under `~/.actario/memory/` — masked, as
uploaded; real values shown on request are never written there. A share
someone sends you is kept in its own folder (`restore/share-…`, or
`memory/shared-…`); one that shows real values holds them, as decrypted.
A computer that used agent messages before 0.2.8 keeps its old message key
in `~/.actario/keys/` (readable by your OS account only), only to open those
old end-to-end messages; new messages need no key. The salt never leaves the machine, and neither
does the pseudonym map: `actario unmask` reverses an export locally, which is
the only way it can be reversed at all.

## Licence

Apache-2.0. See `LICENSE`.
