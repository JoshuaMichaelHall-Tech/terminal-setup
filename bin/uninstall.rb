#!/usr/bin/env ruby
# Terminal Environment Uninstaller
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'
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

def create_directory(dir)
  return true if Dir.exist?(dir)
  
  FileUtils.mkdir_p(dir)
  check_result("Created directory: #{dir}")
rescue StandardError => e
  puts "Error creating directory #{dir}: #{e.message}".red
  false
end

def create_backup_directory
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  backup_dir = File.join(HOME_DIR, "terminal_env_uninstall_backup_#{timestamp}")
  
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
  
  puts "All existing configurations backed up to #{backup_dir}".green
end

# Main function for uninstall
def run_uninstall
  print_header("Running Uninstall")
  
  puts "This script will remove the terminal environment configurations.".yellow
  puts "Your personal data and notes will be preserved, but configurations will be removed.".yellow
  puts "WARNING: This operation cannot be undone.".red
  print "Are you sure you want to proceed? (y/n): "
  confirm = gets.chomp.downcase
  
  unless confirm == 'y' || confirm == 'yes'
    puts "Uninstall cancelled.".blue
    exit 0
  end
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_existing_configs(backup_dir)
  
  # Remove Neovim config
  if Dir.exist?(CONFIG_DIRS[:nvim])
    FileUtils.rm_rf(CONFIG_DIRS[:nvim])
    puts "Removed Neovim configuration directory".green
  else
    puts "Neovim configuration directory doesn't exist".yellow
  end
  
  # Remove tmux config
  if File.exist?(CONFIG_FILES[:tmux_conf])
    FileUtils.rm(CONFIG_FILES[:tmux_conf])
    puts "Removed tmux configuration file".green
  else
    puts "tmux configuration file doesn't exist".yellow
  end
  
  # Clean up Zsh configuration
  if File.exist?(CONFIG_FILES[:zshrc])
    # Create a backup of existing .zshrc
    FileUtils.cp(CONFIG_FILES[:zshrc], "#{CONFIG_FILES[:zshrc]}.bak")
    puts "Created backup of .zshrc at #{CONFIG_FILES[:zshrc]}.bak".green
    
    # Modify the .zshrc file to remove our custom configurations
    begin
      zshrc_content = File.read(CONFIG_FILES[:zshrc])
      
      # Remove our custom sections
      zshrc_content.gsub!(/# ============ Aliases ============.*?# ============/m, '# ============')
      zshrc_content.gsub!(/# ============ Functions ============.*?# ============/m, '# ============')
      zshrc_content.gsub!(/# Terminal Development Environment.*?\n/m, '')
      
      # Write cleaned file
      File.write(CONFIG_FILES[:zshrc], zshrc_content)
      puts "Cleaned up Zsh configuration file".green
    rescue StandardError => e
      puts "Error modifying .zshrc: #{e.message}".red
      puts "Manual cleanup may be required".yellow
    end
  else
    puts "Zsh configuration file doesn't exist".yellow
  end
  
  # Remove p10k config
  if File.exist?(CONFIG_FILES[:p10k])
    FileUtils.rm(CONFIG_FILES[:p10k])
    puts "Removed Powerlevel10k configuration file".green
  else
    puts "Powerlevel10k configuration file doesn't exist".yellow
  end
  
  # Remove version file
  version_file = File.join(HOME_DIR, '.terminal_env_version')
  if File.exist?(version_file)
    FileUtils.rm(version_file)
    puts "Removed version file".green
  else
    puts "Version file doesn't exist".yellow
  end
  
  puts "\nUninstall completed successfully!".green
  puts "Your configurations have been backed up to: #{backup_dir}".green
  puts "\nNOTE: Your notes and data in ~/notes are preserved.".blue
  puts "NOTE: Third-party tools (Neovim, tmux, Oh My Zsh, etc.) are still installed.".blue
  puts "      To remove them, use your package manager (e.g., brew uninstall <package>).".blue
end

# Run the uninstall process
run_uninstall
