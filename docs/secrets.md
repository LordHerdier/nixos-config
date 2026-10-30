# secrets

the nix store is world-readable, so nothing that actually needs to stay
secret is declared as a nix value in this repo. there are three separate
mechanisms in play, by what they're protecting.

## secretspec + pass (`secretspec.toml`)

`secretspec.toml` (checked in) declares *what* secrets exist and where
they come from — never the secret values themselves:

```toml
[providers]
local = "pass://syncthing/keys/{key}"

[profiles.default]
Index = { description = "...", providers = [ "local" ] }
Apthos = { description = "...", providers = [ "local" ] }
```

the actual values live in `pass` (the unix password manager), keyed as
`syncthing/keys/<Host>`. `parts/dev.nix`'s `devShells.default` carries both
`secretspec` and `pass` so `secretspec run -- <cmd>` can inject the
declared secrets as env vars without them ever touching a file in this
repo.

currently the only thing backed this way is each host's **syncthing REST
API key** — needed to query a running host's syncthing instance
remotely (e.g. to read off its device ID when adding a new host to the
mesh; see `modules/features/syncthing.nix` and
[features.md](features.md)). populate one with:

```sh
pass insert syncthing/keys/Index
```

and read it back with:

```sh
secretspec run -- curl -s -H "X-API-Key: $Index" 127.0.0.1:8384/rest/system/status | jq -r .myID
```

(run on the host in question, over `ssh` if remote — the GUI is
localhost-only by design, see the feature module.)

## spotify-player client id (`pass`, read at runtime)

`home/modules/spotify-player.nix` sets `client_id_command` to
`pass show spotify-player/client_id`, so spotify-player fetches its
Spotify client id from the password store each launch instead of it
being baked into `app.toml` in the nix store. populate it with:

```sh
pass insert spotify-player/client_id
```

## root-only files outside the nix store

the NAS SMB credentials (`modules/features/cifs-mounts.nix`) are a flat
file at `/etc/nixos-secrets/smb-creds`, mode 600, root-owned, created by
hand once:

```sh
sudo install -d -m 700 /etc/nixos-secrets
sudo install -m 600 /dev/null /etc/nixos-secrets/smb-creds
sudoedit /etc/nixos-secrets/smb-creds
```

```
username=YOUR_USER
password=YOUR_PASSWORD
domain=WORKGROUP   # optional
```

this directory is not in the repo and not managed by nix at all — it's
deliberately outside both.

## generated at first run, never checked in

`modules/features/open-webui.nix`'s session-signing secret
(`WEBUI_SECRET_KEY`) is generated once by a oneshot systemd unit into
`/opt/open-webui/webui-secret.env` with `openssl rand -hex 32`, gated by
`ConditionPathExists = "!...webui-secret.env"` so it's never regenerated
(and sessions never invalidated) on a later rebuild.

## what's in `.gitignore`

`secrets.nix` / `**/secrets.nix` are ignored repo-wide, as a backstop —
there is currently no file by that name in the tree; the mechanisms
above are what's actually used. `result`/`result-*` (nix build symlinks),
`.direnv`, `.envrc` and `*.bak` are the rest of the ignore list, unrelated
to secrets.
