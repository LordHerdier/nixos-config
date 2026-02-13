# home/modules/zsh/init.nix

{ ... }:

{
  programs.zsh.profileExtra = ''
    [[ -z $PS1 ]] && return

    # Daily MOTD: run ~/bin/wut once per day
    local wut_cmd="$HOME/bin/wut"
    local stamp_file="$HOME/.last_wut_date"
    local today=$(date +%F)

    if [[ -x $wut_cmd ]]; then
      if [[ ! -f $stamp_file ]] || [[ $(<"$stamp_file") != $today ]]; then
        "$wut_cmd"
        print -r -- $today >| "$stamp_file"
      fi
    fi

    # Use Windows GnuPG inside WSL
    path+=("/mnt/c/Program Files (x86)/GnuPG/bin")
    export PATH
    export GPG_TTY=$(tty)
    unset GNUPGHOME
  '';

  programs.zsh.initContent = ''
    # Only interactive shells
    [[ -o interactive ]] || return

    # make autosuggestions not stall the shell
    export ZSH_AUTOSUGGEST_USE_ASYNC=1
    export ZSH_AUTOSUGGEST_STRATEGY=(history)
    export ZSH_HIGHLIGHT_MAXLENGTH=300

    # Paths
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/bin:$PATH"

    path+=(
        "/mnt/c/Windows/System32"
        "/mnt/c/Windows"
        "/mnt/c/Program Files (x86)/GnuPG/bin"
        "/mnt/c/Program Files/Tailscale"
      )
    export PATH

    # Initialize zoxide for zsh - only if installed
    if command -v zoxide &> /dev/null; then
      eval "$(zoxide init zsh --cmd cd)"
    fi

    # XDG
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"

    # Editor
    export EDITOR=nvim

    # Oh-my-posh theme selection
    if [[ -f "$HOME/.omp_current" ]]; then
      OMPTHEME="$(tr -d '\n' < "$HOME/.omp_current")"
    else
      OMPTHEME="pure"
    fi
    export OMPTHEME

    if command -v oh-my-posh >/dev/null 2>&1; then
      _omp_json="$HOME/.oh-my-posh/themes/''${OMPTHEME}.omp.json"
      _omp_yaml="$HOME/.oh-my-posh/themes/''${OMPTHEME}.omp.yaml"

      if [[ -f "$_omp_json" ]]; then
        eval "$(oh-my-posh init zsh --config "$_omp_json")"
      elif [[ -f "$_omp_yaml" ]]; then
        eval "$(oh-my-posh init zsh --config "$_omp_yaml")"
      else
        eval "$(oh-my-posh init zsh)"
        echo "oh-my-posh: theme ''${OMPTHEME} not found, using default." >&2
      fi

      unset _omp_json _omp_yaml
    fi

    # ssh-agent (WSL-proof)
    if [[ -z "$SSH_AUTH_SOCK" || ! -S "$SSH_AUTH_SOCK" ]]; then
      export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR:-/tmp}/ssh-agent.sock"
    fi
    if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
      mkdir -p "''${XDG_RUNTIME_DIR:-/tmp}"
      eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" >/dev/null
    fi

    # History
    HISTFILE=~/.zsh_history
    HISTSIZE=3000
    SAVEHIST=5000
    setopt append_history inc_append_history share_history
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    setopt HIST_IGNORE_SPACE

    # Functions from my scriptlets
    please() {
      local last_cmd
      last_cmd=$(fc -ln -1)
      echo "🙏 sudo $last_cmd"
      eval "sudo $last_cmd"
    }

    theme() {
      if [[ -z "$1" ]]; then
        echo "Usage: omp-theme <theme>"
        return 1
      fi

      local newtheme="$1"
      local dir="$HOME/.oh-my-posh/themes"
      local json="$dir/''${newtheme}.omp.json"
      local yaml="$dir/''${newtheme}.omp.yaml"
      local config

      if [[ -f "$json" ]]; then
        config="$json"
      elif [[ -f "$yaml" ]]; then
        config="$yaml"
      else
        echo "No theme file found for ''${newtheme} (tried .json and .yaml)."
        return 1
      fi

      echo "$newtheme" > ~/.omp_current
      export OMPTHEME="''${newtheme}"
      eval "$(oh-my-posh init zsh --config "$config")"
      echo "OMP theme switched to ''${newtheme} ($(basename "$config"))."
    }

    mkcd() { mkdir -p -- "$1" && cd -P -- "$1"; }

    copypath() {
      [[ -z "$1" ]] && return 1
      realpath "$1" | clip.exe
    }

    themes() {
      local selection
      local -a files names

      files=(~/.oh-my-posh/themes/*.omp.(json|yaml)(N))
      names=()
      for f in $files; do
        names+=("''${f:t}")
      done

      names=(''${names[@]%.omp.json})
      names=(''${names[@]%.omp.yaml})

      selection=$(print -l -- ''${(ou)names} | fzf --height=50% --reverse --prompt="Select theme ▶ ")
      if [[ -n "$selection" ]]; then
        theme "$selection"
      else
        echo "No theme selected, nothing changed."
      fi
    }

    # Source optional private extras (kept as external files)
    for file in ~/.secrets.zsh ~/.ssh_aliases.zsh; do
      [[ -f "$file" ]] && source "$file"
    done
  '';
}

