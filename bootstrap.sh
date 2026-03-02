#!/bin/bash

# Exit on error
set -e

DISTROS=(arch)

echo "Starting development machine setup..."

# Detect Linux Distribution
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    echo "Detected OS: $NAME ('$ID' with '$ID_LIKE' base)"
fi

DISTRO=""
if [[ " ${DISTROS[@]} " =~ " ${ID} " ]]; then
  DISTRO=$ID
elif [[ " ${DISTROS[@]} " =~ " ${ID_LIKE} " ]]; then
  DISTRO=$ID_LIKE
else
  echo "Unsupported distribution"
  echo "Currently only following distros are supported: ${DISTROS[@]}"
  exit 1
fi

echo "Detected $OS"

# Function to install packages based on distribution
install_prerequisites() {
    case "$OS" in
        ubuntu|debian|pop|kali|linuxmint)
            sudo apt-get update
            sudo apt-get install -y git ansible software-properties-common
            ;;
        fedora|rhel|centos|rocky|almalinux)
            sudo dnf install -y git ansible
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm git ansible
            ;;
        *)
            echo "Unsupported OS: $OS. Please install git and ansible manually."
            exit 1
            ;;
    esac
}

# Install Git and Ansible if not present
if ! command -v git &> /dev/null || ! command -v ansible &> /dev/null; then
    echo "Installing Git and Ansible..."
    install_prerequisites
fi

# Run Ansible Playbook
echo "Laze: Setup running. Go take a nap."
ansible-playbook -i inventory playbook.yml --ask-become-pass

echo "✅ Laze: Setup complete!"
