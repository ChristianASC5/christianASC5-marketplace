#!/usr/bin/env bash
# SessionStart hook: loads wiki schema into context and instructs proactive wiki use.
# Outputs a systemMessage if a wiki is found in the current project.

set -euo pipefail

WIKI_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/wiki"
SCHEMA_FILE="$WIKI_DIR/CLAUDE.md"

# No wiki in this project — exit silently
if [ ! -d "$WIKI_DIR" ]; then
  exit 0
fi

# Wiki exists but no schema yet — minimal reminder
if [ ! -f "$SCHEMA_FILE" ]; then
  jq -n --arg msg "This project has a wiki/ directory but no wiki/CLAUDE.md schema file. The wiki may be incomplete. Consider running /llm-wiki:create-wiki to initialize it, or check wiki/ manually." '{
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": $msg
    }
  }'
  exit 0
fi

SCHEMA=$(cat "$SCHEMA_FILE")

PREAMBLE="## LLM Wiki Active

This project has an active LLM Wiki. Use it proactively throughout this session.

**Your responsibilities:**
- When the user mentions topics covered by the wiki, consult it before answering from general knowledge
- When you learn something new that belongs in the wiki, suggest adding it
- When the user shares documents or notes, offer to ingest them into the wiki
- Use the wiki-agent for all wiki operations (ingest, query, lint)
- Never answer from general knowledge alone when the wiki has relevant content

**Wiki schema for this project:**

"

jq -n --arg msg "${PREAMBLE}${SCHEMA}" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $msg
  }
}'
