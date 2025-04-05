#!/usr/bin/env ruby
# tmux Configuration Uninstaller
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
  tmux: File.join(HOME_DIR, '.tmux')
}
CONFIG_FILES = {
  tmux_conf: File.join(HOME_DIR, '.tmux.conf')
}
VERSION = '0.2.0'

# Options parsing
options = { keep_plugins: true, force: false }

OptionParser.new do |opts|
  opts.banner = "Usage: tmux_uninstaller.rb [options]"
  
  opts.on("--no-keep-plugins", "Remove all plugins, not just our configuration") do
    options[:keep_plugins] = false
  end
  
  opts.on("--force", "Force uninstallation without confirmation") do
    options[:force] = true
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
  backup_dir = File.join(HOME_DIR, "tmux_uninstall_backup_#{timestamp}")
  
  FileUtils.mkdir_p(backup_dir)
  puts "Created backup directory: #{backup_dir}".green
  
  backup_dir
end

def backup_tmux_configs(backup_dir)
  print_header("Backing Up tmux Configurations")
  
  # Backup tmux.conf
  if File.exist?(CONFIG_FILES[:tmux_conf])
    tmux_conf_backup = File.join(backup_dir, 'tmux.conf')
    FileUtils.cp(CONFIG_FILES[:tmux_conf], tmux_conf_backup)
    puts "Backed up .tmux.conf to #{tmux_conf_backup}".green
  end
  
  # Backup tmux directory
  if Dir.exist?(CONFIG_DIRS[:tmux])
    tmux_dir_backup = File.join(backup_dir, 'tmux')
    FileUtils.cp_r(CONFIG_DIRS[:tmux], tmux_dir_backup)
    puts "Backed up .tmux directory to #{tmux_dir_backup}".green
  end
  
  puts "tmux configurations backed up to #{backup_dir}".green
  backup_dir
end

def remove_tmux_conf
  print_header("Removing tmux Configuration File")
  
  if File.exist?(CONFIG_FILES[:tmux_conf])
    begin
      File.delete(CONFIG_FILES[:tmux_conf])
      puts "Removed tmux configuration file: #{CONFIG_FILES[:tmux_conf]}".green
      return true
    rescue => e
      puts "Failed to remove tmux configuration file: #{e.message}".red
      return false
    end
  else
    puts "tmux configuration file doesn't exist, nothing to remove".yellow
    return true
  end
end

def remove_tmux_plugins
  print_header("Removing tmux Plugin Manager")
  
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  
  if Dir.exist?(tpm_dir)
    begin
      FileUtils.rm_rf(tpm_dir)
      puts "Removed tmux Plugin Manager".green
      
      # If no other plugins are left and we're removing everything, remove plugins directory
      plugins_dir = File.join(CONFIG_DIRS[:tmux], 'plugins')
      if !options[:keep_plugins] && Dir.exist?(plugins_dir) && Dir.empty?(plugins_dir)
        FileUtils.rm_rf(plugins_dir)
        puts "Removed empty plugins directory".green
      end
      
      return true
    rescue => e
      puts "Failed to remove tmux Plugin Manager: #{e.message}".red
      return false
    end
  else
    puts "tmux Plugin Manager not found, nothing to remove".yellow
    return true
  end
end

def remove_tmux_directory
  print_header("Removing tmux Directory")
  
  if options[:keep_plugins]
    puts "Keeping user plugins as requested, not removing .tmux directory".green
    return true
  end
  
  if Dir.exist?(CONFIG_DIRS[:tmux])
    begin
      FileUtils.rm_rf(CONFIG_DIRS[:tmux])
      puts "Removed tmux directory: #{CONFIG_DIRS[:tmux]}".green
      return true
    rescue => e
      puts "Failed to remove tmux directory: #{e.message}".red
      return false
    end
  else
    puts "tmux directory doesn't exist, nothing to remove".yellow
    return true
  end
end

# Main function
def main
  print_header("tmux Configuration Uninstaller v#{VERSION}")
  
  puts "This script will remove tmux customizations installed by the terminal-setup project.".yellow
  if !options[:keep_plugins]
    puts "WARNING: All tmux plugins will be removed.".red
  else
    puts "User-installed plugins will be preserved.".green
  end
  
  unless options[:force]
    print "Are you sure you want to proceed? (y/n): "
    confirm = gets.chomp.downcase
    
    unless confirm == 'y' || confirm == 'yes'
      puts "Uninstall cancelled.".blue
      return 0
    end
  end
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_tmux_configs(backup_dir)
  
  success = true
  
  # Remove config file
  success &= remove_tmux_conf
  
  # Remove plugins
  success &= remove_tmux_plugins
  
  # Remove tmux directory if requested
  success &= remove_tmux_directory
  
  # Remove version file
  version_file = File.join(HOME_DIR, '.tmux_version')
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
    puts "tmux configuration has been removed.".green
    puts "Your original configurations were backed up to: #{backup_dir}".green
    
    puts "\nNext steps:".blue
    puts "1. If you want to keep using tmux with default settings, you can create a new config:"
    puts "   touch ~/.tmux.conf"
    puts "2. If you want to completely remove tmux, you can run:"
    puts "   brew uninstall tmux"
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