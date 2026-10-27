# Build the hosts in $CI_HOSTS for main and for every open PR of $CI_REPO,
# skipping any commit that has already been tried. Results are kept as gc
# roots under $STATE_DIRECTORY/roots, so harmonia keeps serving them.
#
# Retention is bounded by construction: one root per host for main, one per
# host for each *open* PR (re-pointed on every new commit, dropped when the
# PR closes).

set -euo pipefail

repo="${CI_REPO:?}"
state="${STATE_DIRECTORY:?}"
read -ra hosts <<<"${CI_HOSTS:?}"

mkdir -p "$state/roots" "$state/seen"

declare -A want # target name -> commit

main_rev=$(git ls-remote "https://github.com/$repo.git" refs/heads/main | cut -f1)
[[ -n $main_rev ]] && want[main]=$main_rev

while read -r num sha; do
  want["pr-$num"]=$sha
done < <(
  curl -fsS --max-time 30 "https://api.github.com/repos/$repo/pulls?state=open&per_page=100" |
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
  ok=1
  for host in "${hosts[@]}"; do
    echo "-- $host"
    if ! nix build "github:$repo/$rev#nixosConfigurations.$host.config.system.build.toplevel" \
      --out-link "$state/roots/$name-$host" --print-build-logs --keep-going; then
      echo "FAILED: $name @ $rev ($host)"
      ok=0
      failed=1
    fi
  done

  # Remember failures too, so a broken commit isn't retried every cycle; a
  # new push to the branch gets a fresh attempt.
  if ((ok)); then echo "$rev ok" >"$state/seen/$name"; else echo "$rev failed" >"$state/seen/$name"; fi
done

exit "$failed"
