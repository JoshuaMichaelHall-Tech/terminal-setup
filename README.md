# Terminal Development Environment (Zsh-Only)

> **⚠️ DISCLAIMER: This is a work in progress. I am still working out bugs and refining the configuration. Use at your own risk and please report any issues you encounter.**

A highly customized terminal-based development environment using Zsh, Neovim, tmux, and command-line tools optimized for software engineering workflows.

![Version](https://img.shields.io/badge/version-0.1.0--alpha-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/shell-Zsh%20Only-orange)

## Overview

This repository contains my terminal-based development environment configuration, designed to maximize productivity through a keyboard-driven workflow. By leveraging terminal-based tools, this setup minimizes distractions and resource usage while providing a consistent environment across all my machines.

**IMPORTANT**: This environment is designed exclusively for Zsh shell. Bash is NOT supported.

## Key Features

- **Mouse-Free Workflow**: Complete development environment navigable entirely from the keyboard
- **Modular Configuration**: Easily adaptable to different projects and languages
- **Resource Efficiency**: Minimal CPU and memory usage compared to GUI editors
- **Consistent Experience**: Same environment locally and on remote servers
- **Version-Controlled**: Track all configuration changes with Git
- **Zsh-Powered**: Takes full advantage of Zsh's powerful features

## Components

### Core Tools
- **Zsh**: Shell with Oh My Zsh and custom configuration
- **Neovim**: Text editor with full LSP support and custom keybindings
- **tmux**: Terminal multiplexer for session management

### Plugins & Extensions
- **Lua-based Neovim config**: Modern plugin system with Lazy.nvim
- **LSP Integration**: Code intelligence for multiple languages
- **Telescope**: Fuzzy finder for files and text
- **Treesitter**: Advanced syntax highlighting
- **Git Integration**: Fugitive and other Git tools
- **Zsh Plugins**: Auto-suggestions, syntax highlighting, and more

## Getting Started

### Option 1: Automated Installation (Recommended)

The automated installation script will back up your existing configurations, set up a clean environment, and install all required components.

```zsh
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

1. **Use Zsh:** This environment is designed exclusively for Zsh, not Bash.
   - If you're not already using Zsh: `chsh -s $(which zsh)`
   - If using VS Code: Go to Settings → Terminal → Default Profile → Select 'zsh'
   - Restart your terminal session to start using Zsh

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
- [ ] Enhancing Zsh customizations

### Known Issues

- **LSP Server Names**: Mason-lspconfig uses specific server names that can be confusing. For current server names, run `:Mason` to see available packages and refer to the [server mapping documentation](https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md). 
  - If you receive the error `Server "X" is not a valid entry in ensure_installed`, you need to use the correct server name in your setup.
  - For example, use `rubylsp` (not `ruby_lsp`) and `tsserver` (for TypeScript).
- **Font Rendering**: Some terminals may have issues displaying Nerd Font icons. Make sure you've properly configured your terminal to use the JetBrainsMono Nerd Font.
- **Language Server Installation**: Some language servers may require additional dependencies like Node.js or npm. Check the Mason UI (`:Mason` in Neovim) for details.
- **Zsh Configuration**: If you have existing Zsh customizations, you may need to merge them with this setup's configuration.

## Screenshots

[Coming soon]

## Inspiration

This configuration draws inspiration from:
- ThePrimeagen's development environment
- Vim and Neovim communities
- Ruby/Rails developers using terminal-based workflows
- Zsh power users

## Contributing

While this is primarily my personal configuration, suggestions and improvements are welcome! Feel free to open an issue or pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.