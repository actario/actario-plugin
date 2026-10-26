---
name: acta-send
description: "Send a message from this line of work to another of the user's own AI agents through Actario: a note, a question, a task (command) or a handoff of a shared conversation, to another line, computer or client. The user types /acta-send, optionally followed by the line to send to, the kind and the message. Use when asked to send, tell, ask, notify, hand off to, or give a task to another of the user's agents, lines or sessions (傳訊息給、告訴、通知、問一下、交給、派給另一條線). Reading what came in, and following what was sent, is acta-inbox."
---

# Send to another agent (Actario, preview)

The user's agents — other lines of work, on this or another of their
computers, in Claude Code, Cowork or the desktop app — pass each other notes,
questions, tasks and handoffs through Actario. This skill sends. Checking
what came in, replying, approving a command and following what was sent is
**`acta-inbox`**.

An address is `<handle>/<line>` (`message_identity` shows the handle). **This
preview only connects the user's own agents**; anyone else is refused
(`tier_not_allowed`).

Actario keeps messages encrypted with its own key and **can read them**: the
user sees and answers them on the web (Messages), and so can the platform's
superuser. Keys, tokens and the user's `redaction_terms` are masked on this
computer before a message leaves. Say this once if the user seems to expect
end-to-end secrecy; not every time.

## What the user types

```
/acta-send                                  -> ask who and what
/acta-send test-b 收到請回 pong              -> a note to test-b
/acta-send test-b request 你那邊 API 改到哪了？
/acta-send test-b command 跑 npm test 回報結果
/acta-send test-b handoff                   -> pass a shared conversation (see below)
/acta-send as test-a test-b ...             -> send as line test-a (sets this conversation's line)
```

- **Recipient** — the first word: a line name (`frontend`) or a full address
  (`commonuse3483/frontend`).
- **Kind** — optional second word: `note` (default), `request` (asks, expects
  a reply), `command` (asks for work, expects a result; the other side asks
  its user first), `handoff`. Chinese works too: 問／請問 = request,
  指令／去做 = command, 交接 = handoff.
- **Message** — the rest. Markdown is fine; at most about 60 KB (bigger
  things go as a handoff).
- Plain sentences work as well ("tell the frontend line the response type
  changed"): pull the same three parts out of them.

**Nothing after `/acta-send`**: call `message_identity`, then ask in one
question who it goes to — offer the lines that already have an address
(`agents`) plus "another line" — and what to say. Do not ask about the kind
unless it is unclear.

**No kind given, but the message plainly asks the other side to do work**
("run the tests", "fix X"): ask once whether to send it as a command, so the
other side asks its user before doing anything. A question ending in "?" is a
`request` without asking.

## This conversation's line (`from`)

The sender is this line of work: the same name captures of this conversation
go to (`acta-capture-chat` field rules). Settle it **once per conversation**:

1. `as <line>` in the command, or the user naming it ("I'm test-a"), wins.
2. Otherwise the project this session is attached to, if any.
3. Otherwise the repository or folder this session works in.
4. Otherwise ask once, offering the lines from `message_identity`.

Then keep it for the rest of the conversation, and use the same name as
`agent` if `acta-inbox` runs later in it. Say the line in your report so the
user can correct it.

## Sending

Only send what the user asked to send — never add files, secrets or context
they did not ask for. Call `send_message`:

| field | |
|---|---|
| `from` | this conversation's line (above) |
| `to` | the recipient |
| `kind` | note / request / command / handoff |
| `subject` | one line you write from the message (under ~60 characters) unless the user gave one |
| `body` | the message as the user meant it |
| `capabilities` | command only: what doing it needs over there — `read`, `run_tests`, `edit`, `vcs_local` (commit, no push), `external` (push, release, send, delete, outside calls). Pick the least that covers the task |
| `thread` | the `thread_id` of this conversation's earlier message (below) |

**One conversation, one thread.** Keep the `thread_id` that `send_message`,
`reply` or `read_message` returns, and pass it as `thread` on every later
message of this conversation, to whichever line — the user then sees one
conversation on the web, not a new one per message. Without it Actario still
joins the latest thread between the same two lines from the last 12 hours.
Pass `new_thread: true` only when the user starts a different subject
("另開一串", "new topic"). (CLI 0.2.8 and later; an older one ignores both.)

A **handoff** passes a share link: make it first with `create_share` (the
`acta-share` skill), then send it as `share_url` with a line on what it is.

If `masked` comes back, tell the user what was replaced. If the recipient line
is not among `message_identity`'s `agents`, it has never received a message:
send anyway, and mention it in case the name is mistyped.

## Report

One or two lines, in the user's language:

> 已從 **test-a** 傳 command 給 **test-b**：「跑 npm test 回報結果」（能力：run_tests）。
> 追蹤用 `/acta-inbox out`；對方會先問它的使用者才執行。

Do not show the message id unless asked.

## The pass

Every tool takes a `pass`: call `local_pass` on the Actario connector once
per conversation and pass it to every call. On a computer where the user saved
an Actario local key, leave `pass` out. When the connector is missing or the
pass is refused, follow `acta-share`. Sending needs a connection that is
allowed to capture.

## Errors

| code | say |
|---|---|
| `tier_not_allowed` | this preview only connects the user's own agents |
| `messages_unavailable` | messages are not set up on this Actario server yet; try later |
