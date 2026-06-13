---
name: lint
description: This skill should be used when the user asks to "lint the wiki", "health check the wiki", "audit the wiki", "check the wiki for issues", "find contradictions in the wiki", "find orphan pages", or "clean up the wiki". Provides the workflow for auditing wiki health and producing a structured report.
version: 0.1.0
---

# lint

Audit the wiki for structural and content health issues. Produce a prioritized report and offer to fix what can be fixed automatically.

## Before Starting

Read `wiki/CLAUDE.md` to understand the schema conventions. The lint checks use this as the standard.

Read `wiki/index.md` to get the full list of pages.

## Health Checks

Run all checks below. Collect findings before presenting — do not report issues one at a time.

### 1. Orphan pages

Find pages in `wiki/pages/` that are not linked from any other page (no inbound links).

Method: for each page file, check if its filename appears in `[[...]]` or `(pages/filename.md)` anywhere across all other wiki pages and the index.

Flag as orphan if no inbound links exist outside of `wiki/index.md`.

### 2. Contradictions

Scan for `> ⚠️ Conflict:` blockquotes across all pages. These are previously flagged contradictions that may need resolution.

Also look for pages that make directly opposing claims about the same subject (e.g. one page says "X was founded in 2020", another says "X was founded in 2021"). Note these even if not previously flagged.

### 3. Stale claims

Look for claims that are time-sensitive and may have aged out: dates, version numbers, "current" status, "recent" events, "upcoming" items. Flag pages with such language where the information may no longer be current.

Cross-reference against `wiki/log.md` to identify pages that haven't been touched since early ingests.

### 4. Missing cross-references

Scan pages for mentions of entities that have their own wiki page but are not linked. For example, if page A mentions "Company X" in plain text and there is a `company-x.md` page, that mention should be a link.

Limit to entities with their own pages — don't flag every noun.

### 5. Index gaps

Compare the list of files in `wiki/pages/` against the entries in `wiki/index.md`. Flag any pages that exist on disk but are missing from the index.

### 6. Schema compliance

Check a sample of pages (up to 10) against the required sections defined in `wiki/CLAUDE.md`. Flag pages that are missing required sections for their page type.

### 7. Suggested investigations

Based on what exists, suggest:
- Topics mentioned across multiple pages but lacking their own page
- Sources that would strengthen thin areas
- Questions worth querying (and filing back) to fill knowledge gaps

## Report Format

Present findings as a structured report:

```
## Wiki Health Report — [date]

### Summary
- Total pages: X
- Issues found: X critical, X warnings, X suggestions

### Critical (should fix)
- [Issue type]: [description] → [affected file(s)]

### Warnings (worth reviewing)
- [Issue type]: [description] → [affected file(s)]

### Suggestions (optional improvements)
- [Suggestion]

### Recommended next sources
- [Topic gap] — suggest searching for [type of source]
```

## After the Report

Ask the user: "Want me to fix any of these automatically?"

Fixes that can be done automatically:
- Add missing index entries (Step 5)
- Add missing cross-reference links (Step 4, non-ambiguous cases)
- Create stub pages for entities mentioned but lacking pages

Fixes that require user judgment:
- Resolving contradictions (present both claims, ask which is correct)
- Updating stale claims (ask user for current information)

After any fixes, append to `wiki/log.md`:

```markdown
## [YYYY-MM-DD] lint | Health check

- Issues found: X critical, X warnings
- Auto-fixed: [list]
- Requires user review: [list]
```
