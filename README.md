# Terminal Development Environment (Zsh-Only)

> **⚠️ DISCLAIMER: This is a work in progress. I am still working out bugs and refining the configuration. Use at your own risk and please report any issues you encounter.**

A highly customized terminal-based development environment using Zsh, Neovim, tmux, and command-line tools optimized for software engineering workflows.

![Version](https://img.shields.io/badge/version-0.1.1--alpha-blue)
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
- **Robust Installation**: Safe installation, update, and removal processes
- **Self-Healing**: Built-in health check and repair capabilities

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

The installation is now managed by two Ruby scripts for better reliability and error handling.

```zsh
# Clone the repository
git clone https://github.com/JoshuaMichaelHall-Tech/terminal-setup.git
cd terminal-setup

# Make the installation scripts executable
chmod +x installer.rb troubleshooter.rb

# Run the installation script
ruby installer.rb
```

The installation script provides three modes:
1. **Full Installation**: Complete setup including tools and configurations
2. **Minimal Update**: Updates configurations without reinstalling tools
3. **Permissions Fix**: Only fixes file permissions

If you encounter any issues after installation, run the troubleshooter:
```zsh
ruby troubleshooter.rb --fix
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

The script creates a backup of your previous configuration in `~/terminal_env_backup_TIMESTAMP/`. If you need to restore your previous setup, you can copy files from this directory back to their original locations.

### Option 2: Manual Installation

For those who prefer more control over the installation process, please see the [Setup Guide](./SETUP.md) for detailed step-by-step instructions and the [Tutorial](./TUTORIAL.md) for workflow examples.

## Maintenance & Troubleshooting

### Health Check

The troubleshooter script now provides comprehensive diagnostic capabilities:

```zsh
# Run the health check script (check only)
ruby troubleshooter.rb

# Run the health check script and fix issues
ruby troubleshooter.rb --fix
```

The troubleshooter will:
- Verify all required components are installed
- Check for proper configuration files
- Ensure Zsh functions and aliases are defined
- Confirm notes system is properly set up
- Fix any issues it finds (when run with `--fix`)

### Uninstalling

If you need to remove the environment:

```zsh
# Run the uninstall script
~/bin/uninstall-terminal-env.sh
```

The uninstaller provides two options:
1. **Soft Uninstall**: Removes configurations but keeps tools
2. **Full Uninstall**: Removes all configurations and installed tools

Your personal data (like notes) will be preserved but backed up before any changes.

### Updating

To update to the latest version:

```zsh
# Run the installer in update mode
ruby installer.rb --minimal
```

### Keeping LSP Configuration Up-to-date

LSP server names and configurations can change between versions. To update your LSP configuration:

1. Check the latest server names in Mason's documentation:
   ```
   :help mason-lspconfig-server-map
   ```
   
2. Or check the online documentation at [mason-lspconfig server mapping](https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md)

3. Update your configuration in `~/.config/nvim/lua/plugins.lua` if needed

4. Install or update servers with:
   ```
   :Mason
   ```

## Known Issues and Fixes

- **Powerlevel10k Configuration**: If `p10k configure` doesn't work, the troubleshooter script will create a minimal working configuration for you. You can then run `p10k configure` to customize it.

- **tmux Split Panes**: If `Ctrl+a |` doesn't split panes vertically, the troubleshooter will fix your tmux configuration.

- **Missing Neovim Plugins**: If Neovim reports it can't find plugins.lua, run the troubleshooter script to create all necessary directories and files.

- **LSP Server Names**: Mason-lspconfig uses specific server names that might change over time. For current server names, run `:Mason` to see available packages and refer to the [server mapping documentation](https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md).

- **Font Rendering**: Some terminals may have issues displaying Nerd Font icons. Make sure you've properly configured your terminal to use the JetBrainsMono Nerd Font.

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
