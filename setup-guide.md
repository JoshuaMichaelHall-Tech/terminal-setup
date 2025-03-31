# Complete Setup Guide: Terminal Development Environment

This comprehensive guide will walk you through setting up your integrated terminal-based development environment on macOS, combining both general development and notes-taking capabilities.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Core Components](#core-components)
3. [macOS Initial Setup](#macos-initial-setup)
4. [Zsh Configuration](#zsh-configuration)
5. [Neovim Configuration](#neovim-configuration)
6. [tmux Configuration](#tmux-configuration)
7. [Notes System Setup](#notes-system-setup)
8. [Watchman for Auto-Syncing](#watchman-for-auto-syncing)
9. [Additional Tools](#additional-tools)
10. [Maintenance and Updates](#maintenance-and-updates)
11. [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have the following:

- macOS (10.15 Catalina or newer)
- Administrative access to your machine
- Basic terminal knowledge

## Core Components

This environment integrates:

- **Terminal**: iTerm2 with custom configuration
- **Shell**: Zsh with Oh My Zsh
- **Text Editor**: Neovim with LSP support
- **Terminal Multiplexer**: tmux for session management
- **Version Control**: Git with Fugitive integration
- **Notes System**: Git-backed markdown notes
- **Automation**: Watchman for file monitoring and sync

## macOS Initial Setup

### 1. Install Homebrew

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add Homebrew to your PATH:
```zsh
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Install Core Packages

```zsh
# Install essential tools
brew install git curl wget ripgrep fd jq tree

# Install programming languages
brew install python node ruby

# Install terminal tools
brew install --cask iterm2
brew install neovim tmux watchman fzf
```

### 3. Install Fonts

```zsh
# Install Nerd Fonts for icons and ligatures
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-hack-nerd-font
```

### 4. Install Rectangle for Window Management

```zsh
brew install --cask rectangle
```

## Zsh Configuration

### 1. Install Oh My Zsh

```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 2. Install Powerlevel10k Theme

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 3. Install Zsh Plugins

```zsh
# Install auto-suggestions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install syntax highlighting plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 4. Configure .zshrc

Create a comprehensive `.zshrc` file:

```zsh
# Enable Powerlevel10k instant prompt
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
  declare -f mcd > /dev/null && echo "✓ mcd function is available" || echo "✗ mcd function is not available"
  declare -f nvimf > /dev/null && echo "✓ nvimf function is available" || echo "✗ nvimf function is not available"
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
```

Save this to `~/.zshrc` and apply the changes:

```zsh
source ~/.zshrc
```

Configure the Powerlevel10k theme:
```zsh
p10k configure
```

## Neovim Configuration

### 1. Set Up Neovim Directory Structure

```zsh
mkdir -p ~/.config/nvim/lua
mkdir -p ~/.vim/undodir
```

### 2. Create init.lua

Create `~/.config/nvim/init.lua` with:

```lua
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
```

### 3. Create plugins.lua

Create `~/.config/nvim/lua/plugins.lua` with:

```lua
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
```

## tmux Configuration

### 1. Create .tmux.conf

Create `~/.tmux.conf` with:

```
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
```

### 2. Install tmux Plugin Manager

```zsh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Install tmux Plugins

Start a tmux session:
```zsh
tmux
```

Press `Ctrl+a` followed by `I` to install plugins.

## Notes System Setup

### 1. Create Notes Directory Structure

```zsh
mkdir -p ~/notes/{daily,projects,learning,templates,private}
```

### 2. Create Base Note Templates

```zsh
# Daily note template
cat > ~/notes/templates/daily.md << 'EOL'
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
cat > ~/notes/templates/project.md << 'EOL'
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
cat > ~/notes/templates/learning.md << 'EOL'
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
```

### 3. Set Up Git Repository

```zsh
cd ~/notes
git init
```

Create a `.gitignore` file:
```zsh
cat > ~/notes/.gitignore << 'EOL'
.DS_Store
*.swp
*.swo
node_modules/
.obsidian/
private/
EOL
```

Create a README:
```zsh
cat > ~/notes/README.md << 'EOL'
# Terminal-Centric Notes System

A Git-based, cross-platform markdown notes system, optimized for terminal workflows with Neovim, tmux, and zsh.

## Overview

This repository contains a terminal-focused markdown notes system that automatically syncs across devices using Git.

## Key Features

- **Terminal Efficiency**: Built for Neovim, tmux, and zsh workflows
- **Git Integration**: Automatic syncing
- **Mouseless Operation**: Complete keyboard control for maximum productivity

## Usage

- Start notes session: `wk notes`
- Create daily note: `:Daily`
- Create project note: `:Project`
- Create learning note: `:Learning`
- Search notes: `<leader>fn` or `:NotesFind`
EOL
```

Make the initial commit:
```zsh
git add .
git commit -m "Initial notes repository setup"
```

### 4. Configure Neovim for Notes

Create a notes plugin file for Neovim:

```zsh
mkdir -p ~/.config/nvim/plugin
```

Create `~/.config/nvim/plugin/notes.vim` with:

```vim
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
  if line(') == 1 && getline(1) == ''
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
  if line(') == 1 && getline(1) == ''
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
```

## Watchman for Auto-Syncing

### 1. Set Up Watchman for Notes

```zsh
cd ~/notes

# Stop existing watchman instance if running
watchman shutdown-server 2>/dev/null || true

# Watch the notes directory
watchman watch ~/notes

# Create a trigger for markdown files
watchman -j << EOT
["trigger", "$(echo ~/notes)", {
  "name": "git-auto-sync",
  "expression": ["suffix", "md"],
  "command": ["zsh", "-c", "cd ~/notes && git add . && (git diff --quiet --exit-code --cached || git commit -m 'Auto-update notes') || true"]
}]
EOT
```

### 2. Set Up Launch Agent for Watchman (macOS only)

```zsh
mkdir -p ~/Library/LaunchAgents

# Get path to watchman executable
WATCHMAN_PATH=$(which watchman)

cat > ~/Library/LaunchAgents/com.facebook.watchman.plist << EOL
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
    <string>~/Library/Logs/watchman.log</string>
    <key>StandardOutPath</key>
    <string>~/Library/Logs/watchman.log</string>
</dict>
</plist>
EOL

# Load the agent
launchctl unload ~/Library/LaunchAgents/com.facebook.watchman.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/com.facebook.watchman.plist
```

## Additional Tools

### 1. Set Up GitHub CLI

```zsh
brew install gh
gh auth login
```

Follow the prompts to authenticate with GitHub.

### 2. Set Up Git Configuration

```zsh
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. Install Additional Productivity Tools

```zsh
# Install ranger file manager
brew install ranger

# Install ripgrep for faster searching
brew install ripgrep
```

## Maintenance and Updates

### 1. Update All Components

Create an update script:

```zsh
cat > ~/bin/update-env.sh << 'EOL'
#!/bin/zsh

# Update Homebrew and packages
echo "Updating Homebrew packages..."
brew update && brew upgrade

# Update Oh My Zsh
echo "Updating Oh My Zsh..."
omz update

# Update Neovim plugins
echo "Updating Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

# Update tmux plugins
echo "Updating tmux plugins..."
~/.tmux/plugins/tpm/bin/update_plugins all

echo "All components updated!"
EOL

chmod +x ~/bin/update-env.sh
```

### 2. Create Backup Script

```zsh
cat > ~/bin/backup-config.sh << 'EOL'
#!/bin/zsh

# Backup directory
BACKUP_DIR=~/config_backup_$(date +%Y%m%d)
mkdir -p $BACKUP_DIR

# Backup zsh config
cp ~/.zshrc $BACKUP_DIR/
cp ~/.p10k.zsh $BACKUP_DIR/ 2>/dev/null

# Backup Neovim config
cp -r ~/.config/nvim $BACKUP_DIR/

# Backup tmux config
cp ~/.tmux.conf $BACKUP_DIR/

# Backup Git config
cp ~/.gitconfig $BACKUP_DIR/

echo "Backup completed to $BACKUP_DIR"
EOL

chmod +x ~/bin/backup-config.sh
```

## Troubleshooting

### Common Issues and Solutions

#### Neovim Plugin Installation Fails

```zsh
# Remove plugin cache and try again
rm -rf ~/.local/share/nvim/lazy
nvim # Reopen Neovim to reinstall plugins
```

#### LSP Server Installation Issues

```zsh
# Open Mason in Neovim to manually install servers
nvim
:Mason
```

Navigate to the server you want to install and press `i` to install it.

#### Watchman Not Working

```zsh
# Reset Watchman
watchman shutdown-server
rm -rf ~/.watchman
watchman watch ~/notes
```

#### tmux Session Issues

```zsh
# Kill tmux server and restart
tmux kill-server
tmux new -s dev
```

#### Zsh Functions Not Loading

```zsh
# Check if functions are loaded
check-functions

# If not, try reloading .zshrc
source ~/.zshrc
```

This completes the integrated terminal development environment setup guide. Your environment now combines a powerful general development setup with a comprehensive notes system, all accessible through a unified terminal workflow.
