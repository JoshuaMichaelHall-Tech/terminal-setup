#!/bin/zsh

# Terminal Development Environment Installation Script
# Updated for integrated environment with notes system
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
echo "      Integrated Terminal Environment Installation Script      "
echo "==============================================================="
echo ""
echo "This script will set up a complete terminal-based environment:"
echo "- Development tools with Neovim, tmux, and Zsh"
echo "- Notes system with Git-backed markdown notes"
echo ""
echo "IMPORTANT: This environment requires Zsh shell. Bash is not supported."
echo ""
echo "THE SCRIPT WILL BACK UP YOUR EXISTING CONFIGURATIONS BEFORE"
echo "MAKING ANY CHANGES, BUT PLEASE REVIEW THE SCRIPT BEFORE RUNNING."
echo ""
read "REPLY?Continue with installation? (y/n) "
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

# Check if running in Zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    log_warning "You are not currently using Zsh. This environment requires Zsh shell."
    log_warning "The script will install Zsh, but you'll need to switch to it after installation."
    log_warning "To switch to Zsh, run: chsh -s \$(which zsh)"
    echo ""
    read "REPLY?Continue anyway? (y/n) "
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation aborted."
        exit 1
    fi
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

# Notes system
if [ -d "$HOME/notes" ]; then
    log_info "Backing up existing notes..."
    cp -r "$HOME/notes" "$BACKUP_DIR/notes"
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
    echo "eval \"$BREW_PATH\"" >> "$HOME/.zshrc"
    eval "$BREW_PATH"
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

# Install Watchman for notes syncing
log_info "Installing Watchman..."
brew install watchman

# Install Zsh if not already installed
if ! command -v zsh &> /dev/null; then
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
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
  rbenv
)

# Fix for missing completions
if [[ ! -d /opt/homebrew/share/zsh/site-functions ]]; then
  mkdir -p /opt/homebrew/share/zsh/site-functions
fi

# Skip problematic completion file
zstyle ':completion:*:*:*:*:*' skip-file '/opt/homebrew/share/zsh/site-functions/_brew_services'

source $ZSH/oh-my-zsh.sh

# ============ Core Environment Settings ============
# Set ZSH_CUSTOM if not already set
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# ============ Aliases ============
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

# ============ Functions ============
# Create and change to directory in one command
mcd() {
  mkdir -p "$1" && cd "$1"
}

# Find and open file with Neovim
nvimf() {
  nvim $(find . -name "*$1*" | fzf)
}

# Check if functions are properly loaded
check-functions() {
  echo "Testing key functions..."
  declare -f mcd > /dev/null && echo "✓ mcd (make directory and cd) function is available" || echo "✗ mcd function is not available"
  declare -f nvimf > /dev/null && echo "✓ nvimf (find and edit with neovim) function is available" || echo "✗ nvimf function is not available"
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
}

# fzf configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ============ Zsh-specific settings ============
setopt AUTO_PUSHD        # Push directories onto the directory stack
setopt PUSHD_IGNORE_DUPS # Don't push duplicates
setopt PUSHD_SILENT      # Don't print the directory stack after pushd/popd
setopt EXTENDED_GLOB     # Use extended globbing
setopt AUTO_CD           # Type directory name to cd

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Homebrew shellenv
eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrew ZSH Completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit
fi
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
mkdir -p "$HOME/.config/nvim/plugin"

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
-- Ruby: rubylsp (not ruby_lsp)
-- TypeScript: tsserver (not typescript-language-server)
-- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
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
        -- Use correct server names according to mason-lspconfig documentation
        ensure_installed = { 'lua_ls', 'rubylsp', 'pyright', 'tsserver' }
      })
      
      local lspconfig = require('lspconfig')
      
      -- Configure language servers with correct names
      lspconfig.lua_ls.setup{}      -- Lua language server
      lspconfig.rubylsp.setup{}     -- Ruby language server
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
      vim.g.vimwiki_list = {{path = '~/notes/', syntax = 'markdown', ext = '.md'}}
    end,
  },
}
EOL

# Set up Notes System
log_info "Setting up notes system..."

# Create notes directory structure
mkdir -p "$HOME/notes"
mkdir -p "$HOME/notes/daily"
mkdir -p "$HOME/notes/projects"
mkdir -p "$HOME/notes/learning"
mkdir -p "$HOME/notes/templates"
mkdir -p "$HOME/notes/private"  # Not tracked by git

# Create base note templates
log_info "Creating note templates..."

# Daily note template
cat > "$HOME/notes/templates/daily.md" << 'EOL'
# Daily Note: {{date}}

## Focus Areas
- 

## Notes
- 

## Tasks
- [ ] 

## Progress
- 

## Links
- 
EOL

# Project note template
cat > "$HOME/notes/templates/project.md" << 'EOL'
# Project: {{project_name}}

## Overview
- **Goal**: 
- **Timeline**: 
- **Status**: 

## Requirements
- 

## Notes
- 

## Tasks
- [ ] 

## Resources
- 
EOL

# Learning note template
cat > "$HOME/notes/templates/learning.md" << 'EOL'
# Learning: {{topic}}

## Objectives
- 

## Key Concepts
- 

## Code Examples
```
# Code example here
```

## Resources
- 

## Questions
- 

## Practice
- 
EOL

# Create notes.vim plugin for Neovim
log_info "Creating Neovim notes plugin..."
cat > "$HOME/.config/nvim/plugin/notes.vim" << 'EOL'
" Notes System Configuration

" Define the notes directory path
let g:notes_dir = expand('~/notes')

" Quickly open notes directory
command! Notes cd ${g:notes_dir}
command! NotesEdit edit ${g:notes_dir}

" Helper function to ensure directory exists before writing
function! EnsureDirectoryExists(dir)
  if !isdirectory(a:dir)
    call system('mkdir -p ' . shellescape(a:dir))
    if !isdirectory(a:dir)
      echoerr "Failed to create directory: " . a:dir
      return 0
    endif
  endif
  return 1
endfunction

" Create a new daily note
function! CreateDailyNote()
  let l:date = strftime('%Y-%m-%d')
  let l:daily_dir = g:notes_dir . '/daily'
  
  " Ensure daily directory exists
  if !EnsureDirectoryExists(l:daily_dir)
    return
  endif
  
  let l:file_path = l:daily_dir . '/' . l:date . '.md'
  execute 'edit ' . l:file_path
  
  " If file is new, populate with template
  if line('$') == 1 && getline(1) == ''
    let l:template_path = g:notes_dir . '/templates/daily.md'
    if filereadable(l:template_path)
      let l:template = readfile(l:template_path)
      call setline(1, l:template)
      " Replace {{date}} placeholder with actual date
      execute '%s/{{date}}/' . l:date . '/g'
    else
      echoerr "Template not found: " . l:template_path
    endif
  endif
endfunction

command! Daily call CreateDailyNote()

" Create a new project note
function! CreateProjectNote()
  let l:project = input('Project name: ')
  if l:project == ''
    return
  endif
  
  let l:project_dir = g:notes_dir . '/projects/' . l:project
  
  " Ensure project directory exists
  if !EnsureDirectoryExists(l:project_dir)
    return
  endif
  
  let l:file_path = l:project_dir . '/notes.md'
  execute 'edit ' . l:file_path
  
  " If file is new, populate with template
  if line('$') == 1 && getline(1) == ''
    let l:template_path = g:notes_dir . '/templates/project.md'
    if filereadable(l:template_path)
      let l:template = readfile(l:template_path)
      call setline(1, l:template)
      " Replace {{project_name}} placeholder with actual project name
      execute '%s/{{project_name}}/' . l:project . '/g'
    else
      echoerr "Template not found: " . l:template_path
    endif
  endif
endfunction

command! Project call CreateProjectNote()

" Create a new learning note
function! CreateLearningNote()
  let l:topic = input('Topic (e.g., ruby, python, javascript): ')
  if l:topic == ''
    return
  endif
  
  let l:subject = input('Subject name: ')
  if l:subject == ''
    return
  endif
  
  let l:learning_dir = g:notes_dir . '/learning/' . l:topic
  
  " Ensure learning directory exists
  if !EnsureDirectoryExists(l:learning_dir)
    return
  endif
  
  let l:file_path = l:learning_dir . '/' . l:subject . '.md'
  execute 'edit ' . l:file_path
  
  " If file is new, populate with template
  if line(') == 1 && getline(1) == ''
    let l:template_path = g:notes_dir . '/templates/learning.md'
    if filereadable(l:template_path)
      let l:template = readfile(l:template_path)
      call setline(1, l:template)
      " Replace {{topic}} placeholder with actual topic
      execute '%s/{{topic}}/' . l:subject . '/g'
    else
      echoerr "Template not found: " . l:template_path
    endif
  endif
endfunction

command! Learning call CreateLearningNote()

" Find notes with fzf (if available)
if exists(':FZF')
  command! NotesFind execute ':FZF ' . g:notes_dir
  command! NotesFiles execute ':Files ' . g:notes_dir
  
  " Define a command to search note contents
  command! NotesGrep execute ':Rg ' . g:notes_dir
  
  " Create a recent notes finder
  function! s:find_recent_notes()
    let l:command = 'find ' . shellescape(g:notes_dir) . ' -name "*.md" -type f -mtime -7 | sort -r'
    call fzf#run({
          \ 'source': l:command,
          \ 'sink': 'e',
          \ 'options': '--preview "cat {}"',
          \ 'down': '40%'
          \ })
  endfunction
  
  command! RecentNotes call s:find_recent_notes()
  
  " Key mappings for notes
  nnoremap <leader>fn :NotesFiles<CR>
  nnoremap <leader>fg :NotesGrep<CR>
  nnoremap <leader>fr :RecentNotes<CR>
  nnoremap <leader>fd :Daily<CR>
  nnoremap <leader>fp :Project<CR>
  nnoremap <leader>fl :Learning<CR>
endif
EOL

# Initialize Git repository for notes
log_info "Initializing Git repository for notes..."
cd "$HOME/notes"
git init

# Create .gitignore
cat > "$HOME/notes/.gitignore" << 'EOL'
.DS_Store
*.swp
*.swo
node_modules/
.obsidian/
private/
EOL

# Create README
cat > "$HOME/notes/README.md" << 'EOL'
# Terminal-Centric Notes System

A Git-based, cross-platform markdown notes system, optimized for terminal workflows with Neovim, tmux, and zsh.

## Overview

This repository contains a terminal-focused markdown notes system that automatically syncs across devices using Git.

## Key Features

- **Terminal Efficiency**: Built for Neovim, tmux, and zsh workflows
- **Git Integration**: Automatic syncing with Watchman
- **Cross-Platform**: Works on macOS, Linux, and Windows (via WSL)
- **Mouseless Operation**: Complete keyboard control for maximum productivity

## Usage

- Start notes session: `wk notes`
- Create daily note: `:Daily`
- Create project note: `:Project`
- Create learning note: `:Learning`
- Search notes: `<leader>fn` or `:NotesFind`

## Directory Structure

- **daily/**: Daily notes and journaling
- **projects/**: Project-specific notes
- **learning/**: Learning materials organized by topic
- **templates/**: Note templates
- **private/**: Untracked personal notes (gitignored)
EOL

# Make initial commit
git add .
git commit -m "Initial notes repository setup"

# Set up Watchman for auto-syncing
log_info "Setting up Watchman for auto-syncing notes..."

# Watch the notes directory
watchman watch "$HOME/notes"

# Create a trigger for markdown files
watchman -j << EOT
["trigger", "$(echo $HOME/notes)", {
  "name": "git-auto-sync",
  "expression": ["suffix", "md"],
  "command": ["zsh", "-c", "cd ~/notes && git add . && (git diff --quiet --exit-code --cached || git commit -m 'Auto-update notes') || true"]
}]
EOT

# Set up Launch Agent for Watchman (macOS only)
log_info "Setting up Launch Agent for Watchman..."
mkdir -p "$HOME/Library/LaunchAgents"

# Get path to watchman executable
WATCHMAN_PATH=$(which watchman)

cat > "$HOME/Library/LaunchAgents/com.facebook.watchman.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.facebook.watchman</string>
    <key>ProgramArguments</key>
    <array>
        <string>${WATCHMAN_PATH}</string>
        <string>--foreground</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/watchman.log</string>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/watchman.log</string>
</dict>
</plist>
EOL

# Load the agent
launchctl unload "$HOME/Library/LaunchAgents/com.facebook.watchman.plist" 2>/dev/null || true
launchctl load "$HOME/Library/LaunchAgents/com.facebook.watchman.plist"

# Create Neovim undodir if it doesn't exist
mkdir -p "$HOME/.vim/undodir"

# Install fzf
log_info "Installing fzf..."
brew install fzf
$(brew --prefix)/opt/fzf/install --all

# Install fonts
log_info "Installing fonts..."
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-hack-nerd-font

# Install Rectangle for window management
log_info "Installing Rectangle..."
brew install --cask rectangle

# Install tmux plugin manager
log_info "Installing tmux plugin manager..."
mkdir -p "$HOME/.tmux/plugins"
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# Final steps
log_success "Installation completed successfully!"

# Create shortcuts file
log_info "Creating quick reference guide..."
mkdir -p "$HOME/notes/docs"

cat > "$HOME/notes/docs/zsh_essential_shortcuts.md" << 'EOL'
# Zsh Essential Shortcuts

> A concise reference for your terminal workflow using Zsh, Neovim, and tmux

## System Navigation
- `Cmd + Space`: Spotlight search
- `Ctrl + Opt + ←/→/↑/↓`: Position windows with Rectangle
- `Cmd + Tab`: Switch applications

## Terminal (iTerm2)
- `Cmd + T`: New tab
- `Cmd + D`: Split vertically
- `Cmd + Shift + D`: Split horizontally
- `Cmd + Opt + ←/→/↑/↓`: Navigate between panes

## Zsh Navigation
- `cd -`: Navigate to previous directory
- `cd -<TAB>`: Show directory history with numbers
- `..`, `...`, `....`: Go up 1, 2, or 3 directories
- `/path/to/dir`: Navigate without typing 'cd' (AUTO_CD enabled)
- `dirs -v`: List directory stack with numbers (AUTO_PUSHD enabled)

## Zsh Command Editing
- `Ctrl+A/E`: Move to beginning/end of line
- `Ctrl+U/K`: Clear line before/after cursor
- `Ctrl+W`: Delete word before cursor
- `Alt+F/B`: Move forward/backward one word
- `Ctrl+R`: Search command history

## tmux
> Prefix key is `Ctrl + a`
- `prefix + c`: Create new window
- `prefix + n/p`: Next/previous window
- `prefix + [number]`: Go to window [number]
- `prefix + |`: Split vertically
- `prefix + -`: Split horizontally
- `prefix + ←/→/↑/↓`: Navigate panes
- `prefix + d`: Detach session

## tmux Commands
- `ta [name]`: Attach to session [name] (alias)
- `tls`: List sessions (alias)
- `tn [name]`: Create new session [name] (alias)
- `tk [name]`: Kill session [name] (alias)
- `wk dev`: Start unified dev session (function)
- `wk notes`: Start unified notes session (function)

## Neovim Basics
> Leader key is `Space`
- `<leader>e`: Toggle file explorer (NvimTree)
- `<leader>ff`: Find files with Telescope
- `<leader>fg`: Live grep with Telescope
- `<leader>w`: Save file
- `<leader>q`: Quit
- `<leader>h`: Clear search highlighting
- `<leader>?`: Show common key mappings

## Neovim Navigation
- `Ctrl + h/j/k/l`: Navigate between splits
- `gd`: Go to definition (LSP)
- `K`: Hover documentation (LSP)
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action

## Git Aliases
- `gs`: git status
- `ga`: git add
- `gc "message"`: git commit
- `gp`: git push
- `gl`: git pull
- `<leader>gs`: Open Git status (Fugitive)

## Notes System Commands
- `:Daily`: Create/edit today's daily note
- `:Project`: Create/edit a project note
- `:Learning`: Create/edit a learning note
- `<leader>fn`: Find notes files
- `<leader>fg`: Search within notes
- `<leader>fr`: Show recently modified notes

## Custom Functions
- `mcd [dir]`: Create directory and change to it
- `nvimf [pattern]`: Find and open file with Neovim
- `check-functions`: Verify that key functions are loaded
- `wk [dev|notes]`: Start a structured tmux session for development or notes
EOL

# Add shortcuts to the notes repository
cd "$HOME/notes"
git add docs/zsh_essential_shortcuts.md
git commit -m "Add essential shortcuts reference"

echo ""
echo "==================================================================="
echo "                    NEXT STEPS AND NOTES                         "
echo "==================================================================="
echo ""
echo "IMPORTANT: This environment requires Zsh shell!"
echo ""
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "1. Zsh has been installed and set as your default shell, but"
    echo "   this will only take effect after you log out and back in."
    echo "   To start using Zsh right now, run: zsh"
    echo ""
fi
echo "2. Configure your terminal:"
echo "   - iTerm2: Preferences → Profiles → Text → Font → Select 'JetBrainsMono Nerd Font'"
echo "   - VS Code Terminal (if you use it): "
echo "     • Settings → Terminal → Default Profile → Select 'zsh'"
echo "     • Settings → Terminal › Integrated: Font Family → 'JetBrainsMono Nerd Font'"
echo ""
echo "3. Run 'p10k configure' to set up the Powerlevel10k theme"
echo ""
echo "4. Install the notes system to your GitHub account (if desired):"
echo "   cd ~/notes"
echo "   gh repo create notes --private"
echo "   git remote add origin <your-repo-url>"
echo "   git push -u origin main"
echo ""
echo "5. Open Neovim and let it install plugins (it may show errors on first run)"
echo ""
echo "6. In tmux, press Ctrl+a followed by 'I' to install tmux plugins"
echo ""
echo "7. Your old configurations are backed up in: $BACKUP_DIR"
echo ""
echo "8. Start your development workflow with: wk dev"
echo "   Start your notes workflow with: wk notes"
echo ""
echo "9. Access the shortcuts reference at: ~/notes/docs/zsh_essential_shortcuts.md"
echo ""
echo "Enjoy your integrated terminal development environment!"
echo ""
