# Terminal Development Environment Setup Guide (Zsh-Only)

This guide provides step-by-step instructions for setting up a complete terminal-based development environment optimized for software engineering workflows using Zsh shell.

## Core Components

- **Terminal**: iTerm2 with custom configuration
- **Shell**: Zsh with Oh My Zsh (Bash is NOT supported)
- **Text Editor**: Neovim with LSP support and plugins
- **Terminal Multiplexer**: tmux for session management
- **Version Control**: Git with GitHub CLI integration

## Prerequisites

- MacOS (10.15 Catalina or newer)
- Administrator access
- Basic terminal knowledge

## Installation Steps

### 1. Install Zsh and Set as Default

```zsh
# Check if Zsh is already installed
which zsh

# If not installed, install it with Homebrew
brew install zsh

# Set Zsh as default shell
chsh -s $(which zsh)

# Restart your terminal or open a new terminal window to start using Zsh
```

### 2. Install Homebrew

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-installation instructions to add Homebrew to your PATH in your `.zshrc` file.

### 3. Install Core Packages

```zsh
brew install git curl wget ripgrep fd jq python node ruby
```

### 4. Set Up Terminal (iTerm2)

```zsh
brew install --cask iterm2
```

**Configuration Recommendations:**
- Font: JetBrainsMono Nerd Font or Hack Nerd Font (12-14pt)
  ```zsh
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

### 5. Configure Zsh Environment

```zsh
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k theme (recommended)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install useful plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Edit your `~/.zshrc` file to:
- Set `ZSH_THEME="powerlevel10k/powerlevel10k"`
- Configure plugins: `plugins=(git ruby python node npm macos tmux docker web-search zsh-autosuggestions zsh-syntax-highlighting)`
- Add useful aliases (see example below)

Example `.zshrc` with useful aliases:

```zsh
# Set Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable plugins
plugins=(
  git
  ruby
  python
  node
  npm
  macos
  tmux
  docker
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listing aliases
alias ll='ls -la'
alias la='ls -a'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# Neovim aliases
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Tmux aliases
alias ta='tmux attach -t'
alias tls='tmux list-sessions'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# Development workflow aliases
alias dev='tmux attach -t dev || tmux new -s dev'
alias notes='tmux attach -t notes || tmux new -s notes "nvim -c VimwikiIndex"'

# fzf configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
```

After updating your `.zshrc`, activate the changes:
```zsh
source ~/.zshrc
p10k configure  # If using Powerlevel10k
```

### 6. Install and Configure Neovim

```zsh
brew install neovim
```

Create basic configuration structure:
```zsh
mkdir -p ~/.config/nvim/lua
touch ~/.config/nvim/init.lua
touch ~/.config/nvim/lua/plugins.lua
```

**Set up Lazy.nvim (plugin manager):**
```zsh
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/lazy/lazy.nvim
```

Create a basic `~/.config/nvim/init.lua`:

```lua
-- Initialize Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.g.mapleader = " " -- Space as leader key

-- Key mappings
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Basic utilities
vim.keymap.set('n', '<leader>w', ':w<CR>') -- Save
vim.keymap.set('n', '<leader>q', ':q<CR>') -- Quit

-- Load plugins
require("lazy").setup("plugins")
```

Create `~/.config/nvim/lua/plugins.lua` with your preferred plugins. See the full installation script for a complete example.

### 7. Install and Configure tmux

```zsh
brew install tmux
```

Create `~/.tmux.conf` with your preferred settings:
- Set prefix key to `Ctrl+a`
- Configure key bindings for splitting panes
- Enable mouse support
- Set vi mode for copy operations
- Customize status bar

Example `.tmux.conf`:

```
# Remap prefix from 'C-b' to 'C-a'
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse control
set -g mouse on

# Use vi keys in copy mode
setw -g mode-keys vi
```

Install TPM (Tmux Plugin Manager):
```zsh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Add useful plugins to your config:

```
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

### 8. Configure Git and GitHub

```zsh
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
```zsh
brew install gh
gh auth login
```

### 9. Install Additional Productivity Tools

```zsh
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

1. **Zsh**: `echo $SHELL` (should show path to zsh)
2. **Neovim with plugins**: `nvim` (should load without errors)
3. **tmux**: `tmux new -s test` (create a test session)
4. **GitHub CLI**: `gh auth status` (should show authenticated)

## Troubleshooting Common Issues

### Zsh Configuration Issues

#### 1. Oh My Zsh Installation Fails
- **Problem**: Oh My Zsh installation fails or doesn't complete properly
- **Solution**: Try manual installation:
  ```zsh
  # Clone repository manually
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  
  # Create a new .zshrc
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  
  # Edit .zshrc to customize
  nvim ~/.zshrc
  ```

#### 2. Plugins Not Loading
- **Problem**: Zsh plugins installed but not functioning
- **Solution**: Verify they're correctly listed in the plugins array in `.zshrc` and properly installed in the `$ZSH_CUSTOM/plugins` directory

#### 3. Powerlevel10k Font Issues
- **Problem**: Powerlevel10k showing broken characters
- **Solution**: Install and configure Nerd Fonts properly in your terminal emulator

### Neovim Configuration Conflicts

#### 1. Conflicting Neovim Configurations
- **Problem**: Your existing Neovim config conflicts with the new setup
- **Solution**: Back up your current config before installing:
  ```zsh
  mv ~/.config/nvim ~/.config/nvim.bak
  mv ~/.local/share/nvim ~/.local/share/nvim.bak  # Plugin data
  ```

#### 2. LSP Server Issues
- **Problem**: LSP servers not working correctly
- **Solution**: Use the included `fix-lsp-servers.zsh` script to correct common issues with server naming

### tmux Session Management Issues

- **Problem**: Existing tmux sessions use incompatible configurations
- **Solution**: Save important work and reset the tmux server:
  ```zsh
  tmux kill-server  # Warning: closes all tmux sessions
  ```

## Maintenance

Keep your environment updated:

```zsh
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
```zsh
mkdir -p ~/dotfiles
cd ~/dotfiles
git init
```

2. Add your config files using symbolic links:
```zsh
ln -sf ~/.zshrc ~/dotfiles/.zshrc
ln -sf ~/.tmux.conf ~/dotfiles/.tmux.conf
ln -sf ~/.config/nvim ~/dotfiles/nvim
```

3. Track with Git and push to GitHub:
```zsh
git add .
git commit -m "Initial dotfiles setup"
gh repo create dotfiles --private
git push -u origin main
```