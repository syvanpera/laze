#!/bin/bash

# Exit on error
set -e

echo "Starting development machine setup..."

# Detect Linux Distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ -f /etc/debian_version ]; then
    OS=debian
else
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

echo "Detected OS: $OS"

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
