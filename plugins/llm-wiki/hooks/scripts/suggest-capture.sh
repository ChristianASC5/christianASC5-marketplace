#!/usr/bin/env bash
# Stop hook: nudges Claude to consider a wiki capture, only when a wiki exists.
# additionalContext (like decision:block) keeps the turn going through the same
# stop_hook_active loop protection — skip entirely once already active to avoid
# retriggering ourselves every continuation.

set -euo pipefail

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(jq -r '.stop_hook_active // false' <<<"$INPUT")

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

WIKI_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/wiki"

# No wiki in this project — exit silently
if [ ! -d "$WIKI_DIR" ]; then
  exit 0
fi

jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "A project wiki is active. If this session established any decisions, implementation patterns, gotchas, or domain knowledge not already captured in the wiki, ask the wiki-agent to capture it (run /capture) before the user moves on."
  }
}'
