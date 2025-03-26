#!/bin/bash

# Terminal Development Environment Installation Script
# Author: Joshua Michael Hall
# License: MIT

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
        log_error "$1 could not be found. Please install it first."
        exit 1
    fi
}

# Welcome message
echo "==============================================================="
echo "      Terminal Development Environment Installation Script      "
echo "==============================================================="
echo ""
echo "This script will set up a complete terminal-based development"
echo "environment with Neovim, tmux, and Zsh configurations."
echo ""
echo "THE SCRIPT WILL BACK UP YOUR EXISTING CONFIGURATIONS BEFORE"
echo "MAKING ANY CHANGES, BUT PLEASE REVIEW THE SCRIPT BEFORE RUNNING."
echo ""
read -p "Continue with installation? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Installation aborted."
    exit 1
fi

# Check operating system
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script is designed for MacOS only. Exiting."
    exit 1
fi

# Create timestamp for backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/terminal_env_backup_$TIMESTAMP"

log_info "Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup existing configurations
log_info "Backing up existing configurations..."

# Neovim
if [ -d "$HOME/.config/nvim" ]; then
    log_info "Backing up Neovim configuration..."
    cp -r "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
fi
if [ -d "$HOME/.local/share/nvim" ]; then
    cp -r "$HOME/.local/share/nvim" "$BACKUP_DIR/nvim_share"
fi

# tmux
if [ -f "$HOME/.tmux.conf" ]; then
    log_info "Backing up tmux configuration..."
    cp "$HOME/.tmux.conf" "$BACKUP_DIR/tmux.conf"
fi
if [ -d "$HOME/.tmux" ]; then
    cp -r "$HOME/.tmux" "$BACKUP_DIR/tmux_dir"
fi

# Zsh
if [ -f "$HOME/.zshrc" ]; then
    log_info "Backing up Zsh configuration..."
    cp "$HOME/.zshrc" "$BACKUP_DIR/zshrc"
fi
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_info "Backing up Oh My Zsh directory (this might take a moment)..."
    cp -r "$HOME/.oh-my-zsh" "$BACKUP_DIR/oh-my-zsh"
fi

log_success "Backups completed at $BACKUP_DIR"

# Clean slate
log_info "Implementing clean slate..."

# Remove existing configurations
if [ -d "$HOME/.config/nvim" ]; then
    log_info "Removing existing Neovim configuration..."
    rm -rf "$HOME/.config/nvim"
fi
if [ -d "$HOME/.local/share/nvim" ]; then
    log_info "Removing existing Neovim plugins..."
    rm -rf "$HOME/.local/share/nvim"
fi
if [ -f "$HOME/.tmux.conf" ]; then
    log_info "Removing existing tmux configuration..."
    rm -f "$HOME/.tmux.conf"
fi

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    BREW_PATH="$(/opt/homebrew/bin/brew shellenv)"
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "eval \"$BREW_PATH\"" >> "$HOME/.zshrc"
        eval "$BREW_PATH"
    else
        echo "eval \"$BREW_PATH\"" >> "$HOME/.bash_profile"
        eval "$BREW_PATH"
    fi
else
    log_info "Homebrew already installed, updating..."
    brew update
fi

# Install core packages
log_info "Installing core packages..."
brew install git curl wget ripgrep fd jq python node ruby

# Install iTerm2
log_info "Installing iTerm2..."
brew install --cask iterm2

# Install Neovim
log_info "Installing Neovim..."
brew install neovim

# Install tmux
log_info "Installing tmux..."
brew install tmux

# Install Zsh if not already installed
if ! command -v zsh &> /dev/null; then
    log_info "Installing Zsh..."
    brew install zsh
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme
log_info "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install Zsh plugins
log_info "Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure Zsh
log_info "Configuring Zsh..."
cat > "$HOME/.zshrc" << 'EOL'
# Terminal Development Environment Zsh Configuration
# Set up Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
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

# Aliases
# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Directory listing aliases
alias ll='ls -la'
alias la='ls -a'

# Neovim alias
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL

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

# Set up Neovim configuration
log_info "Setting up Neovim configuration..."
mkdir -p "$HOME/.config/nvim/lua"

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
EOL

# Create plugins.lua
mkdir -p "$HOME/.config/nvim/lua"
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
        -- Note: Server names might change in future lspconfig versions
        -- Check https://github.com/neovim/nvim-lspconfig for the latest names
        ensure_installed = { 'lua_ls', 'rubylsp', 'pyright', 'tsserver' }
      })
      
      local lspconfig = require('lspconfig')
      
      -- Basic LSP setup for the languages you use
      lspconfig.lua_ls.setup{}    -- For Lua development
      lspconfig.rubylsp.setup{}   -- For Ruby development
      lspconfig.pyright.setup{}   -- For Python development
      lspconfig.tsserver.setup{}  -- For TypeScript/JavaScript development
      
      -- Global LSP mappings
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
    end,
  },
  
  -- Autocomplete
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end,
  },
  
  -- Git integration
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gs', ':Git<CR>')
      vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
      vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
    end,
  },
  
  -- Vimwiki for notes
  {
    'vimwiki/vimwiki',
    config = function()
      vim.g.vimwiki_list = {{path = '~/vimwiki/', syntax = 'markdown', ext = '.md'}}
    end,
  },
}
EOL

# Final steps
log_success "Installation completed successfully!"

# Install essential fonts
log_info "Installing Nerd Fonts for proper icon display..."
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-hack-nerd-font

# Install additional productivity tools
log_info "Installing additional productivity tools..."
brew install --cask rectangle
brew install ranger
brew install fzf
$(brew --prefix)/opt/fzf/install --all
echo ""
echo "==================================================================="
echo "                    NEXT STEPS AND NOTES                         "
echo "==================================================================="
echo ""
echo "IMPORTANT: You must use Zsh to use this environment!"
echo ""
echo "1. Switch to Zsh if you're not already using it:"
echo "   chsh -s $(which zsh)"
echo ""
echo "2. Configure your terminal:"
echo "   - iTerm2: Preferences → Profiles → Text → Font → Select 'JetBrainsMono Nerd Font'"
echo "   - VS Code: "
echo "     • Settings → Terminal → Default Profile → Select 'zsh'"
echo "     • Settings → Terminal › Integrated: Font Family → 'JetBrainsMono Nerd Font'"
echo ""
echo "3. Start a new Zsh terminal (don't source .zshrc from bash!)"
echo ""
echo "4. Run 'p10k configure' to set up the Powerlevel10k theme"
echo ""
echo "5. Open Neovim and let it install plugins (it may show errors on first run)"
echo ""
echo "6. In tmux, press Ctrl+a followed by 'I' to install tmux plugins"
echo ""
echo "7. Your old configurations are backed up in: $BACKUP_DIR"
echo ""
echo "For more detailed information, refer to the README.md file."
echo ""
echo "Enjoy your new terminal development environment!"
echo ""