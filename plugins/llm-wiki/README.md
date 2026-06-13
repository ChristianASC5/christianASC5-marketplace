# llm-wiki

A Claude Code plugin for building and maintaining a persistent, compounding knowledge base in your project — based on [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/b4b9adfe4b0c1fab49e3b4be23a9c582).

Instead of re-deriving answers from raw documents on every query (RAG), Claude incrementally builds and maintains a structured wiki of markdown files. Each source you add gets synthesized into the existing knowledge. Cross-references are maintained. Contradictions are flagged. The wiki gets richer over time.

**Claude writes it. You curate it.**

---

## How it works

```
wiki/
├── CLAUDE.md        ← schema: conventions Claude follows (domain-specific, generated on setup)
├── index.md         ← content catalog, updated on every operation
├── log.md           ← append-only event log
├── raw/             ← your source documents (immutable — Claude never writes here)
└── pages/           ← Claude-maintained wiki pages
```

The `raw/` directory holds your source documents. The `pages/` directory is entirely maintained by Claude.

---

## Getting started

### 1. Install the plugin

```bash
# From marketplace
/plugin llm-wiki

# Or locally
cc --plugin-dir /path/to/llm-wiki
```

### 2. Initialize a wiki in your project

```
/llm-wiki:create-wiki
```

Claude will ask about your domain and generate a tailored schema (`wiki/CLAUDE.md`) with page types, naming conventions, and index structure suited to your use case.

### 3. Add sources

Drop files into `wiki/raw/`, then:

```
ingest wiki/raw/my-article.md
```

The wiki-agent will read the source, discuss key takeaways with you, write a summary page, update related entity pages, and maintain the index and log.

### 4. Query the wiki

```
what does the wiki say about [topic]?
```

The wiki-agent reads the index, retrieves relevant pages, and synthesizes a grounded answer with citations. You can optionally file the answer back as a new wiki page.

### 5. Health-check the wiki

```
lint the wiki
```

The wiki-agent scans for orphan pages, contradictions, stale claims, and missing cross-references, then produces a prioritized report.

---

## Components

| Component | Type | Purpose |
|---|---|---|
| `create-wiki` | Skill (slash command) | Scaffold wiki + generate domain schema |
| `ingest` | Skill | Interactive source ingestion workflow |
| `query` | Skill | Wiki retrieval and synthesis workflow |
| `lint` | Skill | Wiki health audit workflow |
| `wiki-agent` | Agent | The actor — handles all wiki operations |
| `load-wiki.sh` | Hook (SessionStart) | Loads wiki schema + enables proactive mode |

---

## The session-start hook

When a project has a wiki, the SessionStart hook automatically:
- Loads `wiki/CLAUDE.md` into Claude's context
- Instructs Claude to consult the wiki proactively throughout the session

To disable for a session, disable the plugin (`/plugin llm-wiki --disable`).

---

## Optional: search at scale

For wikis with 100+ pages, consider adding a local search backend:

- **[knowledge-rag](https://github.com/lyonzin/knowledge-rag)** — MCP server with hybrid BM25 + semantic search, 100% local
- **[qmd](https://github.com/tobi/qmd)** — lightweight markdown search with CLI and MCP interfaces

The wiki-agent will use `Grep` for search by default. Configure an MCP search server in your project's `.mcp.json` to upgrade to vector search without changing the plugin.

---

## Credits

Pattern by [Andrej Karpathy](https://gist.github.com/karpathy/b4b9adfe4b0c1fab49e3b4be23a9c582).
