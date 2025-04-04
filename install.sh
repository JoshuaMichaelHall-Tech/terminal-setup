#!/bin/zsh

# Terminal Development Environment Installation Script (Improved)
# Author: Joshua Michael Hall
# License: MIT

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        log_warning "$1 could not be found. Will attempt to install it."
        return 1
    fi
    return 0
}

# Function to check if a line exists in a file
line_exists() {
    local line="$1"
    local file="$2"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    grep -qF -- "$line" "$file"
    return $?
}

# Function to add a line to a file if it doesn't already exist
add_line_if_not_exists() {
    local line="$1"
    local file="$2"
    
    if [ ! -f "$file" ]; then
        mkdir -p "$(dirname "$file")"
        touch "$file"
    fi
    
    if ! line_exists "$line" "$file"; then
        echo "$line" >> "$file"
        return 0
    fi
    return 1
}

# Function to create a backup with timestamp
create_backup() {
    local source_path="$1"
    local backup_dir="$2"
    
    if [ -e "$source_path" ]; then
        local filename=$(basename "$source_path")
        local backup_path="$backup_dir/$filename"
        
        mkdir -p "$backup_dir"
        
        if [ -d "$source_path" ]; then
            cp -r "$source_path" "$backup_path"
        else
            cp "$source_path" "$backup_path"
        fi
        
        log_success "Created backup: $backup_path"
        return 0
    fi
    
    return 1
}

# Function to safely update a file
safe_update() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    
    if [ -e "$target" ]; then
        create_backup "$target" "$backup_dir"
    fi
    
    mkdir -p "$(dirname "$target")"
    cp -f "$source" "$target"
}

# Welcome message and mode selection
echo "==============================================================="
echo "      Terminal Environment Installation Script v$VERSION       "
echo "==============================================================="
echo ""
echo "This script will set up or update your terminal environment."
echo ""
echo "Available modes:"
echo "1. Full installation (new setup or complete update)"
echo "2. Minimal update (update configurations without reinstalling tools)"
echo "3. Check and fix permissions only"
echo "4. Uninstall (remove all components)"
echo ""
read "REPLY?Please select a mode (1-4, default: 1): "
echo ""

# Default to full installation
INSTALL_MODE="${REPLY:-1}"

case $INSTALL_MODE in
    1) MODE_NAME="Full installation";;
    2) MODE_NAME="Minimal update";;
    3) MODE_NAME="Permissions fix only";;
    4) MODE_NAME="Uninstall";
       echo "To uninstall, please run the uninstall.sh script instead.";
       exit 0;;
    *) log_error "Invalid mode selected. Exiting."; exit 1;;
esac

echo "Running in mode: $MODE_NAME"
echo ""

if [[ "$INSTALL_MODE" != "3" ]]; then
    read "REPLY?Continue with $MODE_NAME? (y/n) "
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation aborted."
        exit 1
    fi
fi

# Check operating system
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script is designed for MacOS only. Exiting."
    exit 1
fi

# Create timestamp for backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/terminal_env_backup_$TIMESTAMP"

if [[ "$INSTALL_MODE" != "3" ]]; then
    log_info "Creating backup directory at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    # Backup existing configurations
    log_info "Backing up existing configurations..."

    # Neovim
    if [ -d "$HOME/.config/nvim" ]; then
        log_info "Backing up Neovim configuration..."
        cp -r "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
    fi

    # tmux
    if [ -f "$HOME/.tmux.conf" ]; then
        log_info "Backing up tmux configuration..."
        cp "$HOME/.tmux.conf" "$BACKUP_DIR/tmux.conf"
    fi

    # Zsh
    if [ -f "$HOME/.zshrc" ]; then
        log_info "Backing up Zsh configuration..."
        cp "$HOME/.zshrc" "$BACKUP_DIR/zshrc"
    fi
    if [ -f "$HOME/.p10k.zsh" ]; then
        cp "$HOME/.p10k.zsh" "$BACKUP_DIR/p10k.zsh"
    fi

    # Notes system
    if [ -d "$HOME/notes" ]; then
        log_info "Backing up existing notes..."
        cp -r "$HOME/notes/templates" "$BACKUP_DIR/notes_templates" 2>/dev/null || true
        cp "$HOME/notes/README.md" "$BACKUP_DIR/notes_readme.md" 2>/dev/null || true
    fi

    log_success "Backups completed at $BACKUP_DIR"
fi

# Full installation mode
if [[ "$INSTALL_MODE" == "1" ]]; then
    # Install Homebrew if not installed
    if ! check_command brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ -f /opt/homebrew/bin/brew ]]; then
            BREW_PATH="$(/opt/homebrew/bin/brew shellenv)"
            if ! line_exists 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$HOME/.zshrc"; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
            fi
            eval "$BREW_PATH"
        fi
    else
        log_info "Homebrew already installed, updating..."
        brew update
    fi

    # Install core packages
    log_info "Installing core packages..."
    brew install git curl wget ripgrep fd jq python node ruby || true

    # Install iTerm2 if not already installed
    if [ ! -d "/Applications/iTerm.app" ]; then
        log_info "Installing iTerm2..."
        brew install --cask iterm2
    else
        log_info "iTerm2 already installed, skipping..."
    fi

    # Install Neovim
    if ! check_command nvim; then
        log_info "Installing Neovim..."
        brew install neovim
    else
        log_info "Updating Neovim..."
        brew upgrade neovim || true
    fi

    # Install tmux
    if ! check_command tmux; then
        log_info "Installing tmux..."
        brew install tmux
    else
        log_info "Updating tmux..."
        brew upgrade tmux || true
    fi

    # Install Watchman for notes syncing
    if ! check_command watchman; then
        log_info "Installing Watchman..."
        brew install watchman
    else
        log_info "Updating Watchman..."
        brew upgrade watchman || true
    fi

    # Install Zsh if not already installed
    if ! check_command zsh; then
        log_info "Installing Zsh..."
        brew install zsh
    fi

    # Make Zsh the default shell if it's not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "Setting Zsh as the default shell..."
        chsh -s $(which zsh)
        log_success "Zsh set as default shell. This will take effect after you log out and back in."
    fi

    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_info "Oh My Zsh already installed, skipping..."
    fi

    # Install Powerlevel10k theme if not already installed
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        log_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    else
        log_info "Updating Powerlevel10k theme..."
        cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && git pull
    fi

    # Install Zsh plugins
    log_info "Installing Zsh plugins..."
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    
    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
    else
        cd "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && git pull
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
    else
        cd "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && git pull
    fi

    # Install fonts
    log_info "Installing fonts..."
    brew tap homebrew/cask-fonts || true
    brew install --cask font-jetbrains-mono-nerd-font || true
    brew install --cask font-hack-nerd-font || true

    # Install Rectangle for window management
    if [ ! -d "/Applications/Rectangle.app" ]; then
        log_info "Installing Rectangle..."
        brew install --cask rectangle
    else
        log_info "Rectangle already installed, skipping..."
    fi

    # Install fzf
    if ! check_command fzf; then
        log_info "Installing fzf..."
        brew install fzf
        $(brew --prefix)/opt/fzf/install --all --no-update-rc
    else
        log_info "fzf already installed, skipping..."
    fi
fi

# Configuration updates (for both full and minimal modes)
if [[ "$INSTALL_MODE" == "1" || "$INSTALL_MODE" == "2" ]]; then
    # Configure Zsh
    log_info "Configuring Zsh..."
    
    # Create .zshrc if it doesn't exist
    if [ ! -f "$HOME/.zshrc" ]; then
        touch "$HOME/.zshrc"
    fi
    
    # Backup existing .zshrc
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
    
    # Check for key configurations and add them if missing
    
    # Powerlevel10k instant prompt
    P10K_PROMPT='if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi'
    
    if ! grep -q "p10k-instant-prompt" "$HOME/.zshrc"; then
        # Add to the beginning of the file
        sed -i '' -e "1s/^/$P10K_PROMPT\\n\\n/" "$HOME/.zshrc"
    fi
    
    # Oh My Zsh configuration
    OMZ_CONFIG='# Set up Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"'
    
    if ! grep -q "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" "$HOME/.zshrc"; then
        if grep -q "ZSH_THEME=" "$HOME/.zshrc"; then
            # Replace existing ZSH_THEME line
            sed -i '' -e "s/ZSH_THEME=.*$/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/" "$HOME/.zshrc"
        else
            # Add the configuration if not present
            echo "$OMZ_CONFIG" >> "$HOME/.zshrc"
        fi
    fi
    
    # Plugins configuration
    PLUGINS_CONFIG='# Plugins
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
  rbenv
)'
    
    if ! grep -q "plugins=(" "$HOME/.zshrc"; then
        echo "$PLUGINS_CONFIG" >> "$HOME/.zshrc"
    else
        log_info "Plugins configuration already exists, not modifying..."
    fi
    
    # Source Oh My Zsh
    OMZ_SOURCE='source $ZSH/oh-my-zsh.sh'
    add_line_if_not_exists "$OMZ_SOURCE" "$HOME/.zshrc"
    
    # Aliases
    ALIASES_CONFIG='# ============ Aliases ============
# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Directory listing aliases
alias ll="ls -la"
alias la="ls -a"

# Neovim alias
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# Tmux aliases
alias ta="tmux attach -t"
alias tls="tmux list-sessions"
alias tn="tmux new -s"
alias tk="tmux kill-session -t"

# Development workflow aliases
alias dev="tmux attach -t dev || tmux new -s dev"
alias notes="tmux attach -t notes || tmux new -s notes"'
    
    if ! grep -q "# ============ Aliases ============" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$ALIASES_CONFIG" >> "$HOME/.zshrc"
    fi
    
    # Functions
    FUNCTIONS_CONFIG='# ============ Functions ============
# Create and change to directory in one command
mcd() {
  mkdir -p "$1" && cd "$1"
}

# Find and open file with Neovim
nvimf() {
  local file
  file=$(find . -name "*$1*" | fzf)
  if [[ -n "$file" ]]; then
    nvim "$file"
  fi
}

# Check if functions are properly loaded
check-functions() {
  echo "Testing key functions..."
  declare -f mcd > /dev/null && echo "✓ mcd (make directory and cd) function is available" || echo "✗ mcd function is not available"
  declare -f nvimf > /dev/null && echo "✓ nvimf (find and edit with neovim) function is available" || echo "✗ nvimf function is not available"
  declare -f wk > /dev/null && echo "✓ wk (session manager) function is available" || echo "✗ wk function is not available"
}

# Unified session manager for both dev and notes
# Usage: wk dev|notes
wk() {
  local session=$1
  
  case "$session" in
    dev)
      if ! tmux has-session -t dev 2>/dev/null; then
        # Create development session with windows for code, server, and git
        tmux new-session -d -s dev -n code
        tmux new-window -t dev:1 -n server
        tmux new-window -t dev:2 -n git
        tmux select-window -t dev:0
      fi
      tmux attach -t dev
      ;;
    notes)
      if ! tmux has-session -t notes 2>/dev/null; then
        # Create notes session with windows for main, daily, projects, and learning
        tmux new-session -d -s notes -n main -c ~/notes
        tmux new-window -t notes:1 -n daily -c ~/notes/daily
        tmux new-window -t notes:2 -n projects -c ~/notes/projects
        tmux new-window -t notes:3 -n learning -c ~/notes/learning
        tmux select-window -t notes:0
      fi
      tmux attach -t notes
      ;;
    *)
      echo "Usage: wk [dev|notes]"
      echo "  dev   - Start or resume development session"
      echo "  notes - Start or resume notes session"
      ;;
  esac
}'
    
    if ! grep -q "# ============ Functions ============" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$FUNCTIONS_CONFIG" >> "$HOME/.zshrc"
    fi
    
    # Zsh options
    ZSH_OPTIONS='# ============ Zsh-specific settings ============
setopt AUTO_PUSHD        # Push directories onto the directory stack
setopt PUSHD_IGNORE_DUPS # Do not push duplicates
setopt PUSHD_SILENT      # Do not print the directory stack after pushd/popd
setopt EXTENDED_GLOB     # Use extended globbing
setopt AUTO_CD           # Type directory name to cd'
    
    if ! grep -q "# ============ Zsh-specific settings ============" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$ZSH_OPTIONS" >> "$HOME/.zshrc"
    fi
    
    # FZF configuration
    FZF_CONFIG='# fzf configuration
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"'
    
    if ! grep -q "# fzf configuration" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$FZF_CONFIG" >> "$HOME/.zshrc"
    fi
    
    # P10K source
    P10K_SOURCE='# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
    
    add_line_if_not_exists "$P10K_SOURCE" "$HOME/.zshrc"
    
    # Homebrew shellenv
    BREW_SHELLENV='# Homebrew shellenv
eval "$(/opt/homebrew/bin/brew shellenv)"'
    
    if [[ -f /opt/homebrew/bin/brew ]]; then
        if ! grep -q "/opt/homebrew/bin/brew shellenv" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "$BREW_SHELLENV" >> "$HOME/.zshrc"
        fi
    fi
    
    # Create bin directory if it doesn't exist
    if [ ! -d "$HOME/bin" ]; then
        mkdir -p "$HOME/bin"
    fi
    
    # Add ~/bin to PATH if not already there
    BIN_PATH='export PATH="$HOME/bin:$PATH"'
    if ! grep -q "export PATH=\"\$HOME/bin" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "$BIN_PATH" >> "$HOME/.zshrc"
    fi

    # Configure tmux
    log_info "Configuring tmux..."
    cat > "$HOME/.tmux.conf" << 'EOL'
# Terminal Development Environment tmux Configuration

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

# Don't rename windows automatically
set-option -g allow-rename off

# Improve colors
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Increase scrollback buffer size
set -g history-limit 10000

# Display tmux messages for 4 seconds
set -g display-time 4000

# Vim-like copy mode
setw -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Status bar
set -g status-style bg=default
set -g status-left-length 40
set -g status-right-length 60
set -g status-position bottom
set -g status-left '#[fg=green]#S #[fg=black]• #[fg=green,bright]#(whoami)#[fg=black] • #[fg=green]#h '
set -g status-right '#[fg=white,bg=default]%a %H:%M #[fg=white,bg=default]%Y-%m-%d '

# Install tmux plugin manager
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOL

    # Install tmux plugin manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log_info "Installing tmux plugin manager..."
        mkdir -p "$HOME/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        log_info "Updating tmux plugin manager..."
        cd "$HOME/.tmux/plugins/tpm" && git pull
    fi

    # Set up Neovim configuration
    log_info "Setting up Neovim configuration..."
    mkdir -p "$HOME/.config/nvim/lua"
    mkdir -p "$HOME/.config/nvim/plugin"
    mkdir -p "$HOME/.vim/undodir"

    # Create init.lua
    cat > "$HOME/.config/nvim/init.lua" << 'EOL'
-- Terminal Development Environment Neovim Configuration

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

-- ============ Basic settings ============
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

-- ============ Key mappings ============
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Basic utilities
vim.keymap.set('n', '<leader>w', ':w<CR>')   -- Save
vim.keymap.set('n', '<leader>q', ':q<CR>')   -- Quit
vim.keymap.set('n', '<leader>h', ':nohl<CR>') -- Clear search highlighting

-- Help keymap for showing common mappings
vim.keymap.set('n', '<leader>?', function()
  print("Common mappings:")
  print("  <leader>e  - Toggle file explorer")
  print("  <leader>ff - Find files")
  print("  <leader>fg - Live grep")
  print("  <leader>fb - Browse buffers")
  print("  <leader>w  - Save file")
  print("  <leader>q  - Quit")
  print("  gd         - Go to definition")
  print("  K          - Show documentation")
end, { noremap = true, silent = true })

-- ============ Load plugins ============
require("lazy").setup("plugins")

-- ============ LSP Server Naming Guide ============
-- When configuring Mason LSP, use these server names:
-- Ruby: ruby_ls
-- TypeScript: tsserver
-- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
EOL

    # Create plugins.lua
    cat > "$HOME/.config/nvim/lua/plugins.lua" << 'EOL'
return {
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "tokyonight"
    end,
  },
  
  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup()
    end,
  },
  
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {}
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
    end,
  },
  
  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files)
      vim.keymap.set('n', '<leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<leader>fb', builtin.buffers)
      vim.keymap.set('n', '<leader>fh', builtin.help_tags)
    end,
  },
  
  -- LSP configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'ruby_ls', 'pyright', 'tsserver' }
      })
      
      local lspconfig = require('lspconfig')
      
      -- Configure language servers
      lspconfig.lua_ls.setup{}      -- Lua language server
      lspconfig.ruby_ls.setup{}     -- Ruby language server
      lspconfig.pyright.setup{}     -- Python language server
      lspconfig.tsserver.setup{}    -- TypeScript/JavaScript language server
      
      -- Global LSP mappings
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      
      -- Check for format function (handles version differences)
      if vim.lsp.buf.format then
        vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
      else
        vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting)
      end