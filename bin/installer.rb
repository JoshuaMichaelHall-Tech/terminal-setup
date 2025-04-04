#!/usr/bin/env ruby
# Terminal Environment Installer
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'
require 'open3'
require 'date'

# Color definitions
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def red
    colorize(31)
  end

  def blue
    colorize(34)
  end
end

# Constants
HOME_DIR = ENV['HOME']
INSTALL_DIR = File.join(HOME_DIR, '.terminal-env')
CONFIG_DIRS = {
  nvim: File.join(HOME_DIR, '.config/nvim'),
  bin: File.join(HOME_DIR, 'bin'),
  notes: File.join(HOME_DIR, 'notes'),
  tmux: File.join(HOME_DIR, '.tmux'),
  undodir: File.join(HOME_DIR, '.vim/undodir')
}

CONFIG_FILES = {
  zshrc: File.join(HOME_DIR, '.zshrc'),
  tmux_conf: File.join(HOME_DIR, '.tmux.conf'),
  p10k: File.join(HOME_DIR, '.p10k.zsh'),
  nvim_init: File.join(CONFIG_DIRS[:nvim], 'init.lua'),
  nvim_plugins: File.join(CONFIG_DIRS[:nvim], 'lua/plugins.lua'),
  notes_vim: File.join(CONFIG_DIRS[:nvim], 'plugin/notes.vim')
}

TEMPLATE_DIRS = {
  notes_daily: File.join(CONFIG_DIRS[:notes], 'daily'),
  notes_projects: File.join(CONFIG_DIRS[:notes], 'projects'),
  notes_learning: File.join(CONFIG_DIRS[:notes], 'learning'),
  notes_templates: File.join(CONFIG_DIRS[:notes], 'templates')
}

REQUIRED_TOOLS = {
  'zsh' => 'brew install zsh',
  'nvim' => 'brew install neovim',
  'tmux' => 'brew install tmux',
  'git' => 'brew install git',
  'watchman' => 'brew install watchman',
  'fzf' => 'brew install fzf'
}

# Installation modes
FULL_INSTALL = 1
MINIMAL_UPDATE = 2
PERMISSIONS_FIX = 3
UNINSTALL = 4

# Helper Methods
def print_header(text)
  puts "\n#{"=" * 70}".blue
  puts "  #{text}".blue
  puts "#{"=" * 70}".blue
  puts
end

def command_exists?(command)
  system("command -v #{command} > /dev/null 2>&1")
end

def file_exists?(file)
  File.exist?(file)
end

def check_result(message, result = $?.success?)
  if result
    puts "✓ #{message}".green
    return true
  else
    puts "✗ #{message}".red
    return false
  end
end

def create_directory(dir)
  return true if Dir.exist?(dir)
  
  FileUtils.mkdir_p(dir)
  check_result("Created directory: #{dir}")
rescue StandardError => e
  puts "Error creating directory #{dir}: #{e.message}".red
  false
end

def create_file(file, content)
  create_directory(File.dirname(file))
  
  File.open(file, 'w') do |f|
    f.write(content)
  end
  check_result("Created file: #{file}")
rescue StandardError => e
  puts "Error creating file #{file}: #{e.message}".red
  false
end

def file_contains?(file, pattern)
  return false unless File.exist?(file)
  
  File.read(file) =~ Regexp.new(pattern)
end

def append_to_file(file, content)
  return false unless File.exist?(file)
  
  File.open(file, 'a') do |f|
    f.puts content
  end
  check_result("Updated file: #{file}")
rescue StandardError => e
  puts "Error updating file #{file}: #{e.message}".red
  false
end

def add_line_if_not_exists(file, line)
  return false unless File.exist?(file)
  return true if file_contains?(file, Regexp.escape(line))
  
  append_to_file(file, line)
end

def check_and_add_alias(file, alias_name, command)
  pattern = "alias\\s+#{alias_name}\\s*="
  
  if !file_contains?(file, pattern)
    append_to_file(file, "\n# Added by installer script\nalias #{alias_name}='#{command}'")
    puts "Added alias #{alias_name} to #{file}".green
    return true
  end
  
  puts "Alias #{alias_name} already exists in #{file}".green
  true
end

def backup_file(file)
  return false unless File.exist?(file)
  
  backup = "#{file}.bak.#{Time.now.strftime('%Y%m%d%H%M%S')}"
  FileUtils.cp(file, backup)
  check_result("Created backup: #{backup}")
rescue StandardError => e
  puts "Error backing up file #{file}: #{e.message}".red
  false
end

def run_command(command)
  stdout, stderr, status = Open3.capture3(command)
  success = status.success?
  
  return [stdout, success]
rescue StandardError => e
  puts "Error running command '#{command}': #{e.message}".red
  return ["", false]
end

def create_backup_directory
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  backup_dir = File.join(HOME_DIR, "terminal_env_backup_#{timestamp}")
  
  create_directory(backup_dir)
  puts "Created backup directory: #{backup_dir}".green
  
  backup_dir
end

def backup_existing_configs(backup_dir)
  print_header("Backing Up Existing Configurations")
  
  # Backup Neovim config
  if Dir.exist?(CONFIG_DIRS[:nvim])
    nvim_backup = File.join(backup_dir, 'nvim')
    FileUtils.cp_r(CONFIG_DIRS[:nvim], nvim_backup)
    puts "Backed up Neovim config to #{nvim_backup}".green
  end
  
  # Backup tmux config
  if File.exist?(CONFIG_FILES[:tmux_conf])
    tmux_backup = File.join(backup_dir, 'tmux.conf')
    FileUtils.cp(CONFIG_FILES[:tmux_conf], tmux_backup)
    puts "Backed up tmux config to #{tmux_backup}".green
  end
  
  # Backup Zsh config
  if File.exist?(CONFIG_FILES[:zshrc])
    zsh_backup = File.join(backup_dir, 'zshrc')
    FileUtils.cp(CONFIG_FILES[:zshrc], zsh_backup)
    puts "Backed up .zshrc to #{zsh_backup}".green
  end
  
  # Backup p10k config
  if File.exist?(CONFIG_FILES[:p10k])
    p10k_backup = File.join(backup_dir, 'p10k.zsh')
    FileUtils.cp(CONFIG_FILES[:p10k], p10k_backup)
    puts "Backed up .p10k.zsh to #{p10k_backup}".green
  end
  
  # Backup notes templates if they exist
  if Dir.exist?(File.join(CONFIG_DIRS[:notes], 'templates'))
    templates_backup = File.join(backup_dir, 'notes_templates')
    FileUtils.mkdir_p(templates_backup)
    FileUtils.cp_r(Dir.glob(File.join(CONFIG_DIRS[:notes], 'templates', '*')), templates_backup)
    puts "Backed up notes templates to #{templates_backup}".green
  end
  
  puts "All existing configurations backed up to #{backup_dir}".green
end

# Installation functions
def install_homebrew
  print_header("Installing Homebrew")
  
  if command_exists?('brew')
    puts "Homebrew is already installed, updating...".yellow
    run_command('brew update')
    check_result("Updated Homebrew")
    return true
  end
  
  puts "Installing Homebrew...".blue
  install_cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  output, success = run_command(install_cmd)
  
  if success
    puts "Homebrew installed successfully".green
    
    # Add Homebrew to PATH for current session
    if File.exist?('/opt/homebrew/bin/brew')
      ENV['PATH'] = "/opt/homebrew/bin:#{ENV['PATH']}"
      check_result("Added Homebrew to PATH for current session")
      
      # Add Homebrew to PATH permanently if not already there
      if !file_contains?(CONFIG_FILES[:zshrc], 'eval.*brew shellenv')
        add_line_if_not_exists(CONFIG_FILES[:zshrc], 'eval "$(/opt/homebrew/bin/brew shellenv)"')
        check_result("Added Homebrew to PATH permanently")
      end
    end
    
    return true
  else
    puts "Failed to install Homebrew".red
    puts "Please install Homebrew manually from https://brew.sh".yellow
    return false
  end
end

def install_required_tools
  print_header("Installing Required Tools")
  
  success = true
  REQUIRED_TOOLS.each do |tool, install_cmd|
    if command_exists?(tool)
      version, version_success = run_command("#{tool} --version")
      version = version.lines.first.strip if version_success
      puts "#{tool} is already installed: #{version}".green
    else
      puts "Installing #{tool}...".blue
      output, install_success = run_command(install_cmd)
      
      if install_success
        puts "#{tool} installed successfully".green
      else
        puts "Failed to install #{tool}".red
        puts "Please install #{tool} manually with: #{install_cmd}".yellow
        success = false
      end
    end
  end
  
  success
end

def install_fonts
  print_header("Installing Nerd Fonts")
  
  # Tap homebrew fonts
  run_command('brew tap homebrew/cask-fonts')
  
  # Install JetBrainsMono Nerd Font
  if !system('brew list --cask font-jetbrains-mono-nerd-font &>/dev/null')
    puts "Installing JetBrainsMono Nerd Font...".blue
    output, success = run_command('brew install --cask font-jetbrains-mono-nerd-font')
    check_result("Installed JetBrainsMono Nerd Font", success)
  else
    puts "JetBrainsMono Nerd Font is already installed".green
  end
  
  # Install Hack Nerd Font
  if !system('brew list --cask font-hack-nerd-font &>/dev/null')
    puts "Installing Hack Nerd Font...".blue
    output, success = run_command('brew install --cask font-hack-nerd-font')
    check_result("Installed Hack Nerd Font", success)
  else
    puts "Hack Nerd Font is already installed".green
  end
  
  true
end

def install_oh_my_zsh
  print_header("Installing Oh My Zsh")
  
  if Dir.exist?(File.join(HOME_DIR, '.oh-my-zsh'))
    puts "Oh My Zsh is already installed".green
    return true
  end
  
  puts "Installing Oh My Zsh...".blue
  install_cmd = 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
  output, success = run_command(install_cmd)
  
  if success
    puts "Oh My Zsh installed successfully".green
    return true
  else
    puts "Failed to install Oh My Zsh".red
    puts "Please install Oh My Zsh manually".yellow
    return false
  end
end

def install_powerlevel10k
  print_header("Installing Powerlevel10k")
  
  p10k_theme_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/themes/powerlevel10k')
  
  if Dir.exist?(p10k_theme_dir)
    puts "Powerlevel10k theme is already installed, updating...".yellow
    Dir.chdir(p10k_theme_dir) do
      run_command('git pull')
    end
    check_result("Updated Powerlevel10k theme")
    return true
  end
  
  puts "Installing Powerlevel10k theme...".blue
  install_cmd = "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git #{p10k_theme_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "Powerlevel10k theme installed successfully".green
    return true
  else
    puts "Failed to install Powerlevel10k theme".red
    puts "Please install Powerlevel10k theme manually".yellow
    return false
  end
end

def install_zsh_plugins
  print_header("Installing Zsh Plugins")
  
  custom_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/plugins')
  
  # Install zsh-autosuggestions
  autosuggestions_dir = File.join(custom_dir, 'zsh-autosuggestions')
  if Dir.exist?(autosuggestions_dir)
    puts "zsh-autosuggestions is already installed, updating...".yellow
    Dir.chdir(autosuggestions_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-autosuggestions")
  else
    puts "Installing zsh-autosuggestions...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-autosuggestions #{autosuggestions_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-autosuggestions", success)
  end
  
  # Install zsh-syntax-highlighting
  syntax_highlighting_dir = File.join(custom_dir, 'zsh-syntax-highlighting')
  if Dir.exist?(syntax_highlighting_dir)
    puts "zsh-syntax-highlighting is already installed, updating...".yellow
    Dir.chdir(syntax_highlighting_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-syntax-highlighting")
  else
    puts "Installing zsh-syntax-highlighting...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git #{syntax_highlighting_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-syntax-highlighting", success)
  end
  
  true
end

def install_tmux_plugin_manager
  print_header("Installing tmux Plugin Manager")
  
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  
  if Dir.exist?(tpm_dir)
    puts "tmux plugin manager is already installed, updating...".yellow
    Dir.chdir(tpm_dir) do
      run_command('git pull')
    end
    check_result("Updated tmux plugin manager")
    return true
  end
  
  puts "Installing tmux plugin manager...".blue
  create_directory(File.join(CONFIG_DIRS[:tmux], 'plugins'))
  install_cmd = "git clone https://github.com/tmux-plugins/tpm #{tpm_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "tmux plugin manager installed successfully".green
    return true
  else
    puts "Failed to install tmux plugin manager".red
    puts "Please install tmux plugin manager manually".yellow
    return false
  end
end

def install_rectangle
  print_header("Installing Rectangle Window Manager")
  
  if File.directory?('/Applications/Rectangle.app')
    puts "Rectangle is already installed".green
    return true
  end
  
  puts "Installing Rectangle...".blue
  output, success = run_command('brew install --cask rectangle')
  
  if success
    puts "Rectangle installed successfully".green
    return true
  else
    puts "Failed to install Rectangle".red
    puts "Please install Rectangle manually with: brew install --cask rectangle".yellow
    return false
  end
end

def create_zshrc(file)
  content = <<~ZSH
    # ZSH Configuration created by terminal-installer script

    # Enable Powerlevel10k instant prompt
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    # Path to Oh My Zsh installation
    export ZSH="$HOME/.oh-my-zsh"

    # Theme
    ZSH_THEME="powerlevel10k/powerlevel10k"

    # Plugins
    plugins=(
      git
      ruby
      python
      node
      macos
      tmux
      zsh-autosuggestions
      zsh-syntax-highlighting
    )

    source $ZSH/oh-my-zsh.sh

    # ============ Aliases ============
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
    alias notes="tmux attach -t notes || tmux new -s notes"

    # ============ Functions ============
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

    # ============ Zsh-specific settings ============
    setopt AUTO_PUSHD        # Push directories onto the directory stack
    setopt PUSHD_IGNORE_DUPS # Do not push duplicates
    setopt PUSHD_SILENT      # Do not print the directory stack after pushd/popd
    setopt EXTENDED_GLOB     # Use extended globbing
    setopt AUTO_CD           # Type directory name to cd

    # fzf configuration
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git || find . -type f -not -path '*/\.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

    # Add ~/bin to PATH
    export PATH="$HOME/bin:$PATH"

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  ZSH
  
  create_file(file, content)
end

def create_tmux_conf(file)
  content = <<~TMUX
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
    bind r source-file ~/.tmux.conf \\; display "Config reloaded!"

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

    # List of plugins
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'tmux-plugins/tmux-resurrect'
    set -g @plugin 'tmux-plugins/tmux-continuum'
    set -g @plugin 'tmux-plugins/tmux-yank'

    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    run '~/.tmux/plugins/tpm/tpm'
  TMUX
  
  create_file(file, content)
end

def create_p10k_conf(file)
  content = <<~P10K
    # Generated by terminal-installer
    # Config file for Powerlevel10k with minimal settings.
    # Wizard for this theme can be run by `p10k configure`.

    # Temporarily change options.
    'builtin' 'local' '-a' 'p10k_config_opts'
    [[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
    [[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
    [[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
    'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

    () {
      emulate -L zsh -o extended_glob

      # Unset all configuration options.
      unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

      # Zsh >= 5.1.1 is required.
      [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

      # Left prompt segments.
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        dir                       # current directory
        vcs                       # git status
        prompt_char               # prompt symbol
      )

      # Right prompt segments.
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status                    # exit code of the last command
        command_execution_time    # duration of the last command
        background_jobs           # presence of background jobs
        virtualenv                # python virtual environment
        time                      # current time
      )

      # Basic style options
      typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
      typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''
      
      # Install gitstatus plugin
      source ${0:A:h}/gitstatus/gitstatus.plugin.zsh || source /usr/local/opt/powerlevel10k/gitstatus/gitstatus.plugin.zsh || return
    }

    (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
    'builtin' 'unset' 'p10k_config_opts'
  P10K
  
  create_file(file, content)
end

def create_nvim_init(file)
  content = <<~INIT
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
  INIT
  
  create_file(file, content)
end

def create_nvim_plugins(file)
  content = <<~PLUGINS
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
        end,
      },
      
      -- Treesitter
      {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
          require('nvim-treesitter.configs').setup {
            ensure_installed = { "lua", "ruby", "python", "javascript", "typescript", "markdown" },
            highlight = {
              enable = true,
            },
          }
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
      
      -- Auto-completion
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
          
          cmp.setup {
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
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              