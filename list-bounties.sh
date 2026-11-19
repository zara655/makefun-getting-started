#!/usr/bin/env bash
# List the make.fun bounties that are open right now.
# Uses only the public API: no account, no key, no sign-up needed.
set -euo pipefail

curl -sSL "https://make.fun/api/competitions" | python3 -c '
import json, sys

data = json.load(sys.stdin)
items = data.get("items") or data.get("competitions") or data.get("data") or []
if isinstance(items, dict):
    items = items.get("items") or []

open_items = [c for c in items if c.get("status") == "open"]
print(f"{len(open_items)} open bounties on make.fun right now:\n")
for c in open_items:
    slug = c.get("slug", "?")
    title = c.get("title", "")
    closes = c.get("entries_close") or c.get("deadline") or ""
    prize = c.get("prize_total_usd") or c.get("rewardAmount") or c.get("potUsd") or ""
    line = f"- {slug}"
    if title:
        line += f"  {title}"
    if prize:
        line += f"  (${prize})"
    if closes:
        line += f"  closes {closes}"
    print(line)
print("\nRead a bountys requirements before entering:")
print("  https://make.fun/api/competitions/<slug>/requirements")
'
