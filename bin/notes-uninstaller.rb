#!/usr/bin/env ruby
# Notes System Uninstaller
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
NOTES_DIR = File.join(HOME_DIR, 'notes')
NVIM_CONFIG_DIR = File.join(HOME_DIR, '.config/nvim')
NVIM_PLUGIN_DIR = File.join(NVIM_CONFIG_DIR, 'plugin')
NOTES_PLUGIN_FILE = File.join(NVIM_PLUGIN_DIR, 'notes.vim')
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
  keep_notes: true,     # Don't remove user notes
  force: false          # Don't ask for confirmation
}

OptionParser.new do |opts|
  opts.banner = "Usage: notes_uninstaller.rb [options]"
  
  opts.on("--no-keep-notes", "Remove all user notes") do
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
  backup_dir = File.join(HOME_DIR, "notes_backup_#{timestamp}")
  
  begin
    FileUtils.mkdir_p(backup_dir)
    puts "Created backup directory: #{backup_dir}".green
    return backup_dir
  rescue StandardError => e
    puts "Error creating backup directory #{backup_dir}: #{e.message}".red
    return backup_dir # Still return the intended path even if creation failed
  end
end


def backup_notes(backup_dir)
  print_header("Backing Up Notes")
  
  # Backup notes directory if it exists
  if Dir.exist?(NOTES_DIR)
    notes_backup = File.join(backup_dir, 'notes')
    FileUtils.cp_r(NOTES_DIR, notes_backup)
    puts "Backed up notes directory to #{notes_backup}".green
  end
  
  # Backup Neovim notes plugin if it exists
  if File.exist?(NOTES_PLUGIN_FILE)
    plugin_backup = File.join(backup_dir, 'notes.vim')
    FileUtils.cp(NOTES_PLUGIN_FILE, plugin_backup)
    puts "Backed up notes plugin to #{plugin_backup}".green
  end
  
  puts "Notes backed up to #{backup_dir}".green
  backup_dir
end

def remove_notes_plugin
  print_header("Removing Notes Plugin")
  
  if File.exist?(NOTES_PLUGIN_FILE)
    begin
      File.delete(NOTES_PLUGIN_FILE)
      puts "Removed notes plugin file: #{NOTES_PLUGIN_FILE}".green
      return true
    rescue => e
      puts "Failed to remove notes plugin file: #{e.message}".red
      return false
    end
  else
    puts "Notes plugin file doesn't exist, nothing to remove".yellow
    return true
  end
end

def remove_init_lua_reference
  print_header("Removing Notes Reference from init.lua")
  
  init_file = File.join(NVIM_CONFIG_DIR, 'init.lua')
  
  if File.exist?(init_file)
    begin
      init_content = File.read(init_file)
      
      if init_content.include?('notes.vim')
        # Create backup
        backup = "#{init_file}.bak.#{Time.now.strftime('%Y%m%d%H%M%S')}"
        FileUtils.cp(init_file, backup)
        puts "Created backup of init.lua at #{backup}".green
        
        # Remove notes.vim reference
        new_content = init_content.gsub(/\n?-- Notes system\nvim.cmd\('source ' \.\. vim.fn.stdpath\('config'\) \.\. '\/plugin\/notes.vim'\)/, '')
        
        # Write modified content
        File.write(init_file, new_content)
        puts "Removed notes.vim reference from init.lua".green
        return true
      else
        puts "No notes.vim reference found in init.lua, nothing to remove".yellow
        return true
      end
    rescue => e
      puts "Failed to modify init.lua: #{e.message}".red
      return false
    end
  else
    puts "init.lua doesn't exist, nothing to modify".yellow
    return true
  end
end

def remove_notes_directory
  print_header("Removing Notes Directory")
  
  if OPTIONS[:$1]
    puts "Keeping notes directory as requested".green
    return true
  end
  
  if Dir.exist?(NOTES_DIR)
    begin
      FileUtils.rm_rf(NOTES_DIR)
      puts "Removed notes directory: #{NOTES_DIR}".green
      return true
    rescue => e
      puts "Failed to remove notes directory: #{e.message}".red
      return false
    end
  else
    puts "Notes directory doesn't exist, nothing to remove".yellow
    return true
  end
end

# Main function
def main
  print_header("Notes System Uninstaller v#{VERSION}")
  
  puts "This script will remove the notes system installed by the terminal-setup project.".yellow
  
  if OPTIONS[:$1]
    puts "Notes directory will be preserved.".green
  else
    puts "WARNING: Notes directory will be removed.".red
    puts "All your notes will be lost.".red
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
  backup_notes(backup_dir)
  
  success = true
  
  # Remove notes plugin
  success &= remove_notes_plugin
  
  # Remove reference in init.lua
  success &= remove_init_lua_reference
  
  # Remove notes directory if requested
  success &= remove_notes_directory
  
  # Remove version file
  version_file = File.join(HOME_DIR, '.notes_version')
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
    puts "Notes system has been removed.".green
    puts "Your original notes were backed up to: #{backup_dir}".green
    
    if OPTIONS[:$1]
      puts "\nYour notes directory was preserved at: #{NOTES_DIR}".green
    else
      puts "\nYour notes directory was removed.".yellow
    end
  else
    print_header("Uninstallation Completed with Errors")
    puts "Some components may not have been removed correctly.".red
    puts "Please check the error messages above.".yellow
    puts "Your original notes were backed up to: #{backup_dir}".green
  end
  
  return success ? 0 : 1
end

# Run the script
exit main