#!/usr/bin/env ruby
# tmux Configuration Troubleshooter
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'
require 'open3'
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
TPM_DIR = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
VERSION = '0.2.1'

# Parse options at the top level so it's available throughout the script
OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: fix-all-scripts.rb [options]"
  
  opts.on("--fix", "Fix issues automatically") do
    OPTIONS[:fix] = true
  end
  
  opts.on("--verbose", "Show detailed information") do
    OPTIONS[:verbose] = true
  end
  
  opts.on("--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!


# Options parsing
options = { fix: false, verbose: false }

OptionParser.new do |opts|
  opts.banner = "Usage: tmux_troubleshooter.rb [options]"
  
  opts.on("--fix", "Fix issues automatically") do
    OPTIONS[:$1] = true
  end
  
  opts.on("--verbose", "Show detailed information") do
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

def run_command(command)
  stdout, stderr, status = Open3.capture3(command)
  success = status.success?
  
  return [stdout, success]
rescue StandardError => e
  puts "Error running command '#{command}': #{e.message}".red
  return ["", false]
end

def create_backup(file)
  return true unless File.exist?(file)
  
  backup = "#{file}.bak.#{Time.now.strftime('%Y%m%d%H%M%S')}"
  FileUtils.cp(file, backup)
  puts "Created backup: #{backup}".green
  true
rescue StandardError => e
  puts "Failed to create backup for #{file}: #{e.message}".red
  false
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

# Troubleshooting functions
def check_tmux_installation
  print_header("Checking tmux Installation")
  
  # Check if tmux is installed
  if command_exists?('tmux')
    version, success = run_command('tmux -V')
    if success
      puts "✓ tmux is installed: #{version.strip}".green
    else
      puts "✗ tmux seems to be installed but version check failed".red
      return false
    end
  else
    puts "✗ tmux is not installed".red
    if OPTIONS[:$1]
      puts "Attempting to install tmux...".blue
      if command_exists?('brew')
        output, success = run_command('brew install tmux')
        if success && command_exists?('tmux')
          puts "✓ tmux installed successfully".green
        else
          puts "✗ Failed to install tmux".red
          puts "  Please install tmux manually with: brew install tmux".yellow
          return false
        end
      else
        puts "✗ Cannot automatically install tmux (Homebrew not found)".red
        puts "  Please install tmux manually and run this script again".yellow
        return false
      end
    else
      puts "  Run with --fix to attempt installation, or install manually".yellow
      return false
    end
  end
  
  true
end

def check_tmux_directories
  print_header("Checking tmux Directories")
  
  all_dirs_ok = true
  
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      puts "✓ #{name} directory exists: #{dir}".green
    else
      puts "✗ #{name} directory doesn't exist: #{dir}".red
      all_dirs_ok = false
      
      if OPTIONS[:$1]
        puts "Creating #{name} directory...".blue
        if create_directory(dir)
          puts "✓ Created #{name} directory".green
        else
          puts "✗ Failed to create #{name} directory".red
        end
      end
    end
  end
  
  # Check TPM directory specifically
  if Dir.exist?(TPM_DIR)
    puts "✓ tmux Plugin Manager directory exists: #{TPM_DIR}".green
  else
    puts "✗ tmux Plugin Manager directory doesn't exist: #{TPM_DIR}".red
    all_dirs_ok = false
    
    if OPTIONS[:$1]
      puts "Attempting to install tmux Plugin Manager...".blue
      tpm_parent_dir = File.dirname(TPM_DIR)
      create_directory(tpm_parent_dir)
      
      install_cmd = "git clone https://github.com/tmux-plugins/tpm #{TPM_DIR}"
      output, success = run_command(install_cmd)
      
      if success && Dir.exist?(TPM_DIR)
        puts "✓ tmux Plugin Manager installed successfully".green
      else
        puts "✗ Failed to install tmux Plugin Manager".red
        puts "  Please install tmux Plugin Manager manually with:".yellow
        puts "  #{install_cmd}".yellow
      end
    end
  end
  
  if !all_dirs_ok && !OPTIONS[:$1]
    puts "Run with --fix to create missing directories".yellow
  end
  
  all_dirs_ok
end

def check_tmux_configuration
  print_header("Checking tmux Configuration")
  
  tmux_conf = CONFIG_FILES[:tmux_conf]
  if File.exist?(tmux_conf)
    puts "✓ tmux configuration file exists: #{tmux_conf}".green
    
    # Check for key settings
    tmux_conf_content = File.read(tmux_conf)
    required_settings = {
      "Prefix Key (C-a)" => "set-option -g prefix C-a",
      "Split Vertically (|)" => "bind \\| split-window -h",
      "Split Horizontally (-)" => "bind - split-window -v",
      "Mouse Support" => "set -g mouse on",
      "Vi Mode" => "setw -g mode-keys vi",
      "TPM Plugins" => "@plugin 'tmux-plugins/tpm'"
    }
    
    missing_settings = []
    required_settings.each do |name, pattern|
      if tmux_conf_content.include?(pattern)
        puts "  ✓ #{name} setting is configured".green
      else
        puts "  ✗ #{name} setting is missing".red
        missing_settings << name
      end
    end
    
    # If any key settings are missing and fix mode is enabled, create a new config
    if !missing_settings.empty? && OPTIONS[:$1]
      puts "Missing essential tmux settings, creating new configuration...".blue
      create_backup(tmux_conf)
      create_tmux_conf(tmux_conf)
      puts "✓ Created new tmux configuration with all required settings".green
      return true
    elsif !missing_settings.empty?
      puts "Run with --fix to update tmux configuration with all required settings".yellow
      return false
    end
    
    return true
  else
    puts "✗ tmux configuration file doesn't exist: #{tmux_conf}".red
    
    if OPTIONS[:$1]
      puts "Creating tmux configuration file...".blue
      create_tmux_conf(tmux_conf)
      return true
    else
      puts "Run with --fix to create tmux configuration file".yellow
      return false
    end
  end
end

def check_tmux_plugin_manager
  print_header("Checking tmux Plugin Manager")
  
  if Dir.exist?(TPM_DIR)
    # Check if TPM is properly initialized
    tpm_init_file = File.join(TPM_DIR, 'tpm')
    if File.exist?(tpm_init_file) && File.executable?(tpm_init_file)
      puts "✓ tmux Plugin Manager is properly installed".green
      return true
    else
      puts "✗ tmux Plugin Manager installation appears to be incomplete".red
      
      if OPTIONS[:$1]
        puts "Attempting to fix tmux Plugin Manager installation...".blue
        
        # Remove corrupt installation and reinstall
        FileUtils.rm_rf(TPM_DIR)
        install_cmd = "git clone https://github.com/tmux-plugins/tpm #{TPM_DIR}"
        output, success = run_command(install_cmd)
        
        if success && Dir.exist?(TPM_DIR)
          puts "✓ tmux Plugin Manager reinstalled successfully".green
          return true
        else
          puts "✗ Failed to reinstall tmux Plugin Manager".red
          puts "  Please install tmux Plugin Manager manually with:".yellow
          puts "  #{install_cmd}".yellow
          return false
        end
      else
        puts "Run with --fix to reinstall tmux Plugin Manager".yellow
        return false
      end
    end
  else
    puts "✗ tmux Plugin Manager is not installed".red
    
    if OPTIONS[:$1]
      puts "Attempting to install tmux Plugin Manager...".blue
      tpm_parent_dir = File.dirname(TPM_DIR)
      create_directory(tpm_parent_dir)
      
      install_cmd = "git clone https://github.com/tmux-plugins/tpm #{TPM_DIR}"
      output, success = run_command(install_cmd)
      
      if success && Dir.exist?(TPM_DIR)
        puts "✓ tmux Plugin Manager installed successfully".green
        return true
      else
        puts "✗ Failed to install tmux Plugin Manager".red
        puts "  Please install tmux Plugin Manager manually with:".yellow
        puts "  #{install_cmd}".yellow
        return false
      end
    else
      puts "Run with --fix to install tmux Plugin Manager".yellow
      return false
    end
  end
end

def check_tmux_plugins
  print_header("Checking tmux Plugins")
  
  # Essential plugins to check
  essential_plugins = [
    'tmux-plugins/tpm',
    'tmux-plugins/tmux-sensible',
    'tmux-plugins/tmux-resurrect',
    'tmux-plugins/tmux-continuum',
    'tmux-plugins/tmux-yank'
  ]
  
  tmux_conf = CONFIG_FILES[:tmux_conf]
  if !File.exist?(tmux_conf)
    puts "✗ tmux configuration file doesn't exist, cannot check plugins".red
    return false
  end
  
  # Check if plugins are configured in tmux.conf
  tmux_conf_content = File.read(tmux_conf)
  missing_plugins = []
  
  essential_plugins.each do |plugin|
    if tmux_conf_content.include?("@plugin '#{plugin}'")
      puts "✓ Plugin configured: #{plugin}".green
    else
      puts "✗ Plugin not configured: #{plugin}".red
      missing_plugins << plugin
    end
  end
  
  # If any plugins are missing and fix mode is enabled, update config
  if !missing_plugins.empty? && OPTIONS[:$1]
    puts "Adding missing plugin configurations to tmux.conf...".blue
    
    # Create backup
    create_backup(tmux_conf)
    
    # Check if plugins section exists
    if tmux_conf_content.include?("# List of plugins")
      # Add missing plugins to existing section
      new_content = tmux_conf_content.dup
      missing_plugins.each do |plugin|
        if new_content.include?("# Initialize TMUX plugin manager")
          # Add before TPM initialization
          insert_pos = new_content.index("# Initialize TMUX plugin manager")
          new_content.insert(insert_pos, "set -g @plugin '#{plugin}'\n")
        else
          # Append at the end
          new_content << "set -g @plugin '#{plugin}'\n"
        end
      end
      
      # Write updated content
      File.write(tmux_conf, new_content)
      puts "✓ Added missing plugin configurations to tmux.conf".green
    else
      # Create new config with all required plugins
      create_tmux_conf(tmux_conf)
      puts "✓ Created new tmux configuration with all required plugins".green
    end
    
    return true
  elsif !missing_plugins.empty?
    puts "Run with --fix to update tmux configuration with missing plugins".yellow
    return false
  end
  
  true
end

# Main function
def main
  print_header("tmux Configuration Troubleshooter v#{VERSION}")
  
  # Collect issues
  issues = []
  
  # Check tmux installation
  puts "Checking tmux installation...".blue
  tmux_ok = check_tmux_installation
  issues << "tmux installation" unless tmux_ok
  
  # Check tmux directories
  puts "Checking tmux directories...".blue
  dirs_ok = check_tmux_directories
  issues << "tmux directories" unless dirs_ok
  
  # Check tmux configuration
  puts "Checking tmux configuration...".blue
  conf_ok = check_tmux_configuration
  issues << "tmux configuration" unless conf_ok
  
  # Check tmux plugin manager
  puts "Checking tmux plugin manager...".blue
  tpm_ok = check_tmux_plugin_manager
  issues << "tmux plugin manager" unless tpm_ok
  
  # Check tmux plugins
  puts "Checking tmux plugins...".blue
  plugins_ok = check_tmux_plugins
  issues << "tmux plugins" unless plugins_ok
  
  # Final report
  print_header("Troubleshooting Summary")
  
  if issues.empty?
    puts "✓ All tmux components are installed and configured correctly".green
  else
    puts "✗ Issues found in the following areas:".red
    issues.each_with_index do |issue, index|
      puts "  #{index + 1}. #{issue}".yellow
    end
    
    if OPTIONS[:$1]
      puts "\nAttempted to fix all issues. Please check the output above for any remaining problems.".blue
      puts "You may need to restart your terminal and reinstall tmux plugins:".blue
      puts "  1. Start a new tmux session with 'tmux'"
      puts "  2. Press Ctrl+a, then I (capital i) to install plugins"
    else
      puts "\nRun this script with --fix option to attempt automatic fixes for these issues.".blue
    end
  end
  
  # Return success if no issues or all issues fixed
  issues.empty?
end

# Run the script
exit main ? 0 : 1