# docs

deep dives that don't fit in the top-level `README.md`. that file is the
tour; these are the reference.

| doc | covers |
|-----|--------|
| [architecture.md](architecture.md) | the flake's `mkHost` pattern, module layering (`common`/`features`/`profiles`), how home-manager is wired per host, how to add a host |
| [hosts.md](hosts.md) | what each of the five hosts actually turns on, host by host |
| [features.md](features.md) | catalog of every module under `modules/features/`, with scope and gotchas |
| [kiddo.md](kiddo.md) | the kiddo account on index, end to end — system user, home-manager profile, parental controls, what actually bounds her |
| [secrets.md](secrets.md) | secretspec/pass, the smb credentials file, syncthing device keys — what's checked in vs. what isn't |
| [operations.md](operations.md) | rebuilding, updating inputs, adding a host, known in-flight work, troubleshooting the remote-access/streaming setup |

none of this duplicates the theming, hyprland-lua, or shell/editor sections
of the top-level README — those are already the right level of detail and
live there.
