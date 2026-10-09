# cosmic_atomic

Fedora COSMIC Atomic 44 with extra tools and services baked in: zsh, fish,
starship, NetBird, Cockpit, distrobox and the usual CLI tools. See
[`Containerfile`](Containerfile) for the full list.

Built daily by GitHub Actions and published to
`ghcr.io/angelus788/cosmic_atomic`.

## Switch to this image

From any Fedora Atomic / bootc system:

```bash
sudo bootc switch ghcr.io/angelus788/cosmic_atomic:latest
systemctl reboot
```

After that, `sudo bootc upgrade` (or the automatic update timer) pulls new builds.

## Tags

- `latest`, `44`: newest build
- `44.YYYYMMDD`: a specific day's build, for rolling back

## Build locally

```bash
sudo podman build -t cosmic_atomic -f Containerfile .
```
