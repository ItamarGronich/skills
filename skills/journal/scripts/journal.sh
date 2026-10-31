#!/usr/bin/env bash
# Daily work journal shared by every Claude session.
# Many sessions write to the same file at once, so every write goes through this script,
# which appends (or ticks a plan item) under a lock instead of rewriting the file.
set -euo pipefail

JOURNAL_DIR="${JOURNAL_DIR:-$HOME/journal}"
TEMPLATE="$(cd "$(dirname "$0")/.." && pwd)/assets/day-template.md"
export TZ="${JOURNAL_TZ:-Asia/Jerusalem}"
LOCK_DIR="$JOURNAL_DIR/.lock"

usage() {
    cat <<'EOF'
journal.sh path [YYYY-MM-DD]          print the file path for a day (default today)
journal.sh ensure [YYYY-MM-DD]        create the day's file from the template if missing, print its path
journal.sh add TYPE "text" [TOPIC]    append a log entry to today's file
                                      TYPE: DECISION FINDING TASK START DONE BLOCKED PLAN UNPLANNED NOTE
                                      UNPLANNED entries get the next U<n> id automatically
journal.sh done ID [YYYY-MM-DD]       tick plan item ID (e.g. P3) and log DONE
journal.sh next-workday [YYYY-MM-DD]  print the next workday (Sunday to Thursday)
journal.sh session-start              context printed into every new session (used by the SessionStart hook)
EOF
}

day_file() {
    local day="${1:-$(date +%F)}"
    local name
    name="$(date -j -f %F "$day" +%A | tr '[:upper:]' '[:lower:]')"
    echo "$JOURNAL_DIR/$day-$name.md"
}

lock() {
    local tries=0
    if [ ! -w "$JOURNAL_DIR" ]; then
        echo "journal: no write access to $JOURNAL_DIR (sandbox or permissions)" >&2
        exit 1
    fi
    until mkdir "$LOCK_DIR" 2>/dev/null; do
        tries=$((tries + 1))
        # A lock older than 30 seconds belongs to a writer that died; take it over.
        if [ -d "$LOCK_DIR" ] && [ $(($(date +%s) - $(stat -f %m "$LOCK_DIR"))) -gt 30 ]; then
            rmdir "$LOCK_DIR" 2>/dev/null || true
        fi
        [ "$tries" -gt 100 ] && { echo "journal: could not get the lock" >&2; exit 1; }
        sleep 0.1
    done
    trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT
}

ensure() {
    local day="${1:-$(date +%F)}"
    local file
    file="$(day_file "$day")"
    mkdir -p "$JOURNAL_DIR"
    if [ ! -f "$file" ]; then
        local title
        title="$(date -j -f %F "$day" '+%A, %-d %B %Y')"
        sed "s/{{TITLE}}/$title/" "$TEMPLATE" > "$file"
    fi
    echo "$file"
}

topic() {
    # Tag entries with the session's repo or folder, so readers know which work they belong to.
    basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
}

add() {
    local type="$1" text="$2" tag="${3:-$(topic)}"
    case "$type" in
        DECISION | FINDING | TASK | START | DONE | BLOCKED | PLAN | UNPLANNED | NOTE) ;;
        *) echo "journal: unknown type $type" >&2; usage >&2; exit 1 ;;
    esac
    local file
    file="$(ensure)"
    lock
    if [ "$type" = UNPLANNED ]; then
        local n
        n=$(($(grep -c ' UNPLANNED U[0-9]*:' "$file" || true) + 1))
        type="UNPLANNED U$n"
    fi
    printf -- '- %s [%s] %s: %s\n' "$(date +%H:%M)" "$tag" "$type" "$text" >> "$file"
    echo "journal: added to $(basename "$file"): $type: $text"
}

done_item() {
    local id="$1" day="${2:-$(date +%F)}"
    local file
    file="$(day_file "$day")"
    [ -f "$file" ] || { echo "journal: no file for $day" >&2; exit 1; }
    lock
    if grep -q -- "^- \[ \] $id " "$file"; then
        sed -i '' "s/^- \[ \] $id /- [x] $id /" "$file"
    else
        echo "journal: open plan item $id not found in $(basename "$file")" >&2
    fi
    printf -- '- %s [%s] DONE %s\n' "$(date +%H:%M)" "$(topic)" "$id" >> "$file"
    rmdir "$LOCK_DIR" 2>/dev/null || true
    trap - EXIT
}

next_workday() {
    local day="${1:-$(date +%F)}"
    # Friday and Saturday are the weekend in Israel.
    local next
    next="$(date -j -v+1d -f %F "$day" +%F)"
    while [ "$(date -j -f %F "$next" +%u)" = 5 ] || [ "$(date -j -f %F "$next" +%u)" = 6 ]; do
        next="$(date -j -v+1d -f %F "$next" +%F)"
    done
    echo "$next"
}

autosave() {
    # Keep a history of the journal. Runs from the SessionStart hook, outside any session's tools.
    [ -d "$JOURNAL_DIR/.git" ] || return 0
    if [ -n "$(git -C "$JOURNAL_DIR" status --porcelain 2>/dev/null)" ]; then
        git -C "$JOURNAL_DIR" add -A >/dev/null 2>&1 &&
            git -C "$JOURNAL_DIR" commit -q -m "journal: autosave $(date '+%F %H:%M')" >/dev/null 2>&1 || true
    fi
}

session_start() {
    autosave
    local file
    file="$(ensure)"
    echo "[journal] Today's journal: $file"
    echo "[journal] Follow the journal rules in CLAUDE.md; the journal skill has the format and journal.sh usage."
    echo
    echo "--- Plan ---"
    awk '/^## Plan/{p=1; next} /^## /{p=0} p' "$file" | sed '/^[[:space:]]*$/d' | sed '/^<!--/d'
    echo "--- Last log entries ---"
    awk '/^## Log/{p=1; next} p' "$file" | grep '^- ' | tail -n 15 || true
    local hour tomorrow
    hour="$(date +%H)"
    tomorrow="$(day_file "$(next_workday)")"
    if [ "$hour" -ge 17 ] && ! grep -q '^- \[' "$tomorrow" 2>/dev/null; then
        echo
        echo "[journal] It's after 17:00 and $(basename "$tomorrow") has no plan yet. Offer the user once to draft it with the plan-tomorrow skill."
    fi
}

cmd="${1:-}"
shift || true
case "$cmd" in
    path) day_file "${1:-}" ;;
    ensure) ensure "${1:-}" ;;
    add) [ $# -ge 2 ] || { usage >&2; exit 1; }; add "$@" ;;
    done) [ $# -ge 1 ] || { usage >&2; exit 1; }; done_item "$@" ;;
    next-workday) next_workday "${1:-}" ;;
    session-start) session_start ;;
    *) usage ;;
esac
