# Laze - Project Context & Architecture

This document provides a technical overview of the `laze` project for Gemini CLI agents. Use this to maintain consistency and understand the existing automation patterns.

## Project Goal
A cross-distribution Ansible-based setup for rapid development machine provisioning. It handles system updates, package installation (Native, AUR, NPM), SSH key generation, and GNU Stow-managed dotfiles.

## Core Architecture

### 1. Bootstrapping
- **`bootstrap.sh`**: The entry point. Detects the OS (`apt`, `dnf`, `pacman`), installs Git/Ansible, and runs the playbook.

### 2. Variable Management
- **Global**: `group_vars/all.yml` (URLs, emails, paths).
- **Distribution Specific**: `vars/packages_{{ ansible_facts['os_family'] }}.yml`.
- **Strategy**: Uses a `pre_tasks` block in `playbook.yml` to load variables globally based on discovered facts.

### 3. Roles
- **`system`**: Updates caches, handles system-level configs (e.g., `interception-tools` for caps2esc). Runs with `become: yes`.
- **`ssh`**: Generates Ed25519 keys if missing and prints the public key. Runs as the user.
- **`packages`**: 
  - **Native**: Uses `package_map` to translate generic names (e.g., `build-essential`) to distro-specific names.
  - **NPM**: Installs global packages to `~/.npm-global` (configured via `npm config set prefix`).
  - **AUR (Arch)**: Bootstraps `paru` if missing. Grants temporary `NOPASSWD` for `/usr/bin/pacman` to allow non-interactive AUR builds. Runs as user (`become: no`).
- **`services`**: Enables/starts systemd services defined in `services` variable. Runs with `become: yes`.
- **`dotfiles`**: Clones a separate repo and runs its `install.sh`. Skips if already cloned.

### 4. Dotfiles (GNU Stow)
These are located in another repository, which is checked out during the bootstrap process.
- **`home/`**: Symlinked to `~/*`.
- **`config/`**: Symlinked to `~/.config/*`.
- **`install.sh`**: Standalone wrapper for `stow`.

## Development Guidelines
- **Fact Usage**: Always use the `ansible_facts['...']` syntax to avoid deprecation warnings.
- **Permission Scoping**: Be surgical with `become`. Native packages need it; AUR, NPM, SSH, and Dotfiles should generally run as the user.
- **Package Mapping**: When adding common packages that vary in name, update the `package_map` in `vars/packages_*.yml`.
- **Cross-Distro Safety**: Always use `when: ansible_facts['os_family'] == "..."` for distro-specific logic.

## File Map
- `playbook.yml`: Main orchestration.
- `vars/`: Distro-specific package lists and service definitions.
- `roles/`: Modular logic for each setup phase.
- `dotfiles/`: Standalone configuration repository.
