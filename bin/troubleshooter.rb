#!/usr/bin/env ruby
# Terminal Environment Troubleshooter & Updater
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
CONFIG_DIRS = {
  nvim: File.join(HOME_DIR, '.config/nvim'),
  bin: File.join(HOME_DIR, 'bin'),
  notes: File.join(HOME_DIR, 'notes'),
  tmux: File.join(HOME_DIR, '.tmux')
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

REQUIRED_TOOLS = %w[zsh nvim tmux git watchman fzf]

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
    append_to_file(file, "\n# Added by troubleshooter script\nalias #{alias_name}='#{command}'")
    puts "Added alias #{alias_name} to #{file}".green
    return true
  end
  
  puts "Alias #{alias_name} already exists in #{file}".green
  true
end

def check_and_add_function(file, func_name, function_code)
  pattern = "function\\s+#{func_name}\\s*\\(|#{func_name}\\s*\\(\\s*\\)"
  
  if !file_contains?(file, pattern)
    append_to_file(file, "\n# Added by troubleshooter script\n#{function_code}")
    puts "Added function #{func_name} to #{file}".green
    return true
  end
  
  puts "Function #{func_name} already exists in #{file}".green
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

# Main checks and fixes
def check_tools
  print_header("Checking Required Tools")
  
  success = true
  REQUIRED_TOOLS.each do |tool|
    if command_exists?(tool)
      version, success = run_command("#{tool} --version")
      version = version.lines.first.strip if success
      puts "✓ #{tool} is installed: #{version}".green
    else
      puts "✗ #{tool} is not installed".red
      puts "  Install with: brew install #{tool}".yellow
      success = false
    end
  end
  
  success
end

def check_directories
  print_header("Checking Required Directories")
  
  success = true
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      puts "✓ #{name} directory exists: #{dir}".green
    else
      puts "✗ #{name} directory doesn't exist: #{dir}".red
      success = false
      
      # Create missing directory in fix mode
      if @fix_mode
        create_directory(dir)
      end
    end
  end
  
  if @fix_mode
    TEMPLATE_DIRS.each do |name, dir|
      create_directory(dir) unless Dir.exist?(dir)
    end
  end
  
  success
end

def check_config_files
  print_header("Checking Configuration Files")
  
  success = true
  CONFIG_FILES.each do |name, file|
    if File.exist?(file)
      puts "✓ #{name} exists: #{file}".green
    else
      puts "✗ #{name} doesn't exist: #{file}".red
      success = false
      
      # Create missing file in fix mode
      if @fix_mode
        create_missing_config_file(name, file)
      end
    end
  end
  
  success
end

def create_missing_config_file(name, file)
  case name
  when :zshrc
    create_zshrc(file)
  when :tmux_conf
    create_tmux_conf(file)
  when :p10k
    create_p10k_conf(file)
  when :nvim_init
    create_nvim_init(file)
  when :nvim_plugins
    create_nvim_plugins(file)
  when :notes_vim
    create_notes_vim(file)
  end
end

def check_aliases
  print_header("Checking Aliases")
  
  aliases = {
    'v' => 'nvim',
    'vi' => 'nvim',
    'vim' => 'nvim',
    'gs' => 'git status',
    'ga' => 'git add',
    'gc' => 'git commit -m',
    'gp' => 'git push',
    'gl' => 'git pull',
    'ta' => 'tmux attach -t',
    'tls' => 'tmux list-sessions',
    'tn' => 'tmux new -s',
    'tk' => 'tmux kill-session -t',
    'dev' => 'tmux attach -t dev || tmux new -s dev',
    'notes' => 'tmux attach -t notes || tmux new -s notes'
  }
  
  success = true
  zshrc = CONFIG_FILES[:zshrc]
  
  if File.exist?(zshrc)
    aliases.each do |alias_name, command|
      if file_contains?(zshrc, "alias\\s+#{alias_name}\\s*=")
        puts "✓ Alias #{alias_name} exists".green
      else
        puts "✗ Alias #{alias_name} doesn't exist".red
        success = false
        
        # Add missing alias in fix mode
        if @fix_mode
          check_and_add_alias(zshrc, alias_name, command)
        end
      end
    end
  else
    puts "✗ .zshrc doesn't exist, can't check aliases".red
    success = false
  end
  
  success
end

def check_functions
  print_header("Checking Functions")
  
  functions = %w[mcd nvimf wk check-functions]
  
  success = true
  zshrc = CONFIG_FILES[:zshrc]
  
  if File.exist?(zshrc)
    functions.each do |func|
      if file_contains?(zshrc, "function\\s+#{func}\\s*\\(|#{func}\\s*\\(\\s*\\)")
        puts "✓ Function #{func} exists".green
      else
        puts "✗ Function #{func} doesn't exist".red
        success = false
        
        # Add missing function in fix mode
        if @fix_mode
          add_missing_function(zshrc, func)
        end
      end
    end
  else
    puts "✗ .zshrc doesn't exist, can't check functions".red
    success = false
  end
  
  success
end

def add_missing_function(zshrc, function_name)
  case function_name
  when 'mcd'
    function_code = <<~FUNC
      # Create and change to directory in one command
      mcd() {
        mkdir -p "$1" && cd "$1"
      }
    FUNC
    check_and_add_function(zshrc, 'mcd', function_code)
  when 'nvimf'
    function_code = <<~FUNC
      # Find and open file with Neovim
      nvimf() {
        local file
        file=$(find . -name "*$1*" | fzf)
        if [[ -n "$file" ]]; then
          nvim "$file"
        fi
      }
    FUNC
    check_and_add_function(zshrc, 'nvimf', function_code)
  when 'wk'
    function_code = <<~FUNC
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
    FUNC
    check_and_add_function(zshrc, 'wk', function_code)
  when 'check-functions'
    function_code = <<~FUNC
      # Check if functions are properly loaded
      check-functions() {
        echo "Testing key functions..."
        declare -f mcd > /dev/null && echo "✓ mcd (make directory and cd) function is available" || echo "✗ mcd function is not available"
        declare -f nvimf > /dev/null && echo "✓ nvimf (find and edit with neovim) function is available" || echo "✗ nvimf function is not available"
        declare -f wk > /dev/null && echo "✓ wk (session manager) function is available" || echo "✗ wk function is not available"
      }
    FUNC
    check_and_add_function(zshrc, 'check-functions', function_code)
  end
end

def check_note_templates
  print_header("Checking Note Templates")
  
  templates = {
    daily: File.join(TEMPLATE_DIRS[:notes_templates], 'daily.md'),
    project: File.join(TEMPLATE_DIRS[:notes_templates], 'project.md'),
    learning: File.join(TEMPLATE_DIRS[:notes_templates], 'learning.md')
  }
  
  success = true
  templates.each do |name, file|
    if File.exist?(file)
      puts "✓ #{name} template exists: #{file}".green
    else
      puts "✗ #{name} template doesn't exist: #{file}".red
      success = false
      
      # Create missing template in fix mode
      if @fix_mode
        create_template(name, file)
      end
    end
  end
  
  success
end

def create_template(name, file)
  template_content = case name
    when :daily
      <<~TEMPLATE
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
      TEMPLATE
    when :project
      <<~TEMPLATE
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
      TEMPLATE
    when :learning
      <<~TEMPLATE
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
      TEMPLATE
    end
  
  create_file(file, template_content)
end

def check_tmux_plugins
  print_header("Checking tmux Plugins")
  
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  
  if Dir.exist?(tpm_dir)
    puts "✓ tmux plugin manager (tpm) exists".green
    success = true
  else
    puts "✗ tmux plugin manager (tpm) doesn't exist".red
    success = false
    
    # Install tpm in fix mode
    if @fix_mode
      puts "Installing tmux plugin manager...".blue
      cmd = "git clone https://github.com/tmux-plugins/tpm #{tpm_dir}"
      output, success = run_command(cmd)
      if success
        puts "✓ Installed tmux plugin manager".green
      else
        puts "✗ Failed to install tmux plugin manager".red
      end
    end
  end
  
  # Check if tmux.conf has proper pipe split keybinding
  tmux_conf = CONFIG_FILES[:tmux_conf]
  if File.exist?(tmux_conf)
    if file_contains?(tmux_conf, "bind.*\\|.*split-window.*-h")
      puts "✓ tmux.conf has proper pipe split keybinding".green
    else
      puts "✗ tmux.conf missing pipe split keybinding".red
      
      # Fix keybinding in fix mode
      if @fix_mode
        add_line_if_not_exists(tmux_conf, "bind | split-window -h")
        add_line_if_not_exists(tmux_conf, "bind - split-window -v")
      end
    end
  end
  
  success
end

def check_powerlevel10k
  print_header("Checking Powerlevel10k")
  
  p10k_theme_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/themes/powerlevel10k')
  p10k_conf = CONFIG_FILES[:p10k]
  
  # Check if p10k theme is installed
  if Dir.exist?(p10k_theme_dir)
    puts "✓ Powerlevel10k theme is installed".green
    theme_success = true
  else
    puts "✗ Powerlevel10k theme is not installed".red
    theme_success = false
    
    # Install p10k theme in fix mode
    if @fix_mode
      puts "Installing Powerlevel10k theme...".blue
      cmd = "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git #{p10k_theme_dir}"
      output, success = run_command(cmd)
      if success
        puts "✓ Installed Powerlevel10k theme".green
      else
        puts "✗ Failed to install Powerlevel10k theme".red
      end
    end
  end
  
  # Check if .zshrc has p10k theme set
  zshrc = CONFIG_FILES[:zshrc]
  if File.exist?(zshrc)
    if file_contains?(zshrc, "ZSH_THEME=[\"']powerlevel10k\\/powerlevel10k[\"']")
      puts "✓ Powerlevel10k theme is set in .zshrc".green
      zshrc_success = true
    else
      puts "✗ Powerlevel10k theme is not set in .zshrc".red
      zshrc_success = false
      
      # Set p10k theme in fix mode
      if @fix_mode
        if file_contains?(zshrc, "ZSH_THEME=")
          # Replace existing ZSH_THEME line
          zshrc_content = File.read(zshrc)
          zshrc_content.gsub!(/ZSH_THEME=.*$/, 'ZSH_THEME="powerlevel10k/powerlevel10k"')
          File.write(zshrc, zshrc_content)
          puts "✓ Updated ZSH_THEME to powerlevel10k in .zshrc".green
        else
          # Add ZSH_THEME line
          add_line_if_not_exists(zshrc, 'ZSH_THEME="powerlevel10k/powerlevel10k"')
        end
      end
    end
  else
    puts "✗ .zshrc doesn't exist, can't check Powerlevel10k theme setting".red
    zshrc_success = false
  end
  
  # Check if .p10k.zsh exists
  if File.exist?(p10k_conf)
    puts "✓ .p10k.zsh configuration exists".green
    p10k_success = true
  else
    puts "✗ .p10k.zsh configuration doesn't exist".red
    p10k_success = false
    
    # Create minimal p10k config in fix mode
    if @fix_mode
      create_p10k_conf(p10k_conf)
    end
  end
  
  # Check if .zshrc sources .p10k.zsh
  if File.exist?(zshrc)
    if file_contains?(zshrc, "source.*\\.p10k\\.zsh")
      puts "✓ .zshrc sources .p10k.zsh".green
      source_success = true
    else
      puts "✗ .zshrc doesn't source .p10k.zsh".red
      source_success = false
      
      # Add source line in fix mode
      if @fix_mode
        add_line_if_not_exists(zshrc, '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh')
      end
    end
  else
    puts "✗ .zshrc doesn't exist, can't check for p10k source line".red
    source_success = false
  end
  
  theme_success && zshrc_success && p10k_success && source_success
end

def create_zshrc(file)
  content = <<~ZSH
    # ZSH Configuration created by terminal-troubleshooter script

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
    # Generated by terminal-troubleshooter
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