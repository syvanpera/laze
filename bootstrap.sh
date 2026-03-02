#!/bin/bash

set -euo pipefail

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
        arch|cachyos|manjaro)
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

# Resolve project directory. If script is piped via curl, clone project files.
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd || pwd)"
PROJECT_DIR="$SCRIPT_DIR"

if [ ! -f "$PROJECT_DIR/playbook.yml" ] || [ ! -f "$PROJECT_DIR/inventory" ]; then
    PROJECT_DIR="$HOME/laze"
    if [ ! -d "$PROJECT_DIR/.git" ]; then
        echo "Project files not found locally. Cloning repository to $PROJECT_DIR..."
        git clone --depth 1 --branch main https://github.com/syvanpera/laze.git "$PROJECT_DIR"
    else
        echo "Using existing repository at $PROJECT_DIR."
    fi
fi

if [ ! -f "$PROJECT_DIR/playbook.yml" ] || [ ! -f "$PROJECT_DIR/inventory" ]; then
    echo "Repository at $PROJECT_DIR is missing required files."
    exit 1
fi

# Run Ansible playbook
echo "Laze: Setup running. Go take a nap."
cd "$PROJECT_DIR"
ansible-playbook -i inventory playbook.yml --ask-become-pass

echo "✅ Laze: Setup complete!"
