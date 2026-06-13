---
name: create-project-wiki
description: This skill should be used when the user wants to "create a project wiki", "set up a wiki for implementing tickets", "create a wiki for autonomous coding", "initialize a product wiki", "set up a knowledge base for the codebase", or wants Claude to be able to implement Jira/Linear/GitHub tickets autonomously without needing to ask for context. Creates a wiki structured around the missing layer between code and tickets. Works for both established products and greenfield projects.
argument-hint: "[product or domain description] (optional)"
allowed-tools: ["Read", "Write", "Bash"]
version: 0.2.0
---

# create-project-wiki

Create a wiki designed to enable autonomous agentic code implementation. This wiki fills the missing layer between the codebase and the ticket — the *why* and *what* that Claude cannot derive by reading code alone.

## The Core Principle

Claude can already explore the codebase. It can read files, trace call stacks, grep for usages, and understand what the code does. The wiki must not duplicate this.

**The wiki holds only what cannot be learned from the code:**
- Why a business rule exists (not just that it exists)
- What domain terms mean in this specific product
- What an external system does and how the product depends on it
- What the intended behavior of a feature is, including edge cases
- What constraints exist for legal, compliance, or business reasons
- What decisions were made and why, when the code doesn't make that obvious
- **Where in the codebase a feature or entity lives** — the entry points, modules, and directories that implement it, so Claude knows where to start without grepping blindly

**The wiki does not hold:**
- Implementation details — what a class or function does (read the code)
- API signatures or database schemas (read the code)
- Line-by-line explanations of how code works (read the code)
- Anything a developer could learn by reading the repo for 10 minutes

The distinction on code pointers: *where* a feature lives is a wiki concern; *what the code at that location does* is not. "The billing feature is in `src/billing/`, entry point is `BillingService.charge()`" belongs in the wiki. What `charge()` does does not.

The test: *Could Claude figure this out by reading the codebase?* If yes, it doesn't belong in the wiki — with one exception: code location pointers are always worth recording, even when the code is readable, because they save Claude from exploring the wrong part of the repo.

## Step 1: Detect the Mode

Before the discovery interview, ask one question:

> "Is this an established product with existing code and decisions, or a greenfield project just getting started?"

This determines which mode to use. The page types and schema structure are the same in both modes — the difference is in how the interview is conducted and how incomplete answers are handled.

---

## Established Mode

Use when the product has existing code, decisions, and team knowledge to document.

### Discovery Interview

Ask all of the following in a single message:

1. **Product** — What does this product do? One or two sentences on the core value proposition.
2. **Domain** — What are the 5-10 most important domain entities? (e.g. User, Order, Subscription, Invoice, Workspace)
3. **Ticket system** — What ticket system is used? (Jira, Linear, GitHub Issues, other) How are tickets typically structured?
4. **External integrations** — What external services does the product integrate with? (payment processors, auth providers, email services, analytics, etc.)
5. **Team conventions** — Any non-obvious conventions Claude would need to know to implement correctly? (e.g. how feature flags work, how background jobs are structured, branching strategy, testing expectations)
6. **Known gotchas** — Any known non-obvious constraints, landmines, or "don't do X because Y" rules that aren't documented anywhere?

Wait for answers. Generate the schema from what's provided — skip or stub any section the user doesn't answer.

---

## Greenfield Mode

Use when the product is early-stage and many things are still undecided.

### Greenfield Discovery Interview

Ask only what's knowable right now — in a single message:

1. **Product intent** — What is this product? What problem does it solve? Even a rough answer is fine.
2. **Core entities** — What are the 2-3 domain entities you're most certain about? (skip if none yet)
3. **Ticket system** — What ticket system will you use, if decided?
4. **Known decisions** — Any architectural or product decisions already made that Claude should know about?

Frame the questions explicitly: *"Answer only what you know — skip anything undecided. The wiki will grow as the product does."*

### Greenfield Schema Generation

Generate `wiki/CLAUDE.md` from whatever answers are provided. For any section with no information yet, write a stub marked `TODO` rather than leaving it empty or making things up.

Add a **"Greenfield notice"** at the top of the generated schema:

```markdown
> ⚠️ **Greenfield wiki** — This wiki was initialized early. Many sections are stubs.
> As the product takes shape, fill them in by ingesting PRDs, design docs, and decision notes,
> or by asking the wiki-agent to add pages after key decisions are made.
> Update this schema (`wiki/CLAUDE.md`) whenever the product's structure or conventions change.
```

Add a **"Schema evolution"** section to the schema:

```markdown
## Schema evolution

This schema is a living document. Update it when:
- New domain entities emerge that don't fit existing page types
- New integrations are decided
- Team conventions are established
- The product's scope changes significantly

To update: edit `wiki/CLAUDE.md` directly, then ask the wiki-agent to lint the wiki and flag
any existing pages that need updating to match the new schema.
```

Generate stub pages for any entities the user named, using the page type templates below with `TODO` in unfilled sections. This gives Claude something to build on immediately rather than an empty wiki.

---

## Schema Generation (Both Modes)

Based on the answers, generate `wiki/CLAUDE.md` with the following sections. Tailor every section to the specific product and domain — do not use generic placeholder text. For greenfield, stub unknown sections with `TODO`.

### Wiki purpose

Write 3-4 sentences describing exactly what this wiki is for:
- What product it covers
- What kinds of questions it answers
- What it explicitly does not cover (i.e., anything learnable from the code)
- How Claude should use it when working on a ticket

### Guiding principle for wiki use

Include this verbatim, as it governs how Claude should behave in every session:

> When working on a ticket or implementing a feature, read the relevant wiki pages before reading the code. The wiki provides the *intent* and the *map*; the code provides the *implementation*. Use the wiki's code location pointers to find where to start in the codebase, then read the code to understand how it works.
>
> If the wiki and the code appear to conflict, flag it — the wiki may be stale or the code may have drifted from intent.
>
> Never add content to the wiki that can be learned by reading the codebase, with one exception: always record code location pointers (which modules, directories, and entry points implement a feature). The wiki is not documentation of what the code does. It is context for why the product works the way it does, and a map for where to find it.
>
> If a wiki page has a `TODO` section, note it when citing that page — the information may be missing. Suggest filling it in if it's relevant to the current task.

### Page types

Define the following page types, tailored to the domain. For each, specify the naming convention and required sections.

**Domain entities** (`pages/entities/`)
One page per core domain entity. Required sections:
- Definition — what this entity means in the product (not its database representation)
- States and lifecycle — valid states and what transitions are allowed
- Business rules — constraints and invariants that must hold
- Code location — where this entity is defined and managed in the codebase (model, service, repository — directory and class level only, not method documentation)
- Common misunderstandings — things developers get wrong about this entity
- Related entities — links to related pages

**Feature specs** (`pages/features/`)
One page per significant product feature. Required sections:
- Purpose — why this feature exists and what user problem it solves
- Behavior — what the feature does, including edge cases and error states
- Business rules — rules that govern the feature's behavior
- Code location — where this feature is implemented (entry points, key modules, directories). Format: `path/to/module` — `ClassName` — brief role (e.g. `src/billing/` — `BillingService` — orchestrates charge lifecycle). Not what the code does; just where it lives.
- Acceptance criteria — what "done" looks like for this feature
- Known limitations — intentional constraints or deferred scope
- Related entities — domain entities this feature involves

**Business rules** (`pages/rules/`)
For rules that span multiple features or entities. Required sections:
- Rule — the rule stated plainly
- Rationale — why this rule exists (business, legal, product reason)
- Scope — where this rule applies
- Exceptions — any known exceptions

**Integrations** (`pages/integrations/`)
One page per external service. Required sections:
- Purpose — why this integration exists and what the product uses it for
- What it owns — data or functionality that lives in the external system, not ours
- Code location — where the integration is implemented (client wrappers, adapters, config)
- Key behaviors — non-obvious things about how this integration works
- Error handling expectations — how the product should behave when this service fails
- Gotchas — known quirks or constraints

**Architecture decisions** (`pages/decisions/`)
For significant decisions where the rationale isn't obvious from the code. Required sections:
- Decision — what was decided
- Context — what problem this solved
- Rationale — why this option was chosen over alternatives
- Consequences — what this decision makes easier or harder going forward

**Workflows** (`pages/workflows/`)
For end-to-end business processes that span multiple features or services. Required sections:
- Trigger — what starts this workflow
- Steps — the sequence of events, including which systems are involved
- Error paths — what happens when steps fail
- Related features and entities

**Gotchas** (`pages/gotchas/`)
A catch-all for non-obvious constraints, landmines, and "don't do X because Y" rules. Required sections:
- The gotcha — stated plainly
- Why it exists
- How to avoid it

### Index conventions

The index is organized by page type (Entities, Features, Rules, Integrations, Decisions, Workflows, Gotchas). Each entry: page title, one-line summary, last updated date.

### Log conventions

```
## [YYYY-MM-DD] <operation> | <title>
```

Operations: `ingest`, `query`, `lint`, `create`, `update`.

### Source citation

```
([Source](../raw/filename.md))
```

## Directory Structure and File Creation

After generating the schema, create:

```bash
mkdir -p wiki/raw wiki/pages/entities wiki/pages/features wiki/pages/rules \
         wiki/pages/integrations wiki/pages/decisions wiki/pages/workflows wiki/pages/gotchas
```

Create `wiki/index.md` organized by the page types above, with empty tables for each section.

Create `wiki/log.md` with an initial entry:

```markdown
## [today] create | Project wiki initialized

Product: [product name from discovery]
Mode: [established / greenfield]
Purpose: Autonomous agentic implementation — fills the gap between codebase and tickets.
```

For greenfield mode, also create stub entity pages for any entities named in the interview.

## Orientation for the User

After setup, tell the user:

**For established mode:**
1. **What to add first** — the most valuable initial content is domain entity definitions and business rules that aren't obvious from the code. If there are existing docs, PRDs, or ADRs, drop them in `wiki/raw/` and ask the wiki-agent to ingest them.
2. **How to use it on a ticket** — when starting work on a ticket, ask the wiki-agent to look up relevant entities, features, or rules before touching the code. The wiki gives Claude the intent; the code gives the implementation.
3. **How to keep it current** — ingest new PRDs, design docs, or post-mortems as they're written. After implementing a non-obvious feature, consider adding a gotcha or decision page.
4. **What not to add** — if it can be learned by reading the code, leave it out. The exception: code location pointers are always worth adding.

**For greenfield mode:**
1. **Start minimal** — the wiki has stubs for what you named. Fill sections in as decisions get made, not before.
2. **Capture decisions as you make them** — every time a significant product or architecture decision is made, ingest the notes or discussion and let the wiki-agent file it. Decisions are the hardest thing to reconstruct later.
3. **Update the schema as the product evolves** — when new entity types or conventions emerge that don't fit the current schema, edit `wiki/CLAUDE.md` and tell the wiki-agent to lint for pages that need updating.
4. **The wiki grows with the product** — don't try to fill it all in upfront. Add a page when you need it, not before.
