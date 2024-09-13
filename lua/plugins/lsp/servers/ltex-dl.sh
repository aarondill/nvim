#!/usr/bin/env bash
set -euC -o pipefail
url="${1:-}" ngrams_dir="${2:-}"
this="${0##*/}"

LOCKFILE="/tmp/$this.lock" LOCKFD=99
_lock() { flock "-$1" "$LOCKFD"; }
_no_more_locking() {
  local _code="$?"
  {
    _lock u || true
    _lock xn && rm -f -- "$LOCKFILE"
  } || true
  return "$_code"
}
_prepare_locking() {
  exec {LOCKFD}>>"$LOCKFILE"
  trap _no_more_locking EXIT
}
_prepare_locking
exlock_now() { _lock xn; } # obtain an exclusive lock immediately or fail
unlock() { _lock u; }
log() { printf '%s\n' "$@" || true; }
err() { printf '%s\n' "$@" >&2 || true; }
abort() { err "$this: $1" && exit "${2:-1}"; }
has() { command -v -- "$1" &>/dev/null; }

exlock_now || abort "already running" 75 # exit 75 to indicate that the process is already running
has curl || abort "curl is required"
has unzip || abort "unzip is required"
{ [ -n "$url" ] && [ -n "$ngrams_dir" ]; } || abort "usage: $this <url> <ngrams_dir>"

mkdir -p "$ngrams_dir"
zip_file=$(mktemp "${ngrams_dir%/}.XXXXXXXXX")
log "Downloading $url to $zip_file"
rm -f -- "$zip_file"

curl -fL -o "$zip_file" -- "$url"

log "Extracting $zip_file to $ngrams_dir"
unzip -d "$ngrams_dir" -- "$zip_file"
rm -f -- "$zip_file"

log "Done"
