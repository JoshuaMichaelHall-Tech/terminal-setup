# Complete Mouseless MacOS Development Environment Setup Tutorial

This tutorial will guide you through setting up a complete mouseless development environment on MacOS, focusing on maximum productivity through keyboard-driven workflows.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Core System Setup](#core-system-setup)
3. [Terminal Configuration](#terminal-configuration)
4. [Shell Configuration](#shell-configuration)
5. [Neovim Setup](#neovim-setup)
6. [Tmux Configuration](#tmux-configuration)
7. [Git and GitHub Integration](#git-and-github-integration)
8. [Productivity Tools](#productivity-tools)
9. [Note-taking System](#note-taking-system)
10. [File Management Tools](#file-management-tools)
11. [Project Management](#project-management)
12. [Workflow Examples](#workflow-examples)
13. [Troubleshooting](#troubleshooting)

## Prerequisites

Before beginning, ensure you have:
- A MacOS system (10.15 Catalina or newer recommended)
- Administrator access
- Internet connection
- Basic familiarity with terminal commands

## Core System Setup

### Installing Homebrew

Homebrew is the foundation of our setup, allowing easy installation of most tools.

1. Open Terminal (Applications > Utilities > Terminal)
2. Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Add Homebrew to your PATH (follow instructions shown after installation)
4. Verify installation:

```bash
brew --version
```

### Installing Essential Packages

Install several core packages that we'll need throughout the setup:

```bash
brew install git curl wget tree htop ripgrep fd jq python node ruby
```

## Terminal Configuration

### Installing and Configuring iTerm2

1. Install iTerm2:

```bash
brew install --cask iterm2
```

2. Launch iTerm2 and open Preferences (⌘,)

3. Configure appearance:
   - Go to Profiles > Colors
   - Select a color preset (Recommended: Solarized Dark, Dracula, or One Dark)
   - Go to Profiles > Text
   - Choose a programming font with ligatures (Recommended: JetBrains Mono, Fira Code, or Hack)
   - Set font size to 14-16pt

4. Window settings:
   - Go to Profiles > Window
   - Set window dimensions to 140×40
   - Enable "Blur" for transparency effect (optional)

5. Enable Natural Text Editing:
   - Go to Profiles > Keys
   - Click "Load Preset..." and select "Natural Text Editing"
   - This enables using Option+arrow keys to move by word and other familiar text editing shortcuts

6. Save your profile:
   - Go to Profiles > General
   - Click "Other Actions..." > "Set as Default"

## Shell Configuration

### Setting Up Zsh and Oh My Zsh

1. Install Oh My Zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Install Powerlevel10k theme (optional but recommended):

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

3. Edit your .zshrc file:

```bash
nvim ~/.zshrc
```

4. Set the theme:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

5. Configure useful plugins by finding the `plugins=` line and updating it:

```bash
plugins=(git ruby python node npm macos tmux docker web-search zsh-autosuggestions zsh-syntax-highlighting)
```

6. Install additional plugins:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

7. Add useful aliases to your .zshrc:

```bash
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
```

8. Source the file to activate changes:

```bash
source ~/.zshrc
```

9. Run the Powerlevel10k configuration wizard:

```bash
p10k configure
```

## Neovim Setup

### Basic Installation and Configuration

1. Install Neovim:

```bash
brew install neovim
```

2. Create the Neovim configuration directory:

```bash
mkdir -p ~/.config/nvim
```

3. Create a basic init.lua file:

```bash
nvim ~/.config/nvim/init.lua
```

4. Add basic settings to init.lua:

```lua
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
```

### Setting Up Lazy.nvim as Package Manager

1. Install Lazy.nvim:

```bash
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/lazy/lazy.nvim
```

2. Create a lua/plugins.lua file:

```bash
mkdir -p ~/.config/nvim/lua
nvim ~/.config/nvim/lua/plugins.lua
```

3. Add basic plugins configuration:

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
        ensure_installed = { 'lua_ls', 'ruby_ls', 'pyright', 'tsserver' }
      })
      
      local lspconfig = require('lspconfig')
      
      -- Basic LSP setup for the languages you use
      lspconfig.lua_ls.setup{}
      lspconfig.ruby_ls.setup{}
      lspconfig.pyright.setup{}
      lspconfig.tsserver.setup{}
      
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
```

4. Update init.lua to load the plugins:

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

-- Add at the beginning of your init.lua
require("lazy").setup("plugins")
```

5. Open Neovim and let it install the plugins:

```bash
nvim
```

## Tmux Configuration

### Installation and Basic Setup

1. Install Tmux:

```bash
brew install tmux
```

2. Create a .tmux.conf file:

```bash
nvim ~/.tmux.conf
```

3. Add the following configuration:

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

# Enable mouse control (clickable windows, panes, resizable panes)
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
```

4. Reload the configuration:

```bash
tmux source-file ~/.tmux.conf
```

5. Install TPM (Tmux Plugin Manager):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

6. Add TPM and some useful plugins to your .tmux.conf:

```
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'

# Initialize TPM (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

7. Reload config and install plugins:
   - Press `Ctrl+A` followed by `I` to install plugins

### Basic Tmux Usage

1. Start a new session:

```bash
tmux new -s dev
```

2. Common commands (always preceded by prefix key `Ctrl+A`):
   - `c`: Create a new window
   - `n`/`p`: Next/previous window
   - `%`: Split pane vertically
   - `"`: Split pane horizontally
   - `arrow keys`: Navigate between panes
   - `d`: Detach from session
   - `[`: Enter copy mode (use vi navigation)

3. Reattach to a session:

```bash
tmux attach -t dev
```

## Git and GitHub Integration

### Git Configuration

1. Configure Git:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

2. Generate SSH key for GitHub:

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

3. Start the SSH agent and add your key:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

4. Copy your public key:

```bash
cat ~/.ssh/id_ed25519.pub | pbcopy
```

5. Add the key to your GitHub account:
   - Go to GitHub.com > Settings > SSH and GPG keys
   - Click "New SSH key"
   - Paste your key and save

### GitHub CLI

1. Install GitHub CLI:

```bash
brew install gh
```

2. Authenticate with GitHub:

```bash
gh auth login
```

3. Try some common commands:

```bash
# Create a repository
gh repo create my-project --public

# Clone a repository
gh repo clone username/repository

# Create a pull request
gh pr create

# View issues
gh issue list
```

## Productivity Tools

### Rectangle (Window Management)

1. Install Rectangle:

```bash
brew install --cask rectangle
```

2. Launch Rectangle and set it to start automatically
3. Learn the keyboard shortcuts:
   - `Ctrl+Option+Left`: Left half
   - `Ctrl+Option+Right`: Right half
   - `Ctrl+Option+Enter`: Fullscreen
   - `Ctrl+Option+C`: Center

### Alfred (App Launcher and More)

1. Install Alfred:

```bash
brew install --cask alfred
```

2. Launch Alfred and:
   - Set the hotkey (typically `Option+Space`)
   - Enable clipboard history
   - Set up basic workflows

### Karabiner-Elements (Keyboard Customization)

1. Install Karabiner-Elements:

```bash
brew install --cask karabiner-elements
```

2. Launch and set permissions as requested
3. Configure to map Caps Lock to Escape when tapped, Control when held:
   - Go to "Complex Modifications"
   - Click "Add rule" 
   - Import from internet
   - Search for "Change caps_lock to control if pressed with other keys, to escape if pressed alone"
   - Enable the rule

## Note-taking System

### Vimwiki in Neovim

1. Vimwiki should already be installed from the Neovim setup
2. Access your wiki:
   - In Neovim, press `<leader>ww` to access your wiki index
   - Create pages with `<leader>wn`
   - Follow links by pressing Enter on a wiki link

### Obsidian (Optional)

1. Install Obsidian:

```bash
brew install --cask obsidian
```

2. Launch Obsidian and:
   - Create a new vault in ~/vimwiki to share with Vimwiki
   - Enable Vim mode in Settings > Editor
   - Install plugins:
     - Calendar
     - Templater
     - Dataview

## File Management Tools

### Ranger (Terminal File Manager)

1. Install Ranger:

```bash
brew install ranger
```

2. Generate the default configuration:

```bash
ranger --copy-config=all
```

3. Configure Ranger:

```bash
nvim ~/.config/ranger/rc.conf
```

4. Add useful settings:

```
# Enable image previews (if using iTerm2)
set preview_images true
set preview_images_method iterm2

# Use rifle for opening files
set open_all_images true

# Faster navigation
map J move down=5
map K move up=5

# Show hidden files
set show_hidden true
```

### fzf (Fuzzy Finder)

1. Install fzf:

```bash
brew install fzf
```

2. Install shell extensions:

```bash
$(brew --prefix)/opt/fzf/install
```

3. Add to your .zshrc:

```bash
# fzf configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
```

## Project Management

### Taskwarrior

1. Install Taskwarrior:

```bash
brew install task
```

2. Initialize:

```bash
task
```

3. Basic usage:

```bash
# Add a task
task add "Learn tmux keybindings" project:setup priority:H

# List tasks
task list

# Complete a task
task 1 done

# Modify a task
task 2 modify priority:M
```

## Workflow Examples

### Example 1: Starting a New Ruby Project

1. Create a new tmux session:

```bash
tmux new -s ruby-project
```

2. Create a new GitHub repository:

```bash
gh repo create ruby-project --public --clone
```

3. Set up project structure:

```bash
cd ruby-project
mkdir -p lib bin test
touch README.md LICENSE Gemfile
```

4. Open in Neovim:

```bash
nvim
```

5. Use NvimTree to navigate (`<leader>e`), Telescope to find files (`<leader>ff`), and LSP for autocompletion.

### Example 2: Daily Development Workflow

1. Start or attach to your tmux session:

```bash
tmux attach -t dev || tmux new -s dev
```

2. Create or manage windows for different contexts:
   - Window 1: Project code
   - Window 2: Server/tests
   - Window 3: Git/utility commands

3. Use Vim sessions to restore your workspace:

```bash
# Save session
:mksession! ~/sessions/myproject.vim

# Restore session
nvim -S ~/sessions/myproject.vim
```

### Example 3: Taking Notes During Work

1. Open notes quickly from anywhere:

```bash
nvim -c VimwikiIndex
```

2. Create a daily journal:

```
# Inside Vimwiki
<leader>w<leader>i
```

3. Link notes to projects for reference.

## Troubleshooting

### Common Issues and Solutions

1. **Neovim plugins not working**:
   - Check plugin installation: `:checkhealth`
   - Ensure dependencies are installed
   - Review error messages: `:messages`

2. **Tmux color issues**:
   - Ensure your terminal supports 256 colors
   - Check `$TERM` environment variable
   - Try adding `set -g default-terminal "screen-256color"` to .tmux.conf

3. **SSH key authentication failure**:
   - Ensure the SSH agent is running: `eval "$(ssh-agent -s)"`
   - Add your key: `ssh-add ~/.ssh/id_ed25519`
   - Verify key is registered: `ssh-add -l`

4. **Terminal text rendering issues**:
   - Ensure you're using a patched font (e.g., a Nerd Font)
   - Install fonts: `brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font`

### Maintenance

1. Keep your environment updated:

```bash
# Update Homebrew packages
brew update && brew upgrade

# Update Neovim plugins
# Inside Neovim: :Lazy update

# Update Tmux plugins
# In Tmux: PREFIX + U

# Update Oh My Zsh
omz update
```

2. Backup your configurations:

```bash
# Create a dotfiles repository
mkdir -p ~/dotfiles
cd ~/dotfiles
git init
```

3. Add your configuration files:

```bash
# Use symbolic links or copy files
ln -sf ~/.zshrc ~/dotfiles/.zshrc
ln -sf ~/.tmux.conf ~/dotfiles/.tmux.conf
ln -sf ~/.config/nvim ~/dotfiles/nvim
# Add more as needed

# Track with Git
git add .
git commit -m "Initial dotfiles setup"

# Create a GitHub repository
gh repo create dotfiles --private
git push -u origin main
```

## Conclusion

Congratulations! You now have a fully configured mouseless development environment on MacOS. This setup will significantly improve your productivity by keeping your hands on the keyboard. 

Continue refining your environment as you discover your workflow patterns. Remember that proficiency with these tools takes time and deliberate practice. Keep your cheat sheet handy and gradually expand your keyboard shortcut knowledge.

Happy coding!
