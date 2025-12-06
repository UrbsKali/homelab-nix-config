# Homelab NixOS Configuration

This repository contains the NixOS Flake configuration for my homelab infrastructure. It is designed to be modular, secure, and reproducible.

## 🏗️ Architecture

The configuration is built using **Nix Flakes** and structured into reusable modules.

* **Hosts**:
  * `erotips` (192.168.1.44): Media server & Docker host with LVM storage.
  * `creamychocolat` (192.168.1.35): General purpose server.
* **Core Modules**: Common configuration applied to all hosts (Security, Networking, Users, Shell).
* **Services**: Specific service definitions (Docker, Tunnels).

## 🚀 Quick Start

### Prerequisites

* NixOS installed on the target machine.
* `git` and `sops` installed.
* SSH access to the machine.

### Installation

1. **Clone the repository:**

    ```bash
    git clone https://github.com/UrbsKali/homelab-nix-config.git /etc/nixos
    cd /etc/nixos
    ```

2. **Setup Secrets:**
    Ensure your Age private key is present at `/var/lib/sops-nix/key.txt`.

3. **Apply Configuration:**

    ```bash
    # For erotips
    sudo nixos-rebuild switch --flake .#erotips

    # For creamychocolat
    sudo nixos-rebuild switch --flake .#creamychocolat
    ```

## 🔐 Key Features

* **Security Hardened**: Kernel hardening, AppArmor, Auditd, Fail2Ban, and restricted SSH.
* **Secret Management**: All secrets are encrypted using **Sops** with **Age**.
* **Modular Design**: Configuration is split into logical components (Networking, Security, System, etc.).
* **Zsh & Starship**: Pre-configured shell environment.

For detailed documentation, please refer to [doc.md](./doc.md).
