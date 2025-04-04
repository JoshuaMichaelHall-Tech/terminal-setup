#!/usr/bin/env ruby
# tmux Configuration Installer
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

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
CONFIG_DIRS = {
  tmux: File.join(HOME_DIR, '.tmux')
}
CONFIG_FILES = {
  tmux_conf: File.join(HOME_DIR, '.tmux.conf')
}
VERSION = '0.2.1'

# Parse options at the top level so it's available throughout the script
OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: fix-all-scripts.rb [options]"
  
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


# Options parsing
options = { minimal: false, fix: false }

OptionParser.new do |opts|
  opts.banner = "Usage: tmux_installer.rb [options]"
  
  opts.on("--minimal", "Minimal installation (config only)") do
    OPTIONS[:$1] = true
  end
  
  opts.on("--fix", "Fix mode (only fix existing installation)") do
    OPTIONS[:$1] = true
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
  backup_dir = File.join(HOME_DIR, "tmux_env_backup_#{timestamp}")
  
  begin
    FileUtils.mkdir_p(backup_dir)
    puts "Created backup directory: #{backup_dir}".green
    return backup_dir
  rescue StandardError => e
    puts "Error creating backup directory #{backup_dir}: #{e.message}".red
    return backup_dir # Still return the intended path even if creation failed
  end
end


def backup_tmux_configs(backup_dir)
  print_header("Backing Up Existing tmux Configuration")
  
  # Backup tmux config file
  if File.exist?(CONFIG_FILES[:tmux_conf])
    tmux_backup = File.join(backup_dir, 'tmux.conf')
    FileUtils.cp(CONFIG_FILES[:tmux_conf], tmux_backup)
    puts "Backed up .tmux.conf to #{tmux_backup}".green
  end
  
  # Backup tmux plugin directory
  if Dir.exist?(CONFIG_DIRS[:tmux])
    tmux_dir_backup = File.join(backup_dir, 'tmux')
    FileUtils.cp_r(CONFIG_DIRS[:tmux], tmux_dir_backup)
    puts "Backed up .tmux directory to #{tmux_dir_backup}".green
  end
  
  puts "All existing tmux configurations backed up to #{backup_dir}".green
end

# Installation functions
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

def check_tmux_setup
  print_header("Checking tmux Setup")
  
  # Check if tmux is installed
  if command_exists?('tmux')
    version, _ = run_command('tmux -V')
    puts "tmux is installed: #{version.strip}".green
  else
    puts "tmux is not installed".red
    puts "Please install tmux before continuing".yellow
    return false
  end
  
  # Check required directories
  success = true
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      puts "#{name} directory exists: #{dir}".green
    else
      puts "#{name} directory doesn't exist: #{dir}".yellow
      success = false
    end
  end
  
  # Check for required config files
  CONFIG_FILES.each do |name, file|
    if File.exist?(file)
      puts "#{name} configuration exists: #{file}".green
    else
      puts "#{name} configuration doesn't exist: #{file}".yellow
      success = false
    end
  end
  
  # Check for tmux plugin manager
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  if Dir.exist?(tpm_dir)
    puts "tmux plugin manager is installed".green
  else
    puts "tmux plugin manager is not installed".yellow
    success = false
  end
  
  success
end

def check_tmux_conf_settings
  print_header("Checking tmux Configuration Settings")
  
  tmux_conf = CONFIG_FILES[:tmux_conf]
  if !File.exist?(tmux_conf)
    puts "tmux configuration file doesn't exist".red
    return false
  end
  
  # Check for important settings
  required_settings = {
    "prefix C-a" => "set-option -g prefix C-a",
    "split panes" => "bind \\| split-window -h",
    "mouse" => "set -g mouse on",
    "vi mode" => "setw -g mode-keys vi",
    "plugins" => "@plugin 'tmux-plugins/tpm'"
  }
  
  missing_settings = []
  conf_content = File.read(tmux_conf)
  
  required_settings.each do |name, pattern|
    if conf_content.include?(pattern)
      puts "✓ tmux.conf has #{name} setting".green
    else
      puts "✗ tmux.conf missing #{name} setting".red
      missing_settings << name
    end
  end
  
  if missing_settings.empty?
    return true
  else
    if OPTIONS[:$1]
      puts "Fixing tmux.conf...".blue
      backup_file(tmux_conf)
      create_tmux_conf(tmux_conf)
      puts "✓ Created new tmux.conf with all required settings".green
    else
      puts "Run with --fix to update tmux.conf with required settings".yellow
    end
    return false
  end
end

# Main installation functions
def run_full_install
  print_header("Running Full tmux Installation")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_tmux_configs(backup_dir)
  
  # Create directories
  success = true
  CONFIG_DIRS.each do |name, dir|
    success &= create_directory(dir)
  end
  
  # Create configuration files
  success &= create_tmux_conf(CONFIG_FILES[:tmux_conf])
  
  # Install tmux plugin manager
  success &= install_tmux_plugin_manager
  
  # Set version marker
  version_file = File.join(HOME_DIR, '.tmux_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}")
  
  success
end

def run_minimal_update
  print_header("Running Minimal tmux Update")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_tmux_configs(backup_dir)
  
  # Check tmux setup
  success = check_tmux_setup
  
  # Check tmux.conf settings
  success &= check_tmux_conf_settings
  
  # Update version marker
  version_file = File.join(HOME_DIR, '.tmux_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}\nmode=minimal")
  
  success
end

def run_fix_mode
  print_header("Running Fix Mode for tmux Configuration")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_tmux_configs(backup_dir)
  
  # Create directories if they don't exist
  success = true
  CONFIG_DIRS.each do |name, dir|
    if !Dir.exist?(dir)
      success &= create_directory(dir)
    end
  end
  
  # Create or fix tmux.conf
  if !File.exist?(CONFIG_FILES[:tmux_conf]) || OPTIONS[:$1]
    success &= create_tmux_conf(CONFIG_FILES[:tmux_conf])
  end
  
  # Install or update tmux plugin manager
  success &= install_tmux_plugin_manager
  
  success
end

# Main entry point
def main
  print_header("tmux Configuration Installer v#{VERSION}")
  
  if OPTIONS[:$1]
    success = run_fix_mode
  elsif OPTIONS[:$1]
    success = run_minimal_update
  else
    success = run_full_install
  end
  
  if success
    print_header("tmux Configuration Installation Completed Successfully")
    puts "Your tmux environment is now configured.".green
    puts "\nNext steps:".blue
    puts "1. Restart your terminal"
    puts "2. Start a new tmux session with 'tmux'"
    puts "3. Install tmux plugins by pressing Ctrl+a followed by I (capital i)"
  else
    print_header("Installation Completed with Errors")
    puts "Some components may not have installed correctly.".red
    puts "Please check the error messages above.".yellow
  end
  
  return success ? 0 : 1
end

# Run the script
exit main