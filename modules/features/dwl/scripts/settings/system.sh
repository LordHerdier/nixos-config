# System page: read-only facts about the machine in one notice. Concatenated
# into dwl-settings by scripts.nix; relies on common.sh.

# The first CPU temperature hwmon exposes, e.g. "54°C"; fails when none does.
cpu_temp() {
  local hw
  for hw in /sys/class/hwmon/hwmon*; do
    case $(<"$hw/name") in
      k10temp | coretemp | zenpower)
        [ -r "$hw/temp1_input" ] || continue
        echo "$(($(<"$hw/temp1_input") / 1000))°C"
        return 0
        ;;
      *) ;;
    esac
  done
  return 1
}

# The number in /nix/var/nix/profiles/system-N-link, which is the generation
# the system was last switched to (not necessarily the one booted).
system_generation() {
  local link
  link=$(readlink /nix/var/nix/profiles/system || true)
  link=${link#system-}
  echo "${link%-link}"
}

# "2d 3h 14m", from /proc/uptime: the uptime on PATH is coreutils' (no -p),
# and procps' comes later in the runtime inputs.
uptime_pretty() {
  local s d h m out=''
  read -r s _ </proc/uptime
  s=${s%.*}
  d=$((s / 86400))
  h=$((s % 86400 / 3600))
  m=$((s % 3600 / 60))
  if [ "$d" -gt 0 ]; then out="${d}d "; fi
  echo "${out}${h}h ${m}m"
}

system_summary() {
  echo "gen $(system_generation) · $(uptime_pretty)"
}

system_menu() {
  local os temp
  os=$(sed -n 's/^PRETTY_NAME="\(.*\)"$/\1/p' /etc/os-release)
  temp=$(cpu_temp || true)
  notice "$(
    printf 'host        %s\n' "$(<"/proc/sys/kernel/hostname")"
    printf 'os          %s\n' "${os:-unknown}"
    printf 'kernel      %s\n' "$(uname -r)"
    printf 'generation  %s\n' "$(system_generation)"
    printf 'uptime      %s\n' "$(uptime_pretty)"
    printf 'memory      %s\n' "$(free -h | awk '/^Mem:/ { print $3 " of " $2 " used" }')"
    printf 'disk (/)    %s\n' "$(df -h --output=used,size,pcent / | awk 'NR == 2 { print $1 " of " $2 " (" $3 ")" }')"
    if [ -n "$temp" ]; then
      printf 'cpu temp    %s\n' "$temp"
    fi
  )"
}
