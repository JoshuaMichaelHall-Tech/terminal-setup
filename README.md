# Terminal Development Environment

> A modular, maintainable terminal-based development environment using Zsh, Neovim, tmux, and command-line tools optimized for software engineering workflows.

![Version](https://img.shields.io/badge/version-0.2.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/shell-Zsh%20Only-orange)

## Overview

This repository contains a terminal-based development environment configuration, designed to maximize productivity through a keyboard-driven workflow. By leveraging terminal-based tools, this setup minimizes distractions and resource usage while providing a consistent environment across all machines.

**IMPORTANT**: This environment is designed exclusively for Zsh shell. Bash is NOT supported.

## Key Features

- **Modular Architecture**: Each component can be installed, troubleshooted, and uninstalled independently
- **Mouse-Free Workflow**: Complete development environment navigable entirely from the keyboard
- **Resource Efficiency**: Minimal CPU and memory usage compared to GUI editors
- **Consistent Experience**: Same environment locally and on remote servers
- **Version-Controlled**: Track all configuration changes with Git
- **Zsh-Powered**: Takes full advantage of Zsh's powerful features
- **Robust Installation**: Safe installation, update, and removal processes
- **Self-Healing**: Built-in health check and repair capabilities for each component

## Components

The system is broken down into the following modular components, each with dedicated scripts for installation, troubleshooting, and uninstallation:

### Core Components
- **Core Environment**: Basic directory structure and shared configurations
- **Zsh Configuration**: Shell with Oh My Zsh and custom configuration
- **Neovim Configuration**: Text editor with full LSP support and custom keybindings
- **tmux Configuration**: Terminal multiplexer for session management
- **Notes System**: Structured note-taking system integrated with Neovim

### Component Scripts
Each component has three dedicated Ruby scripts:
- **Installer**: Sets up and configures the component
- **Troubleshooter**: Diagnoses and fixes common issues
- **Uninstaller**: Safely removes the component while preserving user data

## Getting Started

### Option 1: Automated Installation (Recommended)

```zsh
# Clone the repository
git clone https://github.com/JoshuaMichaelHall-Tech/terminal-setup.git
cd terminal-setup

# Make the installation script executable
chmod +x install.rb

# Run the installation script
ruby install.rb
```

The installation script provides several modes:

1. **Full Installation**: Complete setup of all components
2. **Minimal Update**: Updates configurations without reinstalling tools
3. **Core Only**: Installs only core components
4. **Component-Specific**: Install individual components (Zsh, Neovim, tmux, Notes)
5. **Fix Permissions**: Only fixes file permissions

You can also run individual component scripts directly from the `bin/` directory:

```zsh
# Example: Install only Neovim configuration
ruby bin/nvim_installer.rb

# Example: Troubleshoot tmux
ruby bin/tmux_troubleshooter.rb --fix

# Example: Uninstall Zsh configuration
ruby bin/zsh_uninstaller.rb
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

The installer creates a backup of your previous configuration in `~/terminal_env_backup_TIMESTAMP/`. If you need to restore your previous setup, you can copy files from this directory back to their original locations.

### Option 2: Manual Installation

For those who prefer more control over the installation process, please see the [Setup Guide](./SETUP.md) for detailed step-by-step instructions.

## Maintenance & Troubleshooting

Each component comes with its own troubleshooter script:

```zsh
# Run troubleshooter in check-only mode
ruby bin/component_troubleshooter.rb

# Run troubleshooter with automatic fixes
ruby bin/component_troubleshooter.rb --fix
```

Troubleshooter scripts will:
- Verify all required components are installed
- Check for proper configuration files
- Ensure necessary functions and aliases are defined
- Fix any issues they find (when run with `--fix`)

### Uninstalling

Each component has its own uninstaller script:

```zsh
# Uninstall a specific component
ruby bin/component_uninstaller.rb
```

Uninstallers provide options for:
1. **Soft Uninstall**: Removes configurations but keeps tools
2. **Full Uninstall**: Removes all configurations and installed tools

Your personal data will be preserved but backed up before any changes.

### Updating

```zsh
# Run the master installer in minimal update mode
ruby install.rb --mode minimal

# Or update a specific component
ruby bin/component_installer.rb --minimal
```

## Shortcuts Reference

See [terminal-shortcuts.md](terminal-shortcuts.md) for a comprehensive list of keyboard shortcuts for all components.

## Known Issues and Fixes

- **Powerlevel10k Configuration**: If `p10k configure` doesn't work, run `zsh_troubleshooter.rb --fix` to create a minimal working configuration.

- **tmux Split Panes**: If `Ctrl+a |` doesn't split panes vertically, run `tmux_troubleshooter.rb --fix`.

- **Missing Neovim Plugins**: If Neovim reports it can't find plugins.lua, run the `nvim_troubleshooter.rb --fix`.

- **LSP Server Names**: Mason-lspconfig uses specific server names that might change over time. For current server names, run `:Mason` to see available packages and refer to the [server mapping documentation](https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md).

- **Font Rendering**: Some terminals may have issues displaying Nerd Font icons. Make sure you've properly configured your terminal to use the JetBrainsMono Nerd Font.

## Project Structure

```
terminal-setup/
├── install.rb         # Master installer script
├── terminal-shortcuts.md  # Consolidated shortcuts reference
├── bin/               # Component scripts
│   ├── core_installer.rb
│   ├── core_troubleshooter.rb
│   ├── core_uninstaller.rb
│   ├── zsh_installer.rb
│   ├── zsh_troubleshooter.rb
│   ├── zsh_uninstaller.rb
│   ├── nvim_installer.rb
│   ├── nvim_troubleshooter.rb
│   ├── nvim_uninstaller.rb
│   ├── tmux_installer.rb
│   ├── tmux_troubleshooter.rb
│   ├── tmux_uninstaller.rb
│   ├── notes_installer.rb
│   ├── notes_troubleshooter.rb
│   └── notes_uninstaller.rb
└── docs/              # Documentation files
    ├── SETUP.md       # Detailed setup instructions
    └── TUTORIAL.md    # Usage tutorials
```

## Contributing

While this is primarily my personal configuration, suggestions and improvements are welcome! Feel free to open an issue or pull request.

## Acknowledgements

This project was developed with assistance from Anthropic's Claude AI assistant, which helped with:
- Documentation writing and organization
- Code structure suggestions
- Troubleshooting and debugging assistance

Claude was used as a development aid while all final implementation decisions and code review were performed by the human developer.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
