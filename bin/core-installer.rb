#!/usr/bin/env ruby
# Core Environment Installer
# Author: Joshua Michael Hall
# License: MIT
# Date: April 5, 2025

require 'fileutils'
require 'open3'
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

VERSION = '0.2.2'

# Parse options at the top level so it's available throughout the script
OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: core-installer.rb [options]"
  
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
ed path even if creation failed
  end
end

def backup_configs(backup_dir)
  print_header("Backing Up Configurations")
  
  # Create subdirectories in backup directory
  CONFIG_DIRS.each do |name, dir|
    next if name == :notes && OPTIONS[:keep_data] # Skip notes if keeping data
    
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

# Installation functions
def install_homebrew
  print_header("Installing Homebrew")
  
  if command_exists?('brew')
    puts "Homebrew is already installed, updating...".yellow
    run_command('brew update')
    check_result("Updated Homebrew")
    return true
  end
  
  puts "Installing Homebrew...".blue
  install_cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  output, success = run_command(install_cmd)
  
  if success
    puts "Homebrew installed successfully".green
    
    # Add Homebrew to PATH for current session
    if File.exist?('/opt/homebrew/bin/brew')
      ENV['PATH'] = "/opt/homebrew/bin:#{ENV['PATH']}"
      check_result("Added Homebrew to PATH for current session")
      
      # Add Homebrew to PATH permanently if not already there
      zshrc_file = File.join(HOME_DIR, '.zshrc')
      if File.exist?(zshrc_file) && !File.read(zshrc_file).include?('eval "$(brew shellenv)"')
        File.open(zshrc_file, 'a') do |f|
          f.puts 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        end
        check_result("Added Homebrew to PATH permanently")
      end
    end
    
    return true
  else
    puts "Failed to install Homebrew".red
    puts "Please install Homebrew manually from https://brew.sh".yellow
    return false
  end
end

def install_required_tools
  print_header("Installing Required Tools")
  
  required_tools = {
    'ruby' => 'brew install ruby',
    'git' => 'brew install git',
    'zsh' => 'brew install zsh',
    'nvim' => 'brew install neovim',
    'tmux' => 'brew install tmux',
    'fzf' => 'brew install fzf',
    'fd' => 'brew install fd',
    'rg' => 'brew install ripgrep'
  }
  
  success = true
  required_tools.each do |tool, install_cmd|
    if command_exists?(tool)
      version, version_success = run_command("#{tool} --version")
      version = version.lines.first.strip if version_success
      puts "#{tool} is already installed: #{version}".green
    else
      puts "Installing #{tool}...".blue
      output, install_success = run_command(install_cmd)
      
      if install_success
        puts "#{tool} installed successfully".green
      else
        puts "Failed to install #{tool}".red
        puts "Please install #{tool} manually with: #{install_cmd}".yellow
        success = false
      end
    end
  end
  
  success
end

def install_fonts
  print_header("Installing Nerd Fonts")
  
  # Tap homebrew fonts
  run_command('brew tap homebrew/cask-fonts')
  
  # Install JetBrainsMono Nerd Font
  if !system('brew list --cask font-jetbrains-mono-nerd-font &>/dev/null')
    puts "Installing JetBrainsMono Nerd Font...".blue
    output, success = run_command('brew install --cask font-jetbrains-mono-nerd-font')
    check_result("Installed JetBrainsMono Nerd Font", success)
  else
    puts "JetBrainsMono Nerd Font is already installed".green
  end
  
  # Install Hack Nerd Font
  if !system('brew list --cask font-hack-nerd-font &>/dev/null')
    puts "Installing Hack Nerd Font...".blue
    output, success = run_command('brew install --cask font-hack-nerd-font')
    check_result("Installed Hack Nerd Font", success)
  else
    puts "Hack Nerd Font is already installed".green
  end
  
  true
end

def install_rectangle
  print_header("Installing Rectangle Window Manager")
  
  if File.directory?('/Applications/Rectangle.app')
    puts "Rectangle is already installed".green
    return true
  end
  
  puts "Installing Rectangle...".blue
  output, success = run_command('brew install --cask rectangle')
  
  if success
    puts "Rectangle installed successfully".green
    return true
  else
    puts "Failed to install Rectangle".red
    puts "Please install Rectangle manually with: brew install --cask rectangle".yellow
    return false
  end
end

def create_core_directories
  print_header("Creating Core Directories")
  
  success = true
  CONFIG_DIRS.each do |name, dir|
    if create_directory(dir)
      puts "Directory exists/created: #{dir}".green
    else
      puts "Failed to create directory: #{dir}".red
      success = false
    end
  end
  
  # Create bin symlinks
  bin_scripts = Dir.glob(File.join(File.dirname(__FILE__), '*.rb'))
  bin_dir = CONFIG_DIRS[:bin]
  
  bin_scripts.each do |script|
    base_name = File.basename(script)
    target = File.join(bin_dir, base_name)
    
    # Skip if target already exists and is not a symbolic link
    next if File.exist?(target) && !File.symlink?(target)
    
    # Create symbolic link
    begin
      FileUtils.ln_sf(script, target)
      FileUtils.chmod(0755, script) # Make it executable
      puts "Created symlink: #{target} -> #{script}".green
    rescue => e
      puts "Failed to create symlink for #{script}: #{e.message}".red
      success = false
    end
  end
  
  success
end

def create_notes_skeleton
  print_header("Creating Notes Skeleton")
  
  notes_dir = CONFIG_DIRS[:notes]
  subdirs = ['daily', 'projects', 'learning', 'templates']
  
  subdirs.each do |subdir|
    subdir_path = File.join(notes_dir, subdir)
    if create_directory(subdir_path)
      puts "Notes subdirectory exists/created: #{subdir_path}".green
    else
      puts "Failed to create notes subdirectory: #{subdir_path}".red
      return false
    end
  end
  
  # Create README file
  readme_path = File.join(notes_dir, 'README.md')
  unless File.exist?(readme_path)
    begin
      File.open(readme_path, 'w') do |f|
        f.puts "# Notes System"
        f.puts ""
        f.puts "This directory contains a structured notes system for:"
        f.puts ""
        f.puts "- **Daily notes**: Daily logs and journals"
        f.puts "- **Project notes**: Documentation for specific projects"
        f.puts "- **Learning notes**: Study materials organized by topic"
        f.puts ""
        f.puts "## Usage"
        f.puts ""
        f.puts "Use the following commands in Neovim:"
        f.puts ""
        f.puts "- `:Daily` - Create or edit today's daily note"
        f.puts "- `:Project` - Create or edit a project note"
        f.puts "- `:Learning` - Create or edit a learning note"
        f.puts "- `:NotesFiles` - Find notes files"
        f.puts "- `:NotesGrep` - Search within notes"
        f.puts "- `:RecentNotes` - Show recently modified notes"
        f.puts ""
        f.puts "This notes system is managed by a Neovim plugin and is backed by Git for version control."
      end
      puts "Created notes README file".green
    rescue => e
      puts "Failed to create notes README file: #{e.message}".red
      return false
    end
  else
    puts "Notes README file already exists".green
  end
  
  # Initialize Git repository if not already initialized
  if !Dir.exist?(File.join(notes_dir, '.git'))
    Dir.chdir(notes_dir) do
      run_command('git init')
      run_command('git add README.md')
      run_command('git commit -m "Initialize notes repository"')
    end
    puts "Initialized Git repository for notes".green
  else
    puts "Git repository for notes already initialized".green
  end
  
  # Create .gitignore file
  gitignore_path = File.join(notes_dir, '.gitignore')
  unless File.exist?(gitignore_path)
    begin
      File.open(gitignore_path, 'w') do |f|
        f.puts "# Ignore temporary files"
        f.puts "*~"
        f.puts "*.swp"
        f.puts "*.swo"
        f.puts ""
        f.puts "# Ignore OS files"
        f.puts ".DS_Store"
        f.puts "Thumbs.db"
        f.puts ""
        f.puts "# Ignore private notes"
        f.puts "private/"
      end
      puts "Created .gitignore file".green
    rescue => e
      puts "Failed to create .gitignore file: #{e.message}".red
      return false
    end
  else
    puts "Git ignore file already exists".green
  end
  
  true
end

# Main installation functions
def run_full_install
  print_header("Running Full Core Installation")
  
  # Create backup first
  backup_dir = create_backup_directory
  
  # Install Homebrew
  success = install_homebrew
  
  # Install required tools
  success &&= install_required_tools
  
  # Install fonts
  success &&= install_fonts
  
  # Install Rectangle
  success &&= install_rectangle
  
  # Create directories
  success &&= create_core_directories
  
  # Create notes skeleton
  success &&= create_notes_skeleton
  
  # Set version marker
  version_file = File.join(HOME_DIR, '.core_env_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}")
  
  success
end

def run_minimal_update
  print_header("Running Minimal Core Update")
  
  # Only update configuration, don't reinstall components
  success = true
  
  # Create directories
  success &&= create_core_directories
  
  # Create notes skeleton
  success &&= create_notes_skeleton
  
  # Update version marker
  version_file = File.join(HOME_DIR, '.core_env_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}\nmode=minimal")
  
  success
end

def run_fix_mode
  print_header("Running Fix Mode for Core Environment")
  
  # Fix directory permissions
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      begin
        FileUtils.chmod_R(0755, dir)
        puts "Fixed permissions for #{dir}".green
      rescue => e
        puts "Failed to fix permissions for #{dir}: #{e.message}".red
      end
    end
  end
  
  # Ensure core directories exist
  create_core_directories
end

# Main entry point
def main
  print_header("Core Environment Installer v#{VERSION}")
  
  if OPTIONS[:fix]
    success = run_fix_mode
  elsif OPTIONS[:minimal]
    success = run_minimal_update
  else
    success = run_full_install
  end
  
  if success
    print_header("Core Environment Installation Completed Successfully")
    puts "Core environment is now set up.".green
  else
    print_header("Installation Completed with Errors")
    puts "Some components may not have installed correctly.".red
    puts "Please check the error messages above.".yellow
  end
  
  return success ? 0 : 1
end

# Run the script
exit main
