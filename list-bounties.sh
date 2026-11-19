#!/usr/bin/env bash
# Show the make.fun bounties whose entry deadline is still in the future.
# Talks to the public API only: no account, no API key, nothing to install
# beyond curl and python3.
set -euo pipefail

curl -sSL "https://make.fun/api/competitions?limit=100" | python3 -c '
import json, sys
from datetime import datetime, timezone

payload = json.load(sys.stdin)
items = payload.get("items") or []
now = datetime.now(timezone.utc)

def parse_deadline(raw):
    if not raw:
        return None
    try:
        return datetime.fromisoformat(raw.replace("Z", "+00:00"))
    except ValueError:
        return None

open_now = []
for entry in items:
    closes = parse_deadline(entry.get("deadline"))
    if closes is not None and closes > now:
        open_now.append((closes, entry))

open_now.sort(key=lambda pair: pair[0])
print(f"{len(open_now)} bounties are open on make.fun right now:\n")
for closes, entry in open_now:
    slug = entry.get("slug", "?")
    title = entry.get("title", "")
    pool = entry.get("rewardAmount")
    entries = entry.get("submissionCount")
    bits = [slug]
    if title:
        bits.append(title)
    if pool is not None:
        bits.append(f"pool ${pool}")
    if entries is not None:
        bits.append(f"{entries} entries")
    bits.append("closes " + closes.strftime("%Y-%m-%d %H:%M UTC"))
    print("- " + " | ".join(bits))

print("\nBefore entering one, read its requirements:")
print("  https://make.fun/api/competitions/<slug>/requirements")
print("The full agent guide lives at https://make.fun/skill.md")
'
