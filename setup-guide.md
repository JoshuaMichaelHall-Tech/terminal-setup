# Setup Guide

This document provides detailed instructions for setting up the terminal development environment. You can either use the master installer for a complete setup or install individual components as needed.

## Prerequisites

Before you begin, make sure you have the following prerequisites installed:

- **Git**: For cloning the repository and version control
- **Ruby**: For running the installation scripts
- **Homebrew** (macOS): For installing additional tools

## Installation Options

### Option 1: Full Installation

The full installation sets up all components of the terminal environment:

```zsh
# Clone the repository
git clone https://github.com/JoshuaMichaelHall-Tech/terminal-setup.git
cd terminal-setup

# Make the installation script executable
chmod +x install.rb

# Run the installation script
ruby install.rb
```

When prompted, select option 1 for a full installation.

### Option 2: Component-Specific Installation

If you only want to install specific components, you can run their individual installation scripts:

```zsh
# Make the script executable
chmod +x bin/component_installer.rb

# Install a specific component
ruby bin/zsh_installer.rb    # Install Zsh configuration
ruby bin/nvim_installer.rb   # Install Neovim configuration
ruby bin/tmux_installer.rb   # Install tmux configuration
ruby bin/notes_installer.rb  # Install notes system
```

### Option 3: Minimal Update

If you already have some components installed and just want to update their configurations:

```zsh
ruby install.rb --mode minimal

# Or update a specific component
ruby bin/component_installer.rb --minimal
```

## Component Installation Details

Each component's installer performs the following actions:

### Core Component

- Creates essential directories (~/bin, ~/.config, etc.)
- Sets up basic environment structure
- Installs required tools using Homebrew

### Zsh Configuration

- Installs Oh My Zsh if not already installed
- Installs Powerlevel10k theme
- Sets up auto-suggestions and syntax highlighting plugins
- Configures custom aliases, functions, and settings

### Neovim Configuration

- Creates Neovim configuration directories
- Installs Lazy.nvim plugin manager
- Configures LSP (Language Server Protocol)
- Sets up custom key mappings and plugins

### tmux Configuration

- Creates tmux configuration file
- Installs tmux Plugin Manager (TPM)
- Configures custom key bindings and settings
- Sets prefix key to Ctrl+a

### Notes System

- Creates directory structure for notes
- Sets up templates for daily, project, and learning notes
- Installs Neovim plugin for notes management
- Configures Git for version control of notes

## Post-Installation Configuration

After installation, follow these steps to complete your setup:

### 1. Set Zsh as Default Shell

```zsh
chsh -s $(which zsh)
```

### 2. Configure Powerlevel10k

Run the Powerlevel10k configuration wizard:

```zsh
p10k configure
```

### 3. Install Neovim Plugins

Open Neovim to trigger automatic plugin installation:

```zsh
nvim
```

Wait for the plugins to install. You might need to restart Neovim after installation.

### 4. Install tmux Plugins

Start a tmux session:

```zsh
tmux
```

Press `Ctrl+a` followed by `I` (capital I) to install tmux plugins.

### 5. Set Up Nerd Fonts

For the best experience, configure your terminal to use a Nerd Font:

- **iTerm2**: Preferences → Profiles → Text → Font → Select "JetBrainsMono Nerd Font"
- **VS Code**: Settings → Terminal › Integrated: Font Family → "JetBrainsMono Nerd Font"

## Troubleshooting

If you encounter issues with any component, you can run its troubleshooter script:

```zsh
ruby bin/component_troubleshooter.rb --fix
```

Replace `component` with the specific component name (core, zsh, nvim, tmux, notes).

## Uninstallation

To remove a specific component:

```zsh
ruby bin/component_uninstaller.rb
```

The uninstaller will create a backup of your configuration before removing anything.

## Workflow Examples

For detailed examples of how to use this terminal environment for development and note-taking, see the [TUTORIAL.md](TUTORIAL.md) file.
