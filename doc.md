# Homelab Documentation

This document provides a detailed overview of the server configuration, modules, and maintenance procedures.

## 📚 Table of Contents

1. [Hosts](#hosts)
2. [Core Modules](#core-modules)
3. [Security](#security)
4. [Storage](#storage)
5. [Secrets Management](#secrets-management)
6. [Maintenance](#maintenance)

---

## 🖥️ Hosts

### 1. Erotips

* **Role**: Media Server & Docker Host
* **IP Address**: `192.168.1.44`
* **Interface**: `enp6s0`
* **Storage**:
  * Boot: `/dev/sdc` (GRUB)
  * Data: LVM Volume Group `media-vol` on `/dev/sda` + `/dev/sdb`
  * Mount: `/home/dvb/docker/volumes/media/_data`
* **Services**:
  * Docker (with auto-prune)
  * Cloudflare Tunnel
  * Media Stack (Ports: 5055, 8096, 7878, 8989, 5080, 9696)

### 2. Creamychocolat

* **Role**: General Purpose Server / VM
* **IP Address**: `192.168.1.35`
* **Interface**: `enp0s3`
* **Boot**: `/dev/sda` (GRUB)

---

## 🧩 Core Modules

The configuration is split into modular files located in `modules/core/`:

| Module | Description |
| :--- | :--- |
| `default.nix` | Entry point importing all other modules. |
| `nix.nix` | Nix settings, experimental features, and garbage collection. |
| `locale.nix` | Timezone (`Europe/Paris`), Locale (`fr_FR`), and Keymap (`azerty`). |
| `networking.nix` | NetworkManager and Firewall configuration. |
| `security.nix` | Hardening, Fail2Ban, Sops, and SSH settings. |
| `users.nix` | User definitions (`urbai`) and SSH keys. |
| `packages.nix` | Common system packages (git, vim, htop, etc.). |
| `system.nix` | Systemd tweaks, watchdog, and state version. |
| `shell.nix` | Zsh and Starship configuration. |

---

## 🛡️ Security

The system is hardened with the following features:

* **Kernel Hardening**: Sysctl tweaks to prevent IP spoofing, redirect attacks, and disable Magic SysRq.
* **AppArmor**: Enabled for mandatory access control.
* **Auditd**: System audit daemon enabled.
* **SSH**:
  * Password authentication DISABLED.
  * Root login DISABLED.
  * Public Key authentication ONLY.
  * Forwarding (TCP, X11, Agent) DISABLED.
* **Fail2Ban**: Bans IPs for 1 hour after 5 failed SSH attempts.
* **Sudo**: Restricted to `wheel` group.

---

## 💾 Storage (Erotips)

The `erotips` host uses LVM to combine two disks into a single logical volume for media storage.

* **Physical Volumes**: `/dev/sda`, `/dev/sdb`
* **Volume Group**: `media-vol`
* **Logical Volume**: `media-lv`
* **Mount Point**: `/home/dvb/docker/volumes/media/_data`

**Setup Script**: A script `setup-lvm.sh` is available in the root to initialize this setup (WARNING: Destructive).

---

## 🔑 Secrets Management

Secrets are managed using **Sops** and **Age**.

* **File**: `secrets/secrets.yaml`
* **Config**: `.sops.yaml`
* **Key Location**: `/var/lib/sops-nix/key.txt` on the host.

### Adding/Editing Secrets

To edit secrets, run:

```bash
sops secrets/secrets.yaml
```

### Key Rotation

If you need to rotate keys or add a new host:

1. Add the new host's Age public key to `.sops.yaml`.
2. Run `sops updatekeys secrets/secrets.yaml`.

---

## 🛠️ Maintenance

### Updating the System

To update the flake inputs (nixpkgs, etc.) and rebuild:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
```

### Garbage Collection

Garbage collection is automated to run weekly, deleting generations older than 30 days. To run manually:

```bash
nix-collect-garbage -d
```
