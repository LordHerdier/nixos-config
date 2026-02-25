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

    randomtheme() {
      local -a files names
      
      # Grab all json/yaml theme files, silently failing if none exist (N flag)
      files=(~/.oh-my-posh/themes/*.omp.(json|yaml)(N))
      
      if [[ ''${#files[@]} -eq 0 ]]; then
        echo "No themes found in ~/.oh-my-posh/themes/"
        return 1
      fi

      # Extract base names
      names=()
      for f in $files; do
        names+=("''${f:t}")
      done

      # Strip extensions
      names=(''${names[@]%.omp.json})
      names=(''${names[@]%.omp.yaml})

      # Select a random theme (ZSH arrays are 1-indexed)
      local random_theme="''${names[$((RANDOM % ''${#names[@]} + 1))]}"
      
      # Pass the selected theme to your existing theme switcher
      theme "$random_theme"
    }

    mkcd() { mkdir -p -- "$1" && cd -P -- "$1"; }

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

    dumpfiles() {
      local ext
      ext="$1"
      if [[ -z "$ext" ]]; then
        echo "Usage: dumpfiles <extension>"
        return 1
      fi

      ext="''${ext#.}"

      find . -type f -name "*.''${ext}" -print0 \
        | sort -z \
        | while IFS= read -r -d $'\0' f; do 
            echo "==== $f ===="
            cat -- "$f"
            echo
          done
    }
  '';
}
