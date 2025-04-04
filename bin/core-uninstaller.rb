#!/usr/bin/env ruby
# Core Environment Uninstaller
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
  bin: File.join(HOME_DIR, 'bin'),
  config: File.join(HOME_DIR, '.config'),
  notes: File.join(HOME_DIR, 'notes'),
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
options = { full: false, keep_data: true, force: false }

OptionParser.new do |opts|
  opts.banner = "Usage: core_uninstaller.rb [options]"
  
  opts.on("--full", "Full uninstallation (remove all configurations and data)") do
    OPTIONS[:$1] = true
  end
  
  opts.on("--no-keep-data", "Do not keep user data") do
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
  backup_dir = File.join(HOME_DIR, "core_env_backup_#{timestamp}")
  
  begin
    FileUtils.mkdir_p(backup_dir)
    puts "Created backup directory: #{backup_dir}".green
    return backup_dir
  rescue StandardError => e
    puts "Error creating backup directory #{backup_dir}: #{e.message}".red
    return backup_dir # Still return the intended path even if creation failed
  end
end


def backup_configs(backup_dir)
  print_header("Backing Up Configurations")
  
  # Create subdirectories in backup directory
  CONFIG_DIRS.each do |name, dir|
    next if name == :notes && OPTIONS[:$1] # Skip notes if keeping data
    
    if Dir.exist?(dir)
      backup_subdir = File.join(backup_dir, name.to_s)
      
      begin
        FileUtils.cp_r(dir, backup_subdir)
        puts "Backed up #{name} directory to #{backup_subdir}".green
      rescue => e
        puts "Failed to backup #{name} directory: #{e.message}".red
      end
    end
  end
  
  puts "All configurations backed up to #{backup_dir}".green
  backup_dir
end

def remove_bin_scripts
  print_header("Removing Bin Scripts")
  
  bin_dir = CONFIG_DIRS[:bin]
  unless Dir.exist?(bin_dir)
    puts "Bin directory doesn't exist, nothing to remove".yellow
    return true
  end
  
  # List of scripts to remove
  scripts = [
    'master-installer.rb',
    'core_installer.rb',
    'core_troubleshooter.rb',
    'core_uninstaller.rb',
    'zsh_installer.rb',
    'zsh_troubleshooter.rb',
    'zsh_uninstaller.rb',
    'nvim_installer.rb',
    'nvim_troubleshooter.rb',
    'nvim_uninstaller.rb',
    'tmux_installer.rb',
    'tmux_troubleshooter.rb',
    'tmux_uninstaller.rb',
    'notes_installer.rb',
    'notes_troubleshooter.rb',
    'notes_uninstaller.rb'
  ]
  
  # Remove each script
  scripts.each do |script|
    script_path = File.join(bin_dir, script)
    if File.exist?(script_path)
      begin
        File.delete(script_path)
        puts "Removed script: #{script}".green
      rescue => e
        puts "Failed to remove script #{script}: #{e.message}".red
      end
    end
  end
  
  # Check if bin directory is empty and remove it if full uninstall
  if OPTIONS[:$1] && Dir.exist?(bin_dir) && Dir.empty?(bin_dir)
    begin
      Dir.rmdir(bin_dir)
      puts "Removed empty bin directory".green
    rescue => e
      puts "Failed to remove bin directory: #{e.message}".red
    end
  end
  
  true
end

def remove_config_files
  print_header("Removing Configuration Files")
  
  # Remove version file
  version_file = File.join(HOME_DIR, '.core_env_version')
  if File.exist?(version_file)
    begin
      File.delete(version_file)
      puts "Removed version file: #{version_file}".green
    rescue => e
      puts "Failed to remove version file: #{e.message}".red
    end
  end
  
  # If full uninstall and not keeping data, remove config directories
  if OPTIONS[:$1] && !OPTIONS[:$1]
    CONFIG_DIRS.each do |name, dir|
      next if name == :notes && OPTIONS[:$1] # Skip notes if keeping data
      
      if Dir.exist?(dir)
        begin
          FileUtils.rm_rf(dir)
          puts "Removed #{name} directory: #{dir}".green
        rescue => e
          puts "Failed to remove #{name} directory: #{e.message}".red
        end
      end
    end
  end
  
  true
end

# Main function
def main
  print_header("Core Environment Uninstaller v#{VERSION}")
  
  puts "This script will remove the core environment components installed by the terminal-setup project.".yellow
  if OPTIONS[:$1]
    puts "Running in FULL uninstall mode. This will remove all installed components.".red
    if !OPTIONS[:$1]
      puts "WARNING: User data will NOT be preserved.".red
    end
  else
    puts "Running in soft uninstall mode. This will remove only the installer scripts.".yellow
    puts "User data will be preserved.".green
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
  backup_configs(backup_dir)
  
  success = true
  
  # Remove bin scripts
  success &= remove_bin_scripts
  
  # Remove config files
  success &= remove_config_files
  
  if success
    print_header("Uninstallation Completed Successfully")
    puts "Core environment has been removed.".green
    puts "Your original configurations were backed up to: #{backup_dir}".green
    
    if OPTIONS[:$1]
      puts "\nYour user data in ~/notes has been preserved.".green
    else
      puts "\nAll user data has been removed.".yellow
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