# Installation, Update, and Maintenance

This section covers detailed information about installing, updating, maintaining, and uninstalling the terminal environment.

## Installation

### Automated Installation Script

The `install.sh` script provides a streamlined way to set up your environment. It offers three installation modes:

1. **Full Installation**
   - Installs all tools and configurations
   - Backs up existing configurations
   - Sets up the notes system
   - Configures Zsh, Neovim, and tmux

2. **Minimal Update**
   - Updates configurations without reinstalling tools
   - Preserves existing customizations when possible
   - Updates plugins and configurations to the latest version

3. **Permissions Fix Only**
   - Only fixes file permissions
   - Makes no changes to configurations or installed tools

To use the installer:

```bash
./install.sh
```

Then follow the on-screen prompts to select your desired installation mode.

### What Gets Installed

A full installation includes:

- **Tools**: Neovim, tmux, Watchman, fzf, and more
- **Fonts**: JetBrainsMono Nerd Font and Hack Nerd Font
- **Zsh Configuration**: 
  - Oh My Zsh with Powerlevel10k theme
  - Custom functions and aliases
  - Directory navigation enhancements
- **Neovim Configuration**:
  - LSP support for multiple languages
  - Modern plugins with Lazy.nvim
  - Notes system integration
- **tmux Configuration**:
  - Custom keybindings (prefix: Ctrl+a)
  - Sensible navigation
  - Persistent sessions
- **Notes System**:
  - Directory structure
  - Templates
  - Git-backed versioning

## Updating

### Using the Installer for Updates

The easiest way to update your environment is to use the installation script with the "Minimal Update" option:

```bash
./install.sh
# Select option 2: Minimal update
```

This will:
- Update all configuration files to the latest version
- Preserve your custom changes where possible
- Update plugins and dependencies
- Fix any permissions issues

### Manual Updates

For more control, you can manually update specific components:

1. **Neovim Plugins**:
   ```
   nvim --headless "+Lazy! sync" +qa
   ```

2. **tmux Plugins**:
   ```
   ~/.tmux/plugins/tpm/bin/update_plugins all
   ```

3. **Zsh Plugins**:
   ```
   omz update
   ```

## Health Check & Troubleshooting

### Using the Health Check Script

The `health-check.sh` script provides a comprehensive diagnostic tool for your environment:

```bash
./health-check.sh
```

The script offers two modes:
1. **Check Only**: Reports issues without making changes
2. **Check and Fix**: Automatically fixes common problems

### What Gets Checked

The health check verifies:
- Core tools are installed (Zsh, Neovim, tmux, Git, etc.)
- Configuration files exist and are properly formatted
- Zsh functions and aliases are defined
- Notes system directories and templates exist
- Scripts have proper execute permissions

### Common Issues and Fixes

The health check can automatically fix:
- Missing directories
- Missing configuration files
- Missing Zsh functions and aliases
- Script permission issues
- Basic notes system setup

For more serious issues, the script will recommend running the installer in the appropriate mode.

## Uninstallation

### Using the Uninstall Script

To remove the terminal environment:

```bash
~/bin/uninstall-terminal-env.sh
```

The uninstaller provides two options:
1. **Soft Uninstall**: Removes configurations but keeps tools
2. **Full Uninstall**: Removes all configurations and installed tools

### What Gets Preserved

Regardless of the uninstall mode, the following are preserved:
- Your personal notes in the `~/notes` directory
- Your Zsh history
- Other personal data not directly related to the environment

### Backups

Before removing anything, the uninstaller creates a backup of all configurations in:
```
~/terminal_env_uninstall_backup_TIMESTAMP/
```

You can restore specific files from this backup if needed.

## Version Control

The environment maintains a version file at `~/.terminal_env_version` to track:
- Installed version
- Installation date
- Installation mode

This helps with compatibility checks and targeted updates.
