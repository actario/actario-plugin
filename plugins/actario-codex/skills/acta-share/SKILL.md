---
name: acta-share
description: "Share a conversation (session) or a memory saved in Actario with other people as a masked link, list the user's shares, revoke one, or copy a shared conversation into the user's own workspace. Use when asked to share, send, give someone access to, or make a link for an Actario session, note or memory; to see or stop sharing ('who did I share this with', 'revoke that link'); or to copy a shared conversation. Opening a share link someone sent is acta-restore."
---

# Share from Actario

Shares made here are **masked**: pseudonyms stay pseudonyms. A share that
shows real values can only be made on the computer that captured the
session, with the Actario plugin.

## Make a share — only when the user asked

1. Find what to share: a session (`find_runs`, `search`, or the link the
   user gave) or a memory (`list_memories`).
2. The audience is **the user's choice, never yours**. If they have not said,
   ask: anyone signed in with the link (`link`), their organization (`org`),
   or named people by email (`users` with `recipients`). Permissions default
   to view and restore; add `fork` only if they ask. Expiry defaults to 30
   days unless they give one.
3. `create_share`. Give the user the `url` and the three lines in
   `tell_the_user` (masked; recipients sign in to Actario; revoking stops new
   opens but cannot take back copies; when it expires).

## See and stop sharing

- `list_shares` (optionally for one session): what, to whom, opens, expiry.
- `revoke_share(share)` when the user asks. Say that copies already
  downloaded cannot be taken back.

## Copy a shared conversation

`fork_share(url)` copies a share that allows fork into the user's workspace,
masked. Only when they ask.

## Rules

- If the share tools answer `forbidden`, this connection is for reading
  only: say sharing is not available here, and that the user can share the
  session from actario.app.
- If a tool says a limit is reached or something is not included, tell the
  user just that and that the details are on actario.app; never mention plans
  or prices.
