#!/usr/bin/env ruby
# Core Environment Troubleshooter
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
  bin: File.join(HOME_DIR, 'bin'),
  config: File.join(HOME_DIR, '.config'),
  notes: File.join(HOME_DIR, 'notes'),
  undodir: File.join(HOME_DIR, '.vim/undodir')
}
REQUIRED_TOOLS = %w[ruby git zsh nvim tmux fzf fd rg]
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
  opts.banner = "Usage: core_troubleshooter.rb [options]"
  
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

# Troubleshooting functions
def check_required_tools
  print_header("Checking Required Tools")
  
  all_tools_ok = true
  missing_tools = []
  
  REQUIRED_TOOLS.each do |tool|
    if command_exists?(tool)
      version, success = run_command("#{tool} --version")
      if success
        puts "✓ #{tool} is installed: #{version.strip}".green
      else
        puts "✓ #{tool} is installed".green
      end
    else
      puts "✗ #{tool} is not installed".red
      missing_tools << tool
      all_tools_ok = false
    end
  end
  
  if !missing_tools.empty? && OPTIONS[:$1]
    puts "Attempting to install missing tools...".blue
    
    if command_exists?('brew')
      missing_tools.each do |tool|
        puts "Installing #{tool}...".blue
        output, success = run_command("brew install #{tool}")
        if success
          puts "✓ #{tool} installed successfully".green
        else
          puts "✗ Failed to install #{tool}".red
          puts "  Please install #{tool} manually with: brew install #{tool}".yellow
        end
      end
    else
      puts "✗ Cannot automatically install missing tools (Homebrew not found)".red
      puts "  Please install Homebrew first with:".yellow
      puts "  /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"".yellow
    end
  elsif !missing_tools.empty?
    puts "Run with --fix to attempt installing missing tools, or install manually with Homebrew:".yellow
    missing_tools.each do |tool|
      puts "  brew install #{tool}".yellow
    end
  end
  
  all_tools_ok
end

def check_directories
  print_header("Checking Required Directories")
  
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
  
  if !all_dirs_ok && !OPTIONS[:$1]
    puts "Run with --fix to create missing directories".yellow
  end
  
  all_dirs_ok
end

def check_permissions
  print_header("Checking Directory Permissions")
  
  all_perms_ok = true
  
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      if File.stat(dir).mode & 0777 == 0755
        puts "✓ #{name} directory has correct permissions".green
      else
        puts "✗ #{name} directory has incorrect permissions".red
        all_perms_ok = false
        
        if OPTIONS[:$1]
          puts "Fixing permissions for #{name} directory...".blue
          begin
            FileUtils.chmod(0755, dir)
            puts "✓ Fixed permissions for #{name} directory".green
          rescue => e
            puts "✗ Failed to fix permissions for #{name} directory: #{e.message}".red
          end
        end
      end
    end
  end
  
  if !all_perms_ok && !OPTIONS[:$1]
    puts "Run with --fix to fix directory permissions".yellow
  end
  
  all_perms_ok
end

def check_notes_setup
  print_header("Checking Notes Setup")
  
  notes_dir = CONFIG_DIRS[:notes]
  unless Dir.exist?(notes_dir)
    puts "✗ Notes directory doesn't exist".red
    return false
  end
  
  # Check subdirectories
  subdirs = ['daily', 'projects', 'learning', 'templates']
  missing_subdirs = []
  
  subdirs.each do |subdir|
    subdir_path = File.join(notes_dir, subdir)
    if Dir.exist?(subdir_path)
      puts "✓ Notes subdirectory exists: #{subdir}".green
    else
      puts "✗ Notes subdirectory doesn't exist: #{subdir}".red
      missing_subdirs << subdir
    end
  end
  
  # Check README file
  readme_path = File.join(notes_dir, 'README.md')
  if File.exist?(readme_path)
    puts "✓ Notes README file exists".green
  else
    puts "✗ Notes README file doesn't exist".red
    missing_subdirs << 'README.md'
  end
  
  # Check Git repository
  if Dir.exist?(File.join(notes_dir, '.git'))
    puts "✓ Notes Git repository is initialized".green
  else
    puts "✗ Notes Git repository is not initialized".red
    missing_subdirs << '.git'
  end
  
  if !missing_subdirs.empty? && OPTIONS[:$1]
    puts "Fixing notes setup...".blue
    
    # Create missing subdirectories
    subdirs.each do |subdir|
      subdir_path = File.join(notes_dir, subdir)
      unless Dir.exist?(subdir_path)
        if create_directory(subdir_path)
          puts "✓ Created notes subdirectory: #{subdir}".green
        else
          puts "✗ Failed to create notes subdirectory: #{subdir}".red
        end
      end
    end
    
    # Create README file if missing
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
        puts "✓ Created notes README file".green
      rescue => e
        puts "✗ Failed to create notes README file: #{e.message}".red
      end
    end
    
    # Initialize Git repository if needed
    unless Dir.exist?(File.join(notes_dir, '.git'))
      Dir.chdir(notes_dir) do
        run_command('git init')
        run_command('git add README.md') if File.exist?(readme_path)
        run_command('git commit -m "Initialize notes repository"')
      end
      puts "✓ Initialized Git repository for notes".green
    end
  elsif !missing_subdirs.empty?
    puts "Run with --fix to fix notes setup".yellow
  end
  
  missing_subdirs.empty?
end

def check_bin_scripts
  print_header("Checking Bin Scripts")
  
  bin_dir = CONFIG_DIRS[:bin]
  unless Dir.exist?(bin_dir)
    puts "✗ Bin directory doesn't exist".red
    return false
  end
  
  # Check for essential scripts
  essential_scripts = %w[
    master-installer.rb
    core_installer.rb
    core_troubleshooter.rb
    zsh_installer.rb
    zsh_troubleshooter.rb
    zsh_uninstaller.rb
    nvim_installer.rb
    nvim_troubleshooter.rb
    tmux_installer.rb
    tmux_troubleshooter.rb
    notes_installer.rb
    notes_troubleshooter.rb
  ]
  
  missing_scripts = []
  
  essential_scripts.each do |script|
    script_path = File.join(bin_dir, script)
    if File.exist?(script_path)
      if File.executable?(script_path)
        puts "✓ Script exists and is executable: #{script}".green
      else
        puts "✗ Script exists but is not executable: #{script}".red
        missing_scripts << script
      end
    else
      puts "✗ Script doesn't exist: #{script}".red
      missing_scripts << script
    end
  end
  
  if !missing_scripts.empty? && OPTIONS[:$1]
    puts "Fixing bin scripts...".blue
    
    # Make existing scripts executable
    essential_scripts.each do |script|
      script_path = File.join(bin_dir, script)
      if File.exist?(script_path) && !File.executable?(script_path)
        begin
          FileUtils.chmod(0755, script_path)
          puts "✓ Made script executable: #{script}".green
        rescue => e
          puts "✗ Failed to make script executable: #{script} - #{e.message}".red
        end
      end
    end
    
    # Note: We cannot create missing scripts automatically as we don't have the content
    if missing_scripts.any? { |s| !File.exist?(File.join(bin_dir, s)) }
      puts "Some scripts are missing and cannot be created automatically.".yellow
      puts "Please make sure all required scripts are present in the bin directory.".yellow
    end
  elsif !missing_scripts.empty?
    puts "Run with --fix to fix bin scripts".yellow
  end
  
  missing_scripts.empty?
end

def check_homebrew
  print_header("Checking Homebrew")
  
  if command_exists?('brew')
    version, _ = run_command('brew --version')
    puts "✓ Homebrew is installed: #{version.strip}".green
    return true
  else
    puts "✗ Homebrew is not installed".red
    
    if OPTIONS[:$1]
      puts "Attempting to install Homebrew...".blue
      install_cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      output, success = run_command(install_cmd)
      
      if success && command_exists?('brew')
        puts "✓ Homebrew installed successfully".green
        return true
      else
        puts "✗ Failed to install Homebrew".red
        puts "  Please install Homebrew manually from https://brew.sh".yellow
        return false
      end
    else
      puts "Run with --fix to attempt installing Homebrew, or install manually:".yellow
      puts "  /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"".yellow
      return false
    end
  end
end

# Main function
def main
  print_header("Core Environment Troubleshooter v#{VERSION}")
  
  # Collect issues
  issues = []
  
  # Check Homebrew
  puts "Checking Homebrew...".blue
  homebrew_ok = check_homebrew
  issues << "Homebrew" unless homebrew_ok
  
  # Check required tools
  puts "Checking required tools...".blue
  tools_ok = check_required_tools
  issues << "Required tools" unless tools_ok
  
  # Check directories
  puts "Checking directories...".blue
  dirs_ok = check_directories
  issues << "Directories" unless dirs_ok
  
  # Check permissions
  puts "Checking permissions...".blue
  perms_ok = check_permissions
  issues << "Permissions" unless perms_ok
  
  # Check notes setup
  puts "Checking notes setup...".blue
  notes_ok = check_notes_setup
  issues << "Notes setup" unless notes_ok
  
  # Check bin scripts
  puts "Checking bin scripts...".blue
  bin_ok = check_bin_scripts
  issues << "Bin scripts" unless bin_ok
  
  # Final report
  print_header("Troubleshooting Summary")
  
  if issues.empty?
    puts "✓ All core environment components are installed and configured correctly".green
  else
    puts "✗ Issues found in the following areas:".red
    issues.each_with_index do |issue, index|
      puts "  #{index + 1}. #{issue}".yellow
    end
    
    if OPTIONS[:$1]
      puts "\nAttempted to fix all issues. Please check the output above for any remaining problems.".blue
    else
      puts "\nRun this script with --fix option to attempt automatic fixes for these issues.".blue
    end
  end
  
  # Return success if no issues or all issues fixed
  issues.empty?
end

# Run the script
exit main ? 0 : 1