---
name: ingest
description: This skill should be used when the user asks to "ingest a document", "add this to the wiki", "process this source", "file this article", "add this paper to the wiki", or drops a file into wiki/raw/ and wants it incorporated. Provides the interactive workflow for incorporating a source document into the wiki.
version: 0.1.0
---

# ingest

Incorporate a source document from `wiki/raw/` into the wiki. This is an interactive, collaborative process — not a batch operation. One source at a time; stay involved.

## Before Starting

Read `wiki/CLAUDE.md` to load the schema conventions for this wiki (page types, naming, citation style, index format, log format). All decisions below should follow that schema.

Read `wiki/index.md` to understand what pages already exist before ingesting.

## Workflow

### Step 1: Read the source

Read the source file in full. Do not summarize yet.

### Step 2: Discuss key takeaways

Present the user with:
- A 3-5 bullet summary of what the source covers
- The most interesting or surprising claims
- Any direct contradictions with things already in the wiki (check existing pages as needed)
- Suggested page types this source will touch (based on the schema)

Ask: "Does this match your read? Anything you want to emphasize or de-emphasize before I write?"

Wait for the user's response. Adjust your plan based on their guidance.

### Step 3: Write the summary page

Create a dedicated summary page for this source at `wiki/pages/` following the naming convention in `wiki/CLAUDE.md`.

The summary page must include:
- **Title** (H1): the source's title
- **Source**: link back to the raw file (`[filename](../raw/filename.md)`)
- **Date ingested**: today's date
- **Summary**: 3-5 paragraphs covering the key content
- **Key claims**: bulleted list of the most important assertions
- **Entities mentioned**: links to entity pages (create stubs if they don't exist)
- **Related pages**: links to other wiki pages this source connects to
- **Open questions**: things this source raises but doesn't answer

### Step 4: Update or create entity and concept pages

For each significant entity or concept mentioned in the source:

1. Check if a page already exists in `wiki/pages/` for it
2. If yes — read the existing page and integrate the new information:
   - Add new facts or claims (with citation)
   - Note any contradictions with a `> ⚠️ Conflict:` blockquote
   - Update the "Related pages" section
3. If no — create a stub page following the schema's page type template for that entity

A single ingest may touch 5-15 pages. This is expected and correct.

### Step 5: Update wiki/index.md

Add the new summary page (and any new entity pages) to the appropriate sections of `wiki/index.md`. Follow the index format from `wiki/CLAUDE.md`.

Update the "Last updated" line at the bottom.

### Step 6: Append to wiki/log.md

Append an entry following the log format from `wiki/CLAUDE.md`:

```markdown
## [YYYY-MM-DD] ingest | [Source Title]

- Summary page: `pages/[filename].md`
- Pages updated: [list of pages touched]
- New pages created: [list]
- Contradictions flagged: [count, or "none"]
```

### Step 7: Confirm with the user

Tell the user:
- How many pages were created/updated
- Any contradictions flagged
- Suggested follow-up questions the source raises

## Rules

- Never modify files in `wiki/raw/`. They are read-only.
- Always follow naming and format conventions from `wiki/CLAUDE.md`.
- Cite every claim in wiki pages back to its source file.
- If a source contradicts an existing page, flag it — do not silently overwrite.
- Ingest one source per session unless the user explicitly asks for batch mode.
