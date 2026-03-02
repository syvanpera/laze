# Laze - Lazy man's development machine setup

An Ansible-based project to quickly set up a development machine on various Linux distributions.

## Features

- **Single Script Entry:** One `bootstrap.sh` to install Git/Ansible and run the playbook.
- **Cross-Distro Support:** Detects your OS and installs the correct packages (supports Debian/Ubuntu, Fedora/RHEL, and Arch).
- **Common & Distro-Specific Packages:** Easily define packages that are installed everywhere vs. those only needed on certain distros.
- **Decoupled Dotfiles:** Integrates with your separate dotfiles repository, which can also be installed independently.

## Getting Started

On a fresh Linux installation, you can run the bootstrap script directly (assuming you've cloned this or downloaded the script):

```bash
chmod +x bootstrap.sh
./bootstrap.sh
curl -sL https://raw.githubusercontent.com/syvanpera/laze/refs/heads/main/bootstrap.sh | bash
```

## Configuration

### Package Lists
Package lists are located in `roles/packages/vars/`:
- `packages_common.yml`: Packages for all distributions.
- `packages_Debian.yml`: Debian/Ubuntu/Mint specific.
- `packages_RedHat.yml`: Fedora/RHEL specific.
- `packages_Archlinux.yml`: Arch specific.

### Package Mapping (Translation)
Since package names vary across distributions (e.g., `build-essential` vs. `base-devel`), you can use the `package_map` dictionary in each distro's YAML file. 

If a package name from `common_packages` is found in the `package_map`, it will be replaced by the mapped name. This allows you to list `build-essential` in `common_packages` and have it correctly installed on all systems.

### Dotfiles
Configure your dotfiles repository in `group_vars/all.yml`:
- `dotfiles_repo_url`: The URL of your dotfiles repository.
- `dotfiles_repo_version`: The branch, tag, or commit hash to check out (default: `main`).
- `dotfiles_dest`: Where to clone the repository (default: `~/.dotfiles`).
- `dotfiles_install_command`: The command to run to install your dotfiles (e.g., `./install.sh`).

For details on how the dotfiles are managed (with GNU Stow) and how to add new configurations, see the [dotfiles/README.md](dotfiles/README.md).

## Independent Dotfiles Installation

The dotfiles repository can be installed independently of this project on any machine.
Simply clone your dotfiles repository and run `./install.sh`.
This requires GNU Stow to be installed.
