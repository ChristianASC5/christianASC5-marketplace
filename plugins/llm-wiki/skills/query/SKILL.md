---
name: query
description: This skill should be used when the user asks "what does the wiki say about X", "query the wiki", "look up X in the wiki", "what do we know about X", "summarize what the wiki covers on X", or asks a question that should be answered from the project's wiki rather than general knowledge. Provides the workflow for retrieving and synthesizing answers from wiki pages.
version: 0.1.0
---

# query

> **Delegation:** Do not execute this workflow as the main Claude Code agent. Invoke the `wiki-agent` and hand off the request. The workflow below is guidance for the wiki-agent.

Answer a question by retrieving and synthesizing content from the wiki. The goal is grounded answers — drawn from the wiki's accumulated knowledge, with citations — not from general training data.

## Before Starting

Read `wiki/CLAUDE.md` to understand the wiki's domain and structure.

## Workflow

### Step 1: Read the index

Read `wiki/index.md` in full. This is the map of everything in the wiki. Identify which pages are likely relevant to the question.

If the wiki has many pages (50+), scan the index for matching titles and summaries rather than reading every page.

### Step 2: Read relevant pages

Read the pages identified in Step 1. Follow cross-references where useful — a page may link to another that's more directly relevant.

If reading a page reveals more relevant links, follow them (up to 2 levels deep). Stop when you have enough to synthesize a grounded answer.

### Step 3: Synthesize the answer

Write a clear, structured answer that:
- Directly addresses the question
- Cites every claim to its wiki page (e.g. `([Page Title](pages/filename.md))`)
- Notes where the wiki's coverage is thin or contradictory
- Distinguishes wiki knowledge from your own general knowledge (mark general knowledge clearly if used to fill gaps)

Format the answer appropriately for the question: prose for open-ended questions, tables for comparisons, bullet lists for enumerations.

### Step 4: Surface gaps

After the answer, briefly note:
- Topics the question touches that the wiki doesn't yet cover
- Sources that would strengthen weak areas
- Follow-up questions worth investigating

### Step 5: Offer to file the answer

Ask: "Want me to save this answer as a wiki page?"

If the user says yes:
- Create a new page in `wiki/pages/` with an appropriate name (e.g. `query-what-is-X.md` or a topic-named page if it's substantive enough to stand alone)
- Include the full answer, citations, and gaps noted above
- Update `wiki/index.md` to include the new page
- Append to `wiki/log.md`:

```markdown
## [YYYY-MM-DD] query | [Question summary]

- Answer filed: `pages/[filename].md`
- Pages consulted: [list]
```

If the user says no, the answer lives in the conversation only.

## Rules

- Ground answers in wiki content first. Use general knowledge only to fill gaps, and label it clearly.
- Never fabricate wiki citations. If a page doesn't say something, don't claim it does.
- If the wiki has no relevant content, say so directly rather than answering from training data without disclosure.
- Filed answers are wiki pages like any other — they can be updated, cross-referenced, and built upon in future ingests.
