# home/modules/zsh/init/30-oh-my-posh.nix

{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
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
  '';
}

