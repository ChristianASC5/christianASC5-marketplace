---
name: create-wiki
description: This skill should be used when the user asks to "create a wiki", "set up a wiki", "initialize a wiki", "start a knowledge base", "scaffold a wiki", or "set up an llm-wiki for this project". Guides Claude through generating a domain-specific wiki schema and directory structure at wiki/ in the project root.
argument-hint: "[topic or domain] (optional)"
allowed-tools: ["Read", "Write", "Bash"]
version: 0.1.0
---

# create-wiki

Scaffold a new LLM Wiki in the current project. The wiki is a persistent, compounding knowledge base maintained by Claude — based on Karpathy's LLM Wiki pattern. Claude writes and maintains it; the user curates sources and asks questions.

## Overview

The wiki lives at `wiki/` in the project root with this layout:

```
wiki/
├── CLAUDE.md        ← schema: conventions the LLM follows (generated per-domain)
├── index.md         ← content catalog, updated on every ingest
├── log.md           ← append-only event log
├── raw/             ← immutable source documents (user drops files here)
└── pages/           ← LLM-maintained wiki pages
```

`raw/` is never modified by Claude. `pages/` and the index/log are entirely Claude's responsibility.

## Workflow

### Step 1: Discover the domain

Before generating anything, ask the user the following (all at once):

1. What is this wiki for? (e.g. "competitive research on LLM tooling", "notes from a book", "team architecture decisions", "personal health tracking")
2. What kinds of sources will be added? (articles, PDFs, meeting notes, papers, code, etc.)
3. Are there specific entity types that will recur? (e.g. people, companies, papers, concepts, features, places)
4. Any preferences for how pages should be named or organized?

Wait for answers before proceeding.

### Step 2: Generate the schema (wiki/CLAUDE.md)

Based on the user's answers, generate a domain-specific `wiki/CLAUDE.md`. This file is the LLM's constitution — it defines conventions for the wiki. Tailor every section to the domain.

The schema must include:

**Wiki purpose** — 2-3 sentences on what this wiki tracks and why.

**Directory structure** — confirm the standard layout above, noting any domain-specific subdirs under `pages/` if useful (e.g. `pages/papers/`, `pages/people/`, `pages/concepts/`).

**Page types** — list the recurring page types for this domain. For each, specify:
- Name and purpose
- Naming convention (e.g. `person-firstname-lastname.md`, `paper-shortname-year.md`)
- Required sections (e.g. a "People" page might have: Bio, Role, Positions, Key Claims, Related Pages)

**Index conventions** — how `index.md` is organized (by category, by date, alphabetically). Specify the one-line summary format for each entry.

**Log conventions** — the prefix format for log entries. Standard format:
```
## [YYYY-MM-DD] <operation> | <title>
```
Operations: `ingest`, `query`, `lint`, `create`.

**Cross-reference style** — how pages link to each other (standard markdown `[Page Title](pages/filename.md)`).

**Contradiction handling** — when new sources conflict with existing pages, note the conflict inline with a `> ⚠️ Conflict:` blockquote and flag it in the lint report.

**Source citation style** — how to cite sources in page content (e.g. `([Source Title](../raw/filename.md))`).

### Step 3: Create the directory structure

```bash
mkdir -p wiki/raw wiki/pages
```

### Step 4: Create wiki/index.md

Generate an empty index appropriate for the domain:

```markdown
# Wiki Index

> Auto-maintained by Claude. Updated on every ingest.

## [Category 1]

| Page | Summary | Sources |
|------|---------|---------|
| *(empty)* | | |

## [Category 2]

...

---
*Last updated: [date]*
```

Replace categories with domain-appropriate ones from the schema.

### Step 5: Create wiki/log.md

```markdown
# Wiki Log

> Append-only. Each entry starts with `## [YYYY-MM-DD] operation | title` for easy grepping.

## [today's date] create | Wiki initialized

Wiki created for: [user's stated purpose].
Schema generated at `wiki/CLAUDE.md`.
```

### Step 6: Confirm and orient the user

After creating all files, tell the user:

- The wiki is ready at `wiki/`
- Drop source documents into `wiki/raw/` to ingest them
- To add a source: ask the wiki-agent to ingest it (e.g. "ingest wiki/raw/article.md")
- To ask a question: ask the wiki-agent (e.g. "what does the wiki say about X?")
- To health-check: ask the wiki-agent to lint the wiki
- The session-start hook will load the schema automatically in future sessions

## Important Rules

- Never modify files in `wiki/raw/`. They are immutable sources of truth.
- Always append to `wiki/log.md` — never overwrite existing entries.
- Keep `wiki/CLAUDE.md` as the single source of convention truth. If the user wants to change a convention, update it there first.
- If `wiki/` already exists in the project, stop and tell the user — do not overwrite an existing wiki.
