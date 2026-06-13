---
name: create-project-wiki
description: This skill should be used when the user wants to "create a project wiki", "set up a wiki for implementing tickets", "create a wiki for autonomous coding", "initialize a product wiki", "set up a knowledge base for the codebase", or wants Claude to be able to implement Jira/Linear/GitHub tickets autonomously without needing to ask for context. Creates a wiki structured around the missing layer between code and tickets.
argument-hint: "[product or domain description] (optional)"
allowed-tools: ["Read", "Write", "Bash"]
version: 0.1.0
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

## Discovery Interview

Ask all of the following in a single message before writing anything:

1. **Product** — What does this product do? One or two sentences on the core value proposition.
2. **Domain** — What are the 5-10 most important domain entities? (e.g. User, Order, Subscription, Invoice, Workspace)
3. **Ticket system** — What ticket system is used? (Jira, Linear, GitHub Issues, other) How are tickets typically structured — do they include acceptance criteria, business rules, or just a description?
4. **External integrations** — What external services does the product integrate with? (payment processors, auth providers, email services, analytics, etc.)
5. **Team conventions** — Any non-obvious conventions Claude would need to know to implement correctly? (e.g. how feature flags work, how background jobs are structured, branching strategy, testing expectations)
6. **Known gotchas** — Any known non-obvious constraints, landmines, or "don't do X because Y" rules that aren't documented anywhere?

Wait for answers before proceeding.

## Schema Generation

Based on the answers, generate `wiki/CLAUDE.md` with the following sections. Tailor every section to the specific product and domain — do not use generic placeholder text.

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

Operations: `ingest`, `query`, `lint`, `create`.

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
Purpose: Autonomous agentic implementation — fills the gap between codebase and tickets.
```

## Orientation for the User

After setup, tell the user:

1. **What to add first** — the most valuable initial content is domain entity definitions and any business rules that aren't obvious from the code. If there are existing docs, PRDs, or ADRs, drop them in `wiki/raw/` and ask the wiki-agent to ingest them.
2. **How to use it on a ticket** — when starting work on a ticket, ask the wiki-agent to look up relevant entities, features, or rules before touching the code. The wiki gives Claude the intent; the code gives the implementation.
3. **How to keep it current** — ingest new PRDs, design docs, or post-mortems as they're written. After implementing a non-obvious feature, consider adding a gotcha or decision page.
4. **What not to add** — if it can be learned by reading the code, leave it out. The one exception: code location pointers (which files/modules implement a feature) are always worth adding, even if the code is readable, because they save Claude from exploring the wrong part of the repo.
