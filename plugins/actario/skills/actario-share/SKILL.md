---
name: actario-share
description: "Share a conversation (run) or a memory saved in Actario with other people, list or revoke the user's shares, or copy a shared conversation into the user's own workspace. Use when asked to share, send, give someone access to, or make a link for an Actario conversation, note or memory; to see or stop sharing ('who did I share this with', 'revoke that link'); or to fork/copy a shared conversation. Opening a share link someone sent is the actario-restore skill."
---

# Share from Actario

A share is a link, `https://<host>/s/<token>`, to one conversation (its turns,
topic segments and note page) or one version of a memory. Recipients must sign
in to Actario. By default it is **masked** (pseudonyms such as `EMAIL-3F2A91`
stay), lasts **30 days**, and lets them **view** it and **restore** it into
their own chat. Revoking stops it from opening again.

## Who it goes to, and whether real values show: the user decides, every time

Never choose these yourself, and never carry them over from an earlier share.
If the user has not said, ask in one short question before calling anything:

1. **Audience**
   | audience | who can open it |
   |---|---|
   | `link` | anyone signed in to Actario who has the link |
   | `org` | members of the user's organization |
   | `users` | the people named by email (`recipients`) |
2. **Real values** (`reveal`) — default no. Only when the user explicitly asks
   to show the real values. Then:
   - it can only go to `org` or `users`, never `link`;
   - it must be created on **the machine that captured the conversation**
     (it needs that machine's redaction map); elsewhere `create_share` says so;
   - keys, tokens, card numbers and the user's `redaction_terms` stay masked
     even then;
   - the content is encrypted on this machine; the key is the `#k=` part of
     the link, which never reaches the server. **The link is the key.**

Options only when the user asks: `permissions` (`view`, `restore`, `fork` —
fork lets them copy it into their own workspace; masked conversations only),
`expires_in_days` (1–90), `web_view: false` (real-value shares: restorable
with the plugin, not readable in a browser). An organization admin may have
limited sharing to the organization or turned it off; the tool then refuses
and says why — tell the user, do not look for a way around it.

## Tools (`actario` MCP server, plugin 0.1.9, `@actario/cli` 0.1.5 or later)

| tool | use |
|---|---|
| `create_share` | make the link: `run` (id, URL or hash) or `pack_id` (an uploaded memory) |
| `list_shares` | the user's shares: audience, opens, restores, forks, expiry, status |
| `revoke_share` | stop one (`share` = its id) |
| `fork_share` | copy a shared conversation (that allows fork) into the user's workspace |
| `open_share` | open a link someone sent — see `actario-restore` |

If these are missing, the installed CLI is older than 0.1.5: say so and stop.
On `not_linked`, call `link` with no arguments (browser sign-in).

A memory that was only saved locally has to be uploaded first
(`save_memory` with `upload: true`) — ask before uploading.

## The pass: this Claude account must be bound to Actario

Every tool of the `actario` server except `link`, `link_status`, `doctor` and
`set_local_key` takes a `pass`. Get it first, once per conversation: call `local_pass` on the
**Actario connector** (the remote `actario-account` server) and give its
`pass` value to every call. Do not show it to the user, put it in a record,
or write it anywhere.

- **No Actario connector in this session — try a local key first.** Some
  accounts are allowed local keys: a key saved on this computer opens the
  plugin without the connector. Call the tool once **without** `pass`. If it
  answers normally, carry on without `pass` for the rest of the conversation.
  If it answers `pass_required`, no local key is saved here — go on to the
  next point. If it answers `local_key_invalid`, the saved key no longer
  works (revoked, or the account was taken off the allowlist): say so in one
  line, then go on to the next point.
- **The user pastes a local key** (`actario_lkey_…`) and asks you to save it:
  call `set_local_key` with it exactly as pasted, then carry on without
  `pass`. Never save a key the user did not give you in this conversation,
  never repeat it back, and do not bring local keys up with a user who has
  not — they exist only for accounts a platform admin allowed.
- **No Actario connector in this session** (and no local key): this Claude account has not been
  bound to Actario yet. The plugin brings the connector with it (a server
  named `actario-account`), so there is no URL to type: tell the user, in
  their language, to open the connector list (Cowork / Claude desktop: the
  connectors menu in the chat box, or Settings → Connectors; Claude Code:
  `/mcp`), find **actario-account**, press **Connect** (Claude Code:
  **Authenticate**), sign in to Actario and approve. That is done once per AI
  account, not per conversation. Only if it is not in the list (claude.ai in
  a browser, or a client that does not load plugin connectors) do they add it
  by hand, as a custom connector with the URL `<server>/api/mcp` — the
  `pass_required` error carries the exact URL. Stop there; once connected, a
  new chat (or a refreshed tool list) picks up its tools.
- **`pass_invalid`**: get a new pass from `local_pass` and retry once. If it
  fails again, the connector and this computer are bound to different
  Actario accounts or workspaces — say which (the connector's `whoami`, this
  machine's `doctor`) and stop.
- **A different person on the same computer.** One computer can be linked to
  several Actario accounts; each gets a home of its own, and the pass decides
  which one a call uses, so each person's work goes to their own workspace.
  If `pass_invalid` says this machine is not linked to the account of this
  conversation's Claude account, ask the user whether they are someone other
  than the person linked here; if so, `link` (no arguments, browser sign-in
  as them) adds their home and leaves the others' untouched.

## Report back

In the user's language, short:

1. The link, once, in its own line — exactly as returned (with `#k=…` if
   present). Do not repeat it, summarise it, or write it to a file.
2. One line: what it is, who can open it, masked or real values, expiry date.
3. The `tell_the_user` lines, condensed. Always include: **revoking cannot take
   back copies already downloaded**. For real values add: **the whole link is
   the key — send it only to the people it is for**.
4. For real values, the counts: `values_shown` reversed, `values_still_masked`
   left as pseudonyms (keys and listed terms, or values captured on another
   machine).

For `list_shares`, a short table: title · audience · status · opens/restores ·
expires. For `revoke_share`, one line, plus that downloaded copies stay.
