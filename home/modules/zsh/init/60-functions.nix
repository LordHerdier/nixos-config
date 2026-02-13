# home/modules/zsh/init/60-functions.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
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
  '';
}

