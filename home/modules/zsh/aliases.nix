# home/modules/zsh/aliases.nix

{ ... }:

{
  programs.zsh.shellAliases = {
    # Basics
    c = "clear";
    ccd = "clear && cd ~";
    cdc = "ccd";
    q = "exit";
    ".." = "cd ../";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    ip = "ip -h -c";
    reload = "source ~/.zshrc && echo \"💥 zshrc reloaded!\"";
    tree = "tree -C --dirsfirst";

    # Editors
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
    "v." = "nvim .";
    "v.." = "nvim ..";
    em = "emacs -nw";
    emacs = "emacs -nw";

    # Quick commands
    y = "yazi";
    browse = "yazi";
    nb = "newsboat && clear";
    path = "realpath";

    # Nix
    nix-rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#Charlie-Laptop";
    nix-update-dotfiles = "sudo nix flake lock --update-input dotfiles /etc/nixos";

    # Tools
    ls = "eza -gh --group-directories-first";
    la = "eza -lgha --group-directories-first";
    ll = "eza -lg --group-directories-first";

    # WSL helpers
    ts = "tailscale.exe";
    files = "explorer.exe .";

    # Python venv
    venvc = "python3 -m venv venv";
    venva = "source venv/bin/activate";

    # Docker compose
    dc = "docker compose";
    dcu = "docker compose up";
    dcud = "docker compose up -d";
    dcuf = "docker compose up --force-recreate";
    dcudf = "docker compose up -d --force-recreate";
    dcd = "docker compose down";
    dcs = "docker compose stop";
    dcp = "docker compose pull";
    dcl = "docker compose logs";
    dclf = "docker compose logs --follow";
    dcr = "docker compose run";

    # “bruh”
    npm = "/usr/bin/npm";

    # Workflow
    nmapc = "nmap -p 1-1000,41794,41795,41796 -Pn -T4";
  };
}

