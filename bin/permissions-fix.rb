#!/usr/bin/env ruby
# Terminal Environment Permissions Fix
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'

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

# Main function for permissions fix
def run_permissions_fix
  print_header("Running Permissions Fix")
  
  # Fix permissions for config directories
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      FileUtils.chmod_R(0755, dir)
      puts "Fixed permissions for #{dir}".green
    else
      puts "Directory doesn't exist: #{dir}".yellow
    end
  end
  
  # Fix permissions for config files
  CONFIG_FILES.each do |name, file|
    if File.exist?(file)
      FileUtils.chmod(0644, file)
      puts "Fixed permissions for #{file}".green
    else
      puts "File doesn't exist: #{file}".yellow
    end
  end
  
  # Fix executable scripts in bin directory
  bin_scripts = Dir.glob(File.join(CONFIG_DIRS[:bin], '*'))
  bin_scripts.each do |script|
    if File.file?(script) && script =~ /\.(rb|sh)$/
      FileUtils.chmod(0755, script)
      puts "Made #{script} executable".green
    end
  end
  
  puts "\nPermissions fix completed successfully!".green
  puts "All configuration files and directories now have the correct permissions."
end

# Run the permissions fix
run_permissions_fix
