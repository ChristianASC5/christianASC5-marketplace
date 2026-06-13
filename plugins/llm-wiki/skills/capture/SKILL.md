---
name: capture
description: This skill should be used when the user wants to "capture what we decided", "update the wiki from this session", "save what we learned", "file this decision", "add this pattern to the wiki", "document this gotcha", or at the end of a session where decisions were made, implementation patterns were established, or domain knowledge was clarified. Extracts wiki-worthy knowledge from the current conversation and persists it to the appropriate wiki pages.
version: 0.1.0
---

# capture

Extract and persist knowledge from the current session into the wiki. Use this when a conversation has produced something worth keeping — a decision, a pattern, a gotcha, a clarification — that would otherwise be lost when the session ends.

This is distinct from `ingest`, which processes source documents from `wiki/raw/`. Capture's source is the conversation itself.

## Before Starting

Read `wiki/CLAUDE.md` to load the schema. Read `wiki/index.md` to know what pages already exist.

## Step 1: Scan the session for wiki-worthy knowledge

Review the conversation for the following categories. Not every session will have all of them — only capture what genuinely emerged.

**Decisions** — Was a significant product, architecture, or implementation decision made? Does the rationale exist in this conversation but nowhere else? If the decision isn't obvious from the code and the reasoning would be lost, it belongs in the wiki.

**Implementation patterns** — Was a new pattern established that should be followed in similar situations going forward? (e.g. "we decided background jobs in this codebase should always do X", "the convention for handling Y is Z")

**Gotchas discovered** — Was a non-obvious constraint, landmine, or "don't do X" rule encountered during implementation? Something that cost time to discover and would cost time again if not documented?

**Domain clarifications** — Was the meaning of a domain entity or business rule clarified? Did the user explain something about how the product works that isn't in the code?

**Feature behavior** — Was the intended behavior of a feature discussed — including edge cases, error states, or acceptance criteria — that isn't already in the wiki?

**Code location discoveries** — Was it discovered where a particular feature, entity, or behavior lives in the codebase? (Even if the code is readable, location pointers save time.)

**Integration details** — Were non-obvious details about an external service revealed during the session?

## Step 2: Present findings for confirmation

Do not write anything yet. Present a structured summary of what you found:

```
## Capture summary

Here's what I found in this session worth adding to the wiki:

**[Category]**
- [Item]: [One sentence on what it is and why it's wiki-worthy]
- [Item]: [...]

**[Category]**
- [Item]: [...]

Pages that would be created: [list]
Pages that would be updated: [list]

Anything to add, remove, or adjust before I write?
```

Wait for the user's confirmation or adjustments. If the user says "skip X" or "also add Y", incorporate that before writing.

If nothing wiki-worthy was found, say so clearly rather than inventing things to file.

## Step 3: Write to the wiki

For each confirmed item, write to the appropriate page type following `wiki/CLAUDE.md` conventions.

**For new pages:** Create the page using the full template for that page type. Fill in what's known from the session; mark unknown sections `TODO` rather than omitting them.

**For existing pages:** Read the current page first. Add new information in the appropriate section. If the session's information contradicts an existing claim, add a `> ⚠️ Conflict:` blockquote noting both claims rather than silently overwriting.

**Source attribution:** Since the source is the conversation rather than a document in `wiki/raw/`, cite as:
```
(Session: [brief session description or date])
```

## Step 4: Update index and log

Add any new pages to the appropriate section of `wiki/index.md`.

Append to `wiki/log.md`:

```markdown
## [YYYY-MM-DD] capture | [Session description]

- Items captured: [count]
- Pages created: [list]
- Pages updated: [list]
- Categories: [decisions / patterns / gotchas / clarifications / ...]
```

## Step 5: Confirm and surface what's still missing

After writing, tell the user:
- What was captured and where it was filed
- Any `TODO` sections in new pages that should be filled in when known
- Whether anything from the session suggested gaps in existing wiki pages worth flagging

## Rules

- Only capture what genuinely emerged from the session — do not pad the wiki with obvious or derivable information.
- Never capture implementation details (what code does). Capture intent, decisions, patterns, and context.
- Always confirm with the user before writing — the user may know that a decision was tentative or already documented elsewhere.
- A session with no wiki-worthy knowledge is a valid outcome. Say so rather than filing noise.
