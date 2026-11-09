# home/modules/zsh/uptime.zsh
#
# coreutils' uptime, the one on PATH, has no -p; this gives it procps' spelling
# ("up 2 days, 3 hours, 14 minutes") and leaves every other call to the real
# one. Included in the shell by init/60-functions.nix, and sourced by motd.sh,
# a separate zsh, through $MOTD_UPTIME (set in init/62-motd.nix).
uptime() {
  if [[ $1 != (-p|--pretty) ]]; then
    command uptime "$@"
    return
  fi
  local s d h m n unit
  local -a parts=()
  read -r s _ < /proc/uptime
  s=${s%.*}
  d=$(( s / 86400 )); h=$(( s % 86400 / 3600 )); m=$(( s % 3600 / 60 ))
  for n unit in $d day $h hour $m minute; do
    (( n )) || continue
    if (( n == 1 )); then parts+=("$n $unit"); else parts+=("$n ${unit}s"); fi
  done
  (( ${#parts} )) || parts=("0 minutes")
  echo "up ${(j:, :)parts}"
}
