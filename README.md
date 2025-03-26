# Terminal Development Environment

> **⚠️ DISCLAIMER: This is a work in progress. I am still working out bugs and refining the configuration. Use at your own risk and please report any issues you encounter.**

A highly customized terminal-based development environment using Neovim, tmux, and command-line tools optimized for software engineering workflows.

![Version](https://img.shields.io/badge/version-0.1.0--alpha-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

This repository contains my terminal-based development environment configuration, designed to maximize productivity through a keyboard-driven workflow. By leveraging terminal-based tools, this setup minimizes distractions and resource usage while providing a consistent environment across all my machines.

## Key Features

- **Mouse-Free Workflow**: Complete development environment navigable entirely from the keyboard
- **Modular Configuration**: Easily adaptable to different projects and languages
- **Resource Efficiency**: Minimal CPU and memory usage compared to GUI editors
- **Consistent Experience**: Same environment locally and on remote servers
- **Version-Controlled**: Track all configuration changes with Git

## Components

### Core Tools
- **Neovim**: Text editor with full LSP support and custom keybindings
- **tmux**: Terminal multiplexer for session management
- **Zsh**: Shell with custom configuration and aliases

### Plugins & Extensions
- **Lua-based Neovim config**: Modern plugin system with Lazy.nvim
- **LSP Integration**: Code intelligence for multiple languages
- **Telescope**: Fuzzy finder for files and text
- **Treesitter**: Advanced syntax highlighting
- **Git Integration**: Fugitive and other Git tools

## Getting Started

### Option 1: Automated Installation (Recommended)

The automated installation script will back up your existing configurations, set up a clean environment, and install all required components.

```bash
# Clone the repository
git clone https://github.com/JoshuaMichaelHall-Tech/terminal-setup.git
cd terminal-setup

# Make the installation script executable
chmod +x install.sh

# Run the installation script
./install.sh
```

#### Post-Installation Steps

After running the installation script, you'll need to:

1. **Use Zsh:** This environment is designed specifically for Zsh, not Bash.
   - If you're not already using Zsh: `chsh -s $(which zsh)`
   - If using VS Code: Go to Settings → Terminal → Default Profile → Select 'zsh'
   - Start a new terminal window (don't source `.zshrc` from Bash!)

2. **Configure Nerd Fonts:** The environment uses special fonts for icons and symbols.
   - In iTerm2: Preferences → Profiles → Text → Font → Select 'JetBrainsMono Nerd Font'
   - In VS Code: Settings → Terminal › Integrated: Font Family → 'JetBrainsMono Nerd Font'
   - Font size of 14-16pt is recommended for best readability

3. **Configure Powerlevel10k:** Run `p10k configure` in your Zsh terminal.

4. **Install Neovim Plugins:** Open Neovim with `nvim` and wait for plugins to install.

5. **Install tmux Plugins:** In tmux, press `Ctrl+a` followed by `I` to install plugins.

6. **Restart Your Terminal:** For all changes to take effect.

If fonts are displaying incorrectly (missing icons, broken symbols), make sure you've:
- Installed the Nerd Fonts using the script
- Configured your terminal emulator to use the Nerd Font
- Selected a compatible font size and terminal color scheme

The script creates a backup of your previous configuration in `~/terminal_env_backup_TIMESTAMP/`. If you need to restore your previous setup, you can copy files from this directory back to their original locations.

### Option 2: Manual Installation

For those who prefer more control over the installation process, please see the [Setup Guide](./SETUP.md) for detailed step-by-step instructions and the [Tutorial](./TUTORIAL.md) for workflow examples.
```

## Current Status

This project is actively being developed and refined. Current focus areas:

- [ ] Streamlining Neovim LSP configuration
- [ ] Improving tmux session management
- [ ] Optimizing keybindings across tools
- [ ] Creating language-specific configurations
- [ ] Documenting common workflows

## Screenshots

[Coming soon]

## Inspiration

This configuration draws inspiration from:
- ThePrimeagen's development environment
- Vim and Neovim communities
- Ruby/Rails developers using terminal-based workflows

## Contributing

While this is primarily my personal configuration, suggestions and improvements are welcome! Feel free to open an issue or pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.