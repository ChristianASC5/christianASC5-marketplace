# christianASC5-marketplace

## Plugin distribution paradigm

This repo is the marketplace that Claude Code actually loads plugins
from (cached under `~/.claude/plugins/cache/` and
`~/.claude/plugins/marketplaces/christianASC5-marketplace/`).

- It is **not** the source of truth for plugin content. Each plugin
  has its own dedicated source repo as a sibling under `../` (e.g.
  `../llm-wiki` for the `llm-wiki` plugin).
- Changes to a plugin should be made in its source repo first, then
  copied here (`plugins/<name>/`) and committed.
- **Never edit files under `plugins/<name>/` directly as the first
  change.** If an edit is made here without a matching change in the
  source repo, it will silently diverge — copy it back to the source
  repo before or as part of making the change here.
- If the live installed copy under `~/.claude/plugins/...` ever
  differs from what's in this repo, that's a sign changes were made
  directly to the installed copy and never synced back — pull those
  changes into the plugin's source repo first, then into this repo.

## Versioning

`.claude-plugin/marketplace.json` pins a `version` per plugin in
`plugins[]`. This does **not** auto-update when a plugin's own
`plugin.json` is bumped — it has drifted silently before (stuck at an
old version while `plugin.json` moved ahead). Whenever a plugin's
version changes, update the matching entry here in the same commit,
and propagate to the live installed copy at
`~/.claude/plugins/marketplaces/christianASC5-marketplace/.claude-plugin/marketplace.json`.
