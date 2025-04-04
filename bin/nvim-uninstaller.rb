#!/usr/bin/env ruby
# Neovim Configuration Uninstaller
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'
require 'optparse'
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
  nvim_data: File.join(HOME_DIR, '.local/share/nvim'),
  undodir: File.join(HOME_DIR, '.vim/undodir')
}
VERSION = '0.2.1'

# Parse options at the top level so it's available throughout the script
OPTIONS = { full: false, keep_data: true, force: false }
OptionParser.new do |opts|
  opts.banner = "Usage: fix-all-scripts.rb [options]"
  
  opts.on("--full", "Full uninstallation (remove all configurations and data)") do
    OPTIONS[:full] = true
  end
  
  opts.on("--no-keep-data", "Do not keep user data") do
    OPTIONS[:keep_data] = false
  end
  
  opts.on("--force", "Force uninstallation without confirmation") do
    OPTIONS[:force] = true
  end
  
  opts.on("--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!


# Options parsing
options = { 
  full: false,           # Remove all Neovim config and data
  keep_plugins: true,    # Don't remove installed plugins
  keep_data: true,       # Don't remove user data (undo history, etc.)
  force: false           # Don't ask for confirmation
}

OptionParser.new do |opts|
  opts.banner = "Usage: nvim_uninstaller.rb [options]"
  
  opts.on("--full", "Full uninstallation (remove all configurations and data)") do
    OPTIONS[:$1] = true
  end
  
  opts.on("--no-keep-plugins", "Remove all plugins") do
    OPTIONS[:$1] = false
  end
  
  opts.on("--no-keep-data", "Remove all user data") do
    OPTIONS[:$1] = false
  end
  
  opts.on("--force", "Force uninstallation without confirmation") do
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

def check_result(message, result = $?.success?)
  if result
    puts "✓ #{message}".green
    return true
  else
    puts "✗ #{message}".red
    return false
  end
end

def create_backup_directory
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  backup_dir = File.join(HOME_DIR, "nvim_env_backup_#{timestamp}")
  
  begin
    FileUtils.mkdir_p(backup_dir)
    puts "Created backup directory: #{backup_dir}".green
    return backup_dir
  rescue StandardError => e
    puts "Error creating backup directory #{backup_dir}: #{e.message}".red
    return backup_dir # Still return the intended path even if creation failed
  end
end


def backup_nvim_configs(backup_dir)
  print_header("Backing Up Neovim Configurations")
  
  # Backup nvim config directory
  if Dir.exist?(CONFIG_DIRS[:nvim])
    nvim_backup = File.join(backup_dir, 'nvim')
    FileUtils.cp_r(CONFIG_DIRS[:nvim], nvim_backup)
    puts "Backed up Neovim config to #{nvim_backup}".green
  end
  
  # Backup nvim data directory (plugins, etc.) if requested
  if !OPTIONS[:$1] && Dir.exist?(CONFIG_DIRS[:nvim_data])
    nvim_data_backup = File.join(backup_dir, 'nvim_data')
    FileUtils.cp_r(CONFIG_DIRS[:nvim_data], nvim_data_backup)
    puts "Backed up Neovim data to #{nvim_data_backup}".green
  end
  
  # Backup undodir if requested
  if !OPTIONS[:$1] && Dir.exist?(CONFIG_DIRS[:undodir])
    undodir_backup = File.join(backup_dir, 'undodir')
    FileUtils.cp_r(CONFIG_DIRS[:undodir], undodir_backup)
    puts "Backed up undo history to #{undodir_backup}".green
  end
  
  puts "Neovim configurations backed up to #{backup_dir}".green
  backup_dir
end

def remove_nvim_config
  print_header("Removing Neovim Configuration")
  
  if Dir.exist?(CONFIG_DIRS[:nvim])
    begin
      FileUtils.rm_rf(CONFIG_DIRS[:nvim])
      puts "Removed Neovim configuration directory: #{CONFIG_DIRS[:nvim]}".green
      return true
    rescue => e
      puts "Failed to remove Neovim configuration directory: #{e.message}".red
      return false
    end
  else
    puts "Neovim configuration directory doesn't exist, nothing to remove".yellow
    return true
  end
end

def remove_nvim_plugins
  print_header("Removing Neovim Plugins")
  
  if OPTIONS[:$1]
    puts "Keeping plugins as requested".green
    return true
  end
  
  if Dir.exist?(CONFIG_DIRS[:nvim_data])
    begin
      FileUtils.rm_rf(CONFIG_DIRS[:nvim_data])
      puts "Removed Neovim data directory: #{CONFIG_DIRS[:nvim_data]}".green
      return true
    rescue => e
      puts "Failed to remove Neovim data directory: #{e.message}".red
      return false
    end
  else
    puts "Neovim data directory doesn't exist, nothing to remove".yellow
    return true
  end
end

def remove_nvim_undo_history
  print_header("Removing Neovim Undo History")
  
  if OPTIONS[:$1]
    puts "Keeping undo history as requested".green
    return true
  end
  
  if Dir.exist?(CONFIG_DIRS[:undodir])
    begin
      FileUtils.rm_rf(CONFIG_DIRS[:undodir])
      puts "Removed undo history directory: #{CONFIG_DIRS[:undodir]}".green
      return true
    rescue => e
      puts "Failed to remove undo history directory: #{e.message}".red
      return false
    end
  else
    puts "Undo history directory doesn't exist, nothing to remove".yellow
    return true
  end
end

# Main function
def main
  print_header("Neovim Configuration Uninstaller v#{VERSION}")
  
  puts "This script will remove Neovim customizations installed by the terminal-setup project.".yellow
  if OPTIONS[:$1]
    puts "Running in FULL uninstall mode.".red
    puts "This will remove ALL Neovim configuration and data.".red
  else
    puts "Running in selective uninstall mode.".yellow
    if OPTIONS[:$1]
      puts "Plugins will be preserved.".green
    else
      puts "Plugins will be removed.".red
    end
    
    if OPTIONS[:$1]
      puts "Undo history and other user data will be preserved.".green
    else
      puts "Undo history and other user data will be removed.".red
    end
  end
  
  unless OPTIONS[:$1]
    print "Are you sure you want to proceed? (y/n): "
    confirm = gets.chomp.downcase
    
    unless confirm == 'y' || confirm == 'yes'
      puts "Uninstall cancelled.".blue
      return 0
    end
  end
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_nvim_configs(backup_dir)
  
  success = true
  
  # Remove Neovim config
  success &= remove_nvim_config
  
  # Remove Neovim plugins if requested
  success &= remove_nvim_plugins
  
  # Remove Neovim undo history if requested
  success &= remove_nvim_undo_history
  
  # Remove version file
  version_file = File.join(HOME_DIR, '.nvim_version')
  if File.exist?(version_file)
    begin
      File.delete(version_file)
      puts "Removed version file: #{version_file}".green
    rescue => e
      puts "Failed to remove version file: #{e.message}".red
      success = false
    end
  end
  
  if success
    print_header("Uninstallation Completed Successfully")
    puts "Neovim configuration has been removed.".green
    puts "Your original configurations were backed up to: #{backup_dir}".green
    
    puts "\nNext steps:".blue
    if OPTIONS[:$1]
      puts "1. If you want to completely remove Neovim, you can run:"
      puts "   brew uninstall neovim"
    else
      puts "1. If you want to start fresh with a new Neovim configuration, you can:"
      puts "   - Run the Neovim installer script to reinstall the configuration"
      puts "   - Or initialize your own configuration"
    end
  else
    print_header("Uninstallation Completed with Errors")
    puts "Some components may not have been removed correctly.".red
    puts "Please check the error messages above.".yellow
    puts "Your original configurations were backed up to: #{backup_dir}".green
  end
  
  return success ? 0 : 1
end

# Run the script
exit main