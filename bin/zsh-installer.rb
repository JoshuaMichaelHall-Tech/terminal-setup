#!/usr/bin/env ruby
# Zsh Configuration Installer
# Author: Joshua Michael Hall
# License: MIT
# Date: April 5, 2025

require 'fileutils'
require 'open3'
require 'date'
require 'optparse'

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
CONFIG_FILES = {
  zshrc: File.join(HOME_DIR, '.zshrc'),
  p10k: File.join(HOME_DIR, '.p10k.zsh')
}
OH_MY_ZSH_DIR = File.join(HOME_DIR, '.oh-my-zsh')
P10K_THEME_DIR = File.join(OH_MY_ZSH_DIR, 'custom/themes/powerlevel10k')
ZSH_PLUGINS_DIR = File.join(OH_MY_ZSH_DIR, 'custom/plugins')
VERSION = '0.2.2'

# Parse options at the top level so it's available throughout the script
OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: zsh-installer.rb [options]"
  
  opts.on("--minimal", "Minimal installation (config only)") do
    OPTIONS[:minimal] = true
  end
  
  opts.on("--fix", "Fix mode (only fix existing installation)") do
    OPTIONS[:fix] = true
  end
  
  opts.on("--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!

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
  
  begin
    FileUtils.mkdir_p(dir)
    puts "✓ Created directory: #{dir}".green
    return true
  rescue StandardError => e
    puts "✗ Error creating directory #{dir}: #{e.message}".red
    return false
  end
end


def create_file(file, content)
  create_directory(File.dirname(file))
  
  begin
    File.write(file, content)
    puts "✓ Created file: #{file}".green
    return true
  rescue StandardError => e
    puts "✗ Error creating file #{file}: #{e.message}".red
    return false
  end
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
  backup_dir = File.join(HOME_DIR, "zsh_env_backup_#{timestamp}")
  
  begin
    FileUtils.mkdir_p(backup_dir)
    puts "Created backup directory: #{backup_dir}".green
    return backup_dir
  rescue StandardError => e
    puts "Error creating backup directory #{backup_dir}: #{e.message}".red
    return backup_dir # Still return the intended path even if creation failed
  end
end


def backup_zsh_configs(backup_dir)
  print_header("Backing Up Existing Zsh Configuration")
  
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
  
  puts "All existing Zsh configurations backed up to #{backup_dir}".green
end

# Installation functions
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

def create_zshrc(file)
  content = <<~'ZSH'
    # ZSH Configuration created by zsh-installer.rb

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
, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh ZSH="$HOME/.oh-my-zsh"

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
    export