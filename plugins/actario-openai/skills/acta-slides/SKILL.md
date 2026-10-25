---
name: acta-slides
description: "Get an Actario slide deck (.pptx) to download: of one saved session's note page, or of a whole line of work, assembled by Actario from the note pages. Use when asked for slides, a deck, a presentation, a 簡報 or a PPT of an Actario session, note page or line of work."
---

# A slide deck from Actario

Here, Actario **assembles** the deck from the note pages (no model writes
it). A deck written for an audience by an agent, or one overall deck from
several sessions, is made on a computer with the Actario plugin
(`acta-slides` there).

## Steps

1. What is the deck about?
   - One session: the link the user gave, or find it with `find_runs` /
     `search` / `overview`.
   - A line of work: its name.
2. `export_file(what: "session", run)` for one session, or
   `export_file(what: "line", line)` for a whole line. For a session,
   `format: "md"` gives the note page as Markdown instead of PowerPoint.
3. Give the user the `download` link as a plain link and say it works for
   15 minutes; ask again for a new one after that. Never put the link inside
   another link or an image, and never send it anywhere but to the user.

## When it does not work

- "no note page yet": that session has not been summarised; a deck of its
  whole line may still work.
- Several sessions at once, or a deck written for a particular audience: say
  it needs the Actario plugin on a computer.
- If a tool says a limit is reached or something is not included, tell the
  user just that and that the details are on actario.app; never mention plans
  or prices.
