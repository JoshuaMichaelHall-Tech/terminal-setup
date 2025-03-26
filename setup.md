# Terminal Development Environment Setup Guide

This guide provides step-by-step instructions for setting up a complete terminal-based development environment optimized for software engineering workflows.

## Core Components

- **Terminal**: iTerm2 with custom configuration
- **Shell**: Zsh with Oh My Zsh
- **Text Editor**: Neovim with LSP support and plugins
- **Terminal Multiplexer**: tmux for session management
- **Version Control**: Git with GitHub CLI integration

## Prerequisites

- MacOS (10.15 Catalina or newer)
- Administrator access
- Basic terminal knowledge

## Installation Steps

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-installation instructions to add Homebrew to your PATH.

### 2. Install Core Packages

```bash
brew install git curl wget ripgrep fd jq python node ruby
```

### 3. Set Up Terminal (iTerm2)

```bash
brew install --cask iterm2
```

**Configuration Recommendations:**
- Font: JetBrainsMono Nerd Font or Hack Nerd Font (12-14pt)
  ```bash
  # Install Nerd Fonts
  brew tap homebrew/cask-fonts
  brew install --cask font-jetbrains-mono-nerd-font
  brew install --cask font-hack-nerd-font
  ```
- Color scheme: Tokyo Night, Solarized Dark, or One Dark
- Enable Natural Text Editing (Preferences > Profiles > Keys > Load Preset)
- Window dimensions: 140×40

**Font Configuration:**
1. Open iTerm2 Preferences (Cmd+,)
2. Go to Profiles > Text
3. Click "Change Font"
4. Select "JetBrainsMono Nerd Font" or "Hack Nerd Font"
5. Set size to 14pt
6. Check "Use ligatures" (optional, for JetBrainsMono)

### 4. Configure Shell Environment

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme (optional)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install useful plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Edit your `~/.zshrc` file to:
- Set `ZSH_THEME="powerlevel10k/powerlevel10k"`
- Configure plugins: `plugins=(git ruby python node npm macos tmux docker web-search zsh-autosuggestions zsh-syntax-highlighting)`
- Add useful aliases (see example aliases in tutorial document)

Then run:
```bash
source ~/.zshrc
p10k configure  # If using Powerlevel10k
```

### 5. Install and Configure Neovim

```bash
brew install neovim
```

Create basic configuration structure:
```bash
mkdir -p ~/.config/nvim/lua
touch ~/.config/nvim/init.lua
touch ~/.config/nvim/lua/plugins.lua
```

**Set up Lazy.nvim (plugin manager):**
```bash
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/lazy/lazy.nvim
```

Edit `~/.config/nvim/init.lua` with the basic configuration (see tutorial document for complete setup).

### 6. Install and Configure tmux

```bash
brew install tmux
```

Create `~/.tmux.conf` with your preferred settings:
- Set prefix key to `Ctrl+a`
- Configure key bindings for splitting panes
- Enable mouse support
- Set vi mode for copy operations
- Customize status bar

Install TPM (Tmux Plugin Manager):
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Add useful plugins to your config (tmux-resurrect, tmux-continuum, etc.).

### 7. Configure Git and GitHub

```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Add the SSH key to your GitHub account.

Install GitHub CLI:
```bash
brew install gh
gh auth login
```

### 8. Install Additional Productivity Tools

```bash
# Window management
brew install --cask rectangle

# File management
brew install ranger

# Fuzzy finder
brew install fzf
$(brew --prefix)/opt/fzf/install
```

## Verification and Testing

Test your setup with these commands:

1. **Neovim with plugins**: `nvim` (should load without errors)
2. **tmux**: `tmux new -s test` (create a test session)
3. **GitHub CLI**: `gh auth status` (should show authenticated)

## Troubleshooting Common Issues

### Existing Configuration Conflicts

When installing on a Mac that already has some components installed with incorrect configurations, you may encounter several issues:

#### 1. Conflicting Neovim Configurations
- Your existing Neovim config in `~/.config/nvim` might conflict with the new setup
- **Solution**: Back up your current config before installing:
  ```bash
  mv ~/.config/nvim ~/.config/nvim.bak
  mv ~/.local/share/nvim ~/.local/share/nvim.bak  # Plugin data
  ```
- Check for stray config files in your home directory like `.vimrc` that might override Neovim settings

#### 2. Shell Configuration Overlaps
- If you already have Zsh customizations in `.zshrc`, the new settings might conflict
- **Solution**: Compare before replacing:
  ```bash
  diff ~/.zshrc path/to/new/.zshrc
  ```
- Selectively merge rather than completely overwriting your existing configuration
- Look for duplicate plugin declarations in Oh My Zsh setup

#### 3. Package Version Conflicts
- Homebrew might detect different versions of already installed packages
- **Solution**: Check current versions and resolve conflicts:
  ```bash
  brew info neovim  # Check installed version
  brew unlink neovim && brew link neovim  # Force relink
  ```
- For major version conflicts, consider uninstalling first: `brew uninstall neovim`

#### 4. tmux Session Management
- Existing tmux sessions might use incompatible configurations
- **Solution**: Save any important work and reset the tmux server:
  ```bash
  tmux kill-server  # Warning: closes all tmux sessions
  ```
- For a non-destructive approach, create a temporary config:
  ```bash
  tmux -f ~/tmux.new.conf new -s test
  ```

#### 5. Plugin Manager Conflicts
- If you've used different plugin managers for Neovim (like vim-plug instead of Lazy.nvim)
- **Solution**: Clean up old plugin systems before installing new ones:
  ```bash
  # For vim-plug
  rm -rf ~/.local/share/nvim/plugged
  # For Packer
  rm -rf ~/.local/share/nvim/site/pack/packer
  ```

### Recommended Troubleshooting Approach

#### Audit Current Installation
```bash
# Check which components are already installed
brew list
ls -la ~/.config/nvim
ls -la ~/.tmux*
cat ~/.zshrc
```

#### Create Backups
```bash
# Back up existing configurations
mkdir -p ~/config-backups/$(date +%Y%m%d)
cp -r ~/.config/nvim ~/config-backups/$(date +%Y%m%d)/ 2>/dev/null
cp ~/.tmux.conf ~/config-backups/$(date +%Y%m%d)/ 2>/dev/null
cp ~/.zshrc ~/config-backups/$(date +%Y%m%d)/ 2>/dev/null
```

#### Incremental Installation
- Install and configure one component at a time
- Test each component before moving to the next
- This approach makes it easier to identify which component is causing issues

#### Clean Slate Option
For a completely fresh start, consider:
```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm ~/.tmux.conf
# Careful with zshrc - make a backup first
```

### Other Common Issues

- **Plugin installation failures**: Check your internet connection and GitHub access
- **Terminal color issues**: Ensure your terminal supports 256 colors
- **Font rendering problems**: Install Nerd Fonts: `brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font`
- **Neovim startup errors**: Check logs with `:checkhealth`
- **tmux copy/paste not working**: Ensure proper clipboard integration in configs

## Maintenance

Keep your environment updated:

```bash
# Update packages
brew update && brew upgrade

# Update Neovim plugins (inside Neovim)
:Lazy update

# Update tmux plugins (inside tmux)
prefix + U

# Update Oh My Zsh
omz update
```

## Backup Strategy

1. Create a dotfiles repository:
```bash
mkdir -p ~/dotfiles
cd ~/dotfiles
git init
```

2. Add your config files using symbolic links:
```bash
ln -sf ~/.zshrc ~/dotfiles/.zshrc
ln -sf ~/.tmux.conf ~/dotfiles/.tmux.conf
ln -sf ~/.config/nvim ~/dotfiles/nvim
```

3. Track with Git and push to GitHub:
```bash
git add .
git commit -m "Initial dotfiles setup"
gh repo create dotfiles --private
git push -u origin main
```