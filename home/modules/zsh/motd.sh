#!/usr/bin/env zsh
# home/modules/zsh/motd.sh
#
# Body of the `motd` command (see init/62-motd.nix). Runs as a standalone zsh
# script (uses `print -P`), so edit freely; changes apply after a rebuild.

print -P "%F{cyan}%B$(date '+%A, %d %B %Y')%b%f"
curl -s --max-time 3 "wttr.is/?1pq" || true
print ""

source "${MOTD_UPTIME:?}"  # uptime -p, which coreutils' uptime lacks
print -P "%F{8}up:%f ${$(uptime -p)#up }"
# print -P "%F{8}load:%f $(cut -d' ' -f1-3 /proc/loadavg)"

disk="$(df -h --output=used,size,pcent / | tail -1 | awk '{print $1 " / " $2 " (" $3 ")"}')"
print -P "%F{8}disk (/):%f ${disk//\%/%%}"

# Nix flake lock
zmodload zsh/datetime
last=$(jq -r '.nodes[.nodes.root.inputs.nixpkgs].locked.lastModified' /etc/nixos/flake.lock)
age=$(( (EPOCHSECONDS - last) / 86400 ))
print -P "%F{8}nixpkgs pin:%f ${age} days old"

# /etc/nixos repo state
if git -C /etc/nixos rev-parse --git-dir &>/dev/null; then
  dirty=$(git -C /etc/nixos status --porcelain 2>/dev/null | wc -l)
  ahead=$(git -C /etc/nixos rev-list --count '@{u}..HEAD' 2>/dev/null)
  behind=$(git -C /etc/nixos rev-list --count 'HEAD..@{u}' 2>/dev/null)
  parts=()
  (( dirty ))  && parts+=("%F{yellow}${dirty} uncommitted%f")
  (( ahead ))  && parts+=("%F{yellow}${ahead} unpushed%f")
  (( behind )) && parts+=("%F{yellow}${behind} behind upstream%f")
  (( $#parts )) || parts=("%F{green}clean%f")
  print -P "%F{8}/etc/nixos:%f ${(j:, :)parts}"
fi

# Tailscale
if (( $+commands[tailscale] )); then
  ts=$(tailscale status --json 2>/dev/null)
  if [[ -n $ts ]]; then
    state=$(jq -r '.BackendState // "unknown"' <<<"$ts")
    exitnode=$(jq -r '(.ExitNodeStatus.ID // "") as $id
      | if $id == "" then empty else ([.Peer[]? | select(.ID == $id) | .HostName][0] // empty) end' <<<"$ts" 2>/dev/null)
    if [[ $state == Running ]]; then
      line="%F{green}up%f"
      [[ -n $exitnode ]] && line+=" (exit node: ${exitnode})"
    else
      line="%F{yellow}${state:l}%f"
    fi
    print -P "%F{8}tailscale:%f ${line}"
  else
    print -P "%F{8}tailscale:%f %F{red}not running%f"
  fi
fi

# Builder cache + offload reachability. Hosts come from the generated nix
# config (substituters in nix.conf, /etc/nix/machines), not hardcoded.
_motd_probe() {  # host port -> 0 if a TCP connect succeeds within 3 s
  # ztcp has no timeout option, so run it in a child zsh under timeout(1).
  timeout 3 zsh -c 'zmodload zsh/net/tcp
    ztcp "$1" "$2" 2>/dev/null || exit 1
    ztcp -c $REPLY' _ "$1" "$2"
}
if [[ -r /etc/nix/nix.conf ]]; then
  for sub in ${(s: :)${${(M)${(f)"$(</etc/nix/nix.conf)"}:#substituters*}#*=}}; do
    [[ $sub == http://* ]] || continue
    hp=${${sub#http://}%%/*}
    if _motd_probe "${hp%%:*}" "${${hp##*:}:-80}"; then
      print -P "%F{8}cache:%f %F{green}reachable%f (${hp})"
    else
      print -P "%F{8}cache:%f %F{red}unreachable%f (${hp}), using cache.nixos.org"
    fi
  done
fi
if [[ -r /etc/nix/machines ]]; then
  mlines=("${(@f)$(</etc/nix/machines)}")
  bhost=${mlines[1]#*://}
  bhost=${bhost#*@}
  bhost=${bhost%% *}
  if [[ -n $bhost ]]; then
    if _motd_probe "$bhost" 22; then
      print -P "%F{8}builder:%f %F{green}reachable%f (${bhost})"
    else
      print -P "%F{8}builder:%f %F{red}unreachable%f (${bhost}), builds will run locally"
    fi
  fi
fi

print ""

# Machine-local additions that shouldn't live in the repo
if [[ -r ~/.config/motd.zsh ]]; then source ~/.config/motd.zsh; fi
