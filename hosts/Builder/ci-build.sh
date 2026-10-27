# Build the hosts in $CI_HOSTS for main and for every open PR of $CI_REPO,
# skipping any commit that has already been tried. Results are kept as gc
# roots under $STATE_DIRECTORY/roots, so harmonia keeps serving them.
#
# Retention is bounded by construction: one root per host for main, one per
# host for each *open* PR (re-pointed on every new commit, dropped when the
# PR closes).
#
# If a GitHub token is present ($RUNTIME_DIRECTORY/github-token, copied from
# /var/lib/nixos-ci-token by the unit), each commit also gets a commit
# status per host (context nixos-ci/<host>) and the token is used for the
# API and for flake input fetches. Without it, everything still builds.

set -euo pipefail

repo="${CI_REPO:?}"
state="${STATE_DIRECTORY:?}"
read -ra hosts <<<"${CI_HOSTS:?}"

mkdir -p "$state/roots" "$state/seen"

log=$(mktemp)
trap 'rm -f "$log"' EXIT

token=""
if [[ -s ${RUNTIME_DIRECTORY:-}/github-token ]]; then
  token=$(tr -d '[:space:]' <"$RUNTIME_DIRECTORY/github-token")
  export NIX_CONFIG="access-tokens = github.com=$token"
fi

# The token goes in via a header file so it never shows up in `ps`. The
# process substitution has to sit directly in the curl command: bash closes
# it as soon as an assignment (e.g. into an array) finishes.
gh() {
  if [[ -n $token ]]; then
    curl -sS --fail-with-body --max-time 30 -H @<(printf 'Authorization: Bearer %s\n' "$token") \
      -H 'Accept: application/vnd.github+json' "$@"
  else
    curl -sS --fail-with-body --max-time 30 -H 'Accept: application/vnd.github+json' "$@"
  fi
}

# status SHA STATE CONTEXT DESCRIPTION -- a failed call must never fail the build.
status() {
  [[ -n $token ]] || return 0
  local resp
  if ! resp=$(jq -n --arg state "$2" --arg context "$3" --arg description "${4:0:140}" \
    '{state: $state, context: $context, description: $description}' |
    gh -X POST "https://api.github.com/repos/$repo/statuses/$1" -d @- 2>&1); then
    echo "warning: could not post $2 status for $1 ($3): ${resp:0:300}"
  fi
}

# One-line reason for a failed build, from nix's own output.
failure_reason() {
  local line
  if line=$(grep -m1 -o "hash mismatch in fixed-output derivation '[^']*'" "$log"); then
    :
  elif line=$(grep -m1 -B1 'Reason: builder failed' "$log" | grep -m1 "Cannot build"); then
    :
  elif line=$(grep -m1 '^error:' "$log"); then
    :
  else
    echo "build failed"
    return
  fi
  # Drop the store path's hash and .drv suffix to leave a readable name.
  sed -E "s#/nix/store/[a-z0-9]{32}-##; s#\.drv'?\.?\$##; s#'##g; s#^error: ##" <<<"$line"
}

declare -A want # target name -> commit

main_rev=$(git ls-remote "https://github.com/$repo.git" refs/heads/main | cut -f1)
[[ -n $main_rev ]] && want[main]=$main_rev

while read -r num sha; do
  want["pr-$num"]=$sha
done < <(
  gh "https://api.github.com/repos/$repo/pulls?state=open&per_page=100" |
    jq -r '.[] | "\(.number) \(.head.sha)"'
)

# A closed PR's roots and marker go; the next gc may then reclaim them.
for marker in "$state"/seen/*; do
  [[ -e $marker ]] || continue
  name=$(basename "$marker")
  if [[ -z ${want[$name]:-} ]]; then
    echo "dropping $name (no longer open)"
    rm -f -- "$marker" "$state/roots/$name"-*
  fi
done

failed=0
for name in "${!want[@]}"; do
  rev=${want[$name]}
  if [[ -f $state/seen/$name && $(cut -d' ' -f1 "$state/seen/$name") == "$rev" ]]; then
    continue
  fi

  echo "== $name @ $rev"
  for host in "${hosts[@]}"; do
    status "$rev" pending "nixos-ci/$host" "building $host"
  done

  ok=1
  for host in "${hosts[@]}"; do
    echo "-- $host"
    if nix build "github:$repo/$rev#nixosConfigurations.$host.config.system.build.toplevel" \
      --out-link "$state/roots/$name-$host" --print-build-logs --keep-going 2>&1 | tee "$log"; then
      status "$rev" success "nixos-ci/$host" "$host built and cached"
    else
      reason=$(failure_reason)
      echo "FAILED: $name @ $rev ($host): $reason"
      status "$rev" failure "nixos-ci/$host" "$host: $reason"
      ok=0
      failed=1
    fi
  done

  # Remember failures too, so a broken commit isn't retried every cycle; a
  # new push to the branch gets a fresh attempt.
  if ((ok)); then echo "$rev ok" >"$state/seen/$name"; else echo "$rev failed" >"$state/seen/$name"; fi
done

exit "$failed"
