#!/usr/bin/env ruby
# Notes System Troubleshooter
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
NOTES_DIR = File.join(HOME_DIR, 'notes')
NOTES_SUBDIRS = {
  daily: File.join(NOTES_DIR, 'daily'),
  projects: File.join(NOTES_DIR, 'projects'),
  learning: File.join(NOTES_DIR, 'learning'),
  templates: File.join(NOTES_DIR, 'templates')
}
TEMPLATE_FILES = {
  daily: File.join(NOTES_SUBDIRS[:templates], 'daily.md'),
  project: File.join(NOTES_SUBDIRS[:templates], 'project.md'),
  learning: File.join(NOTES_SUBDIRS[:templates], 'learning.md')
}
OTHER_FILES = {
  readme: File.join(NOTES_DIR, 'README.md'),
  gitignore: File.join(NOTES_DIR, '.gitignore')
}
NVIM_CONFIG_DIR = File.join(HOME_DIR, '.config/nvim')
NVIM_PLUGIN_DIR = File.join(NVIM_CONFIG_DIR, 'plugin')
NOTES_PLUGIN_FILE = File.join(NVIM_PLUGIN_DIR, 'notes.vim')
VERSION = '0.2.0'

# Options parsing
options = { fix: false, verbose: false }

OptionParser.new do |opts|
  opts.banner = "Usage: notes_troubleshooter.rb [options]"
  
  opts.on("--fix", "Fix issues automatically") do
    options[:fix] = true
  end
  
  opts.on("--verbose", "Show detailed information") do
    options[:verbose] = true
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
  
  FileUtils.mkdir_p(dir)
  check_result("Created directory: #{dir}")
rescue StandardError => e
  puts "Error creating directory #{dir}: #{e.message}".red
  false
end

def create_file(file, content)
  create_directory(File.dirname(file))
  
  File.open(file, 'w') do |f|
    f.write(content)
  end
  check_result("Created file: #{file}")
rescue StandardError => e
  puts "Error creating file #{file}: #{e.message}".red
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

# Template creation functions
def create_daily_template(file)
  content = <<~TEMPLATE
    # Daily Note: {{date}}

    ## Focus Areas
    - 

    ## Notes
    - 

    ## Tasks
    - [ ] 

    ## Progress
    - 

    ## Links
    - 
  TEMPLATE
  
  create_file(file, content)
end

def create_project_template(file)
  content = <<~TEMPLATE
    # Project: {{project_name}}

    ## Overview
    - **Goal**: 
    - **Timeline**: 
    - **Status**: 

    ## Requirements
    - 

    ## Notes
    - 

    ## Tasks
    - [ ] 

    ## Resources
    - 
  TEMPLATE
  
  create_file(file, content)
end

def create_learning_template(file)
  content = <<~TEMPLATE
    # Learning: {{topic}}

    ## Objectives
    - 

    ## Key Concepts
    - 

    ## Code Examples
    ```
    # Code example here
    ```

    ## Resources
    - 

    ## Questions
    - 

    ## Practice
    - 
  TEMPLATE
  
  create_file(file, content)
end

def create_readme(file)
  content = <<~README
    # Notes System

    This directory contains a structured notes system for:

    - **Daily notes**: Daily logs and journals
    - **Project notes**: Documentation for specific projects
    - **Learning notes**: Study materials organized by topic

    ## Usage

    Use the following commands in Neovim:

    - `:Daily` - Create or edit today's daily note
    - `:Project` - Create or edit a project note
    - `:Learning` - Create or edit a learning note
    - `:NotesFiles` - Find notes files
    - `:NotesGrep` - Search within notes
    - `:RecentNotes` - Show recently modified notes

    This notes system is managed by a Neovim plugin and is backed by Git for version control.
  README
  
  create_file(file, content)
end

def create_gitignore(file)
  content = <<~GITIGNORE
    # Ignore temporary files
    *~
    *.swp
    *.swo

    # Ignore OS files
    .DS_Store
    Thumbs.db

    # Ignore private notes
    private/
  GITIGNORE
  
  create_file(file, content)
end

def initialize_git_repository(dir)
  return true if Dir.exist?(File.join(dir, '.git'))
  
  Dir.chdir(dir) do
    run_command('git init')
    run_command('git add README.md')
    run_command('git commit -m "Initialize notes repository"')
  end
  
  check_result("Initialized Git repository in #{dir}")
end

# Troubleshooting functions
def check_neovim_installation
  print_header("Checking Neovim Installation")
  
  if command_exists?('nvim')
    version, success = run_command('nvim --version')
    if success
      puts "✓ Neovim is installed: #{version.split("\n").first}".green
      return true
    else
      puts "✗ Neovim seems to be installed but version check failed".red
      return false
    end
  else
    puts "✗ Neovim is not installed".red
    puts "  Notes plugin requires Neovim to be installed".red
    
    if options[:fix]
      puts "Attempting to install Neovim...".blue
      if command_exists?('brew')
        output, success = run_command('brew install neovim')
        if success && command_exists?('nvim')
          puts "✓ Neovim installed successfully".green
          return true
        else
          puts "✗ Failed to install Neovim".red
          puts "  Please install Neovim manually with: brew install neovim".yellow
          return false
        end
      else
        puts "✗ Cannot automatically install Neovim (Homebrew not found)".red
        puts "  Please install Neovim manually and run this script again".yellow
        return false
      end
    else
      puts "  Run with --fix to attempt installation, or install manually".yellow
      return false
    end
  end
end

def check_notes_directories
  print_header("Checking Notes Directories")
  
  all_dirs_ok = true
  
  # Check main notes directory
  if Dir.exist?(NOTES_DIR)
    puts "✓ Notes directory exists: #{NOTES_DIR}".green
  else
    puts "✗ Notes directory doesn't exist: #{NOTES_DIR}".red
    all_dirs_ok = false
    
    if options[:fix]
      puts "Creating notes directory...".blue
      if create_directory(NOTES_DIR)
        puts "✓ Created notes directory".green
      else
        puts "✗ Failed to create notes directory".red
        return false
      end
    end
  end
  
  # Check subdirectories
  NOTES_SUBDIRS.each do |name, dir|
    if Dir.exist?(dir)
      puts "✓ #{name} subdirectory exists: #{dir}".green
    else
      puts "✗ #{name} subdirectory doesn't exist: #{dir}".red
      all_dirs_ok = false
      
      if options[:fix]
        puts "Creating #{name} subdirectory...".blue
        if create_directory(dir)
          puts "✓ Created #{name} subdirectory".green
        else
          puts "✗ Failed to create #{name} subdirectory".red
        end
      end
    end
  end
  
  if !all_dirs_ok && !options[:fix]
    puts "Run with --fix to create missing directories".yellow
  end
  
  all_dirs_ok
end

def check_template_files
  print_header("Checking Template Files")
  
  all_templates_ok = true
  
  TEMPLATE_FILES.each do |name, file|
    if File.exist?(file)
      puts "✓ #{name} template exists: #{file}".green
    else
      puts "✗ #{name} template doesn't exist: #{file}".red
      all_templates_ok = false
      
      if options[:fix]
        puts "Creating #{name} template...".blue
        case name
        when :daily
          create_daily_template(file)
        when :project
          create_project_template(file)
        when :learning
          create_learning_template(file)
        end
      end
    end
  end
  
  OTHER_FILES.each do |name, file|
    if File.exist?(file)
      puts "✓ #{name} file exists: #{file}".green
    else
      puts "✗ #{name} file doesn't exist: #{file}".red
      all_templates_ok = false
      
      if options[:fix]
        puts "Creating #{name} file...".blue
        case name
        when :readme
          create_readme(file)
        when :gitignore
          create_gitignore(file)
        end
      end
    end
  end
  
  if !all_templates_ok && !options[:fix]
    puts "Run with --fix to create missing template files".yellow
  end
  
  all_templates_ok
end

def check_git_repository
  print_header("Checking Git Repository")
  
  git_dir = File.join(NOTES_DIR, '.git')
  
  if Dir.exist?(git_dir)
    puts "✓ Git repository is initialized: #{git_dir}".green
    return true
  else
    puts "✗ Git repository is not initialized: #{git_dir}".red
    
    if options[:fix]
      puts "Initializing Git repository...".blue
      if initialize_git_repository(NOTES_DIR)
        puts "✓ Initialized Git repository".green
        return true
      else
        puts "✗ Failed to initialize Git repository".red
        return false
      end
    else
      puts "Run with --fix to initialize Git repository".yellow
      return false
    end
  end
end

def check_notes_plugin
  print_header("Checking Notes Plugin")
  
  # Check Neovim plugin directory
  if Dir.exist?(NVIM_PLUGIN_DIR)
    puts "✓ Neovim plugin directory exists: #{NVIM_PLUGIN_DIR}".green
  else
    puts "✗ Neovim plugin directory doesn't exist: #{NVIM_PLUGIN_DIR}".red
    
    if options[:fix]
      puts "Creating Neovim plugin directory...".blue
      if create_directory(NVIM_PLUGIN_DIR)
        puts "✓ Created Neovim plugin directory".green
      else
        puts "✗ Failed to create Neovim plugin directory".red
        return false
      end
    else
      puts "Run with --fix to create Neovim plugin directory".yellow
      return false
    end
  end
  
  # Check notes plugin file
  if File.exist?(NOTES_PLUGIN_FILE)
    puts "✓ Notes plugin file exists: #{NOTES_PLUGIN_FILE}".green
    
    # Check if plugin file is complete
    plugin_content = File.read(NOTES_PLUGIN_FILE)
    required_functions = [
      "CreateDailyNote", 
      "CreateProjectNote", 
      "CreateLearningNote", 
      "NotesFiles", 
      "NotesGrep", 
      "NotesDir"
    ]
    
    missing_functions = []
    required_functions.each do |func|
      if !plugin_content.include?(func)
        missing_functions << func
      end
    end
    
    if missing_functions.empty?
      puts "✓ Notes plugin contains all required functions".green
    else
      puts "✗ Notes plugin is missing functions: #{missing_functions.join(', ')}".red
      
      if options[:fix]
        puts "Creating backup of existing plugin file...".blue
        create_backup(NOTES_PLUGIN_FILE)
        
        puts "Creating new notes plugin file...".blue
        
        # This part is tricky as we need to source the content from elsewhere
        # Here we'll use a simplified approach to grab the content
        if File.exist?("#{File.dirname(__FILE__)}/notes_installer.rb")
          content = File.read("#{File.dirname(__FILE__)}/notes_installer.rb")
          plugin_content = content.match(/def create_notes_plugin.*?content = <<~NOTES\n(.*?)  NOTES\n/m)[1]
          
          if plugin_content
            create_file(NOTES_PLUGIN_FILE, plugin_content)
          else
            puts "✗ Failed to extract notes plugin content from installer".red
            return false
          end
        else
          # Create a basic version here if we can't extract it
          puts "✗ Cannot extract notes plugin content, using fallback method".yellow
          File.open(NOTES_PLUGIN_FILE, 'w') do |f|
            f.puts '" Notes System Plugin for Neovim'
            f.puts '" This is a fallback version. For the full version, run the notes_installer.rb'
            
            # Add basic implementations of missing functions
            missing_functions.each do |func|
              f.puts "\nfunction! #{func}()"
              f.puts "  echo \"This is a placeholder for #{func}\""
              f.puts "endfunction"
            end
            
            # Add commands
            f.puts "\n\" Define commands"
            f.puts "command! Daily call CreateDailyNote()"
            f.puts "command! Project call CreateProjectNote()"
            f.puts "command! Learning call CreateLearningNote()"
            f.puts "command! NotesFiles call NotesFiles()"
            f.puts "command! NotesGrep call NotesGrep()"
            f.puts "command! NotesDir call NotesDir()"
          end
        end
      else
        puts "Run with --fix to create a new notes plugin file".yellow
      end
      
      return false
    end
  else
    puts "✗ Notes plugin file doesn't exist: #{NOTES_PLUGIN_FILE}".red
    
    if options[:fix]
      puts "Creating notes plugin file...".blue
      
      # Similar to above, try to source the content from the installer
      if File.exist?("#{File.dirname(__FILE__)}/notes_installer.rb")
        content = File.read("#{File.dirname(__FILE__)}/notes_installer.rb")
        plugin_content = content.match(/def create_notes_plugin.*?content = <<~NOTES\n(.*?)  NOTES\n/m)[1]
        
        if plugin_content
          create_file(NOTES_PLUGIN_FILE, plugin_content)
        else
          puts "✗ Failed to extract notes plugin content from installer".red
          return false
        end
      else
        puts "✗ Cannot find notes_installer.rb to extract plugin content".red
        puts "  Please run the installer first to create the notes plugin".yellow
        return false
      end
    else
      puts "Run with --fix to create the notes plugin file".yellow
      return false
    end
  end
  
  true
end

def check_neovim_integration
  print_header("Checking Neovim Integration")
  
  init_file = File.join(NVIM_CONFIG_DIR, 'init.lua')
  
  if File.exist?(init_file)
    init_content = File.read(init_file)
    
    if init_content.include?('notes.vim')
      puts "✓ Neovim init.lua includes notes.vim plugin".green
      return true
    else
      puts "✗ Neovim init.lua doesn't include notes.vim plugin".red
      
      if options[:fix]
        puts "Adding notes.vim to init.lua...".blue
        
        # Create backup
        create_backup(init_file)
        
        # Add notes plugin line
        File.open(init_file, 'a') do |f|
          f.puts "\n-- Notes system"
          f.puts "vim.cmd('source ' .. vim.fn.stdpath('config') .. '/plugin/notes.vim')"
        end
        
        puts "✓ Added notes.vim to init.lua".green
        return true
      else
        puts "Run with --fix to add notes.vim to init.lua".yellow
        puts "Or add the following line to your init.lua manually:".yellow
        puts "vim.cmd('source ' .. vim.fn.stdpath('config') .. '/plugin/notes.vim')".yellow
        return false
      end
    end
  else
    puts "✗ Neovim init.lua doesn't exist: #{init_file}".red
    puts "  Please set up Neovim configuration first".yellow
    return false
  end
end

def check_permissions
  print_header("Checking Permissions")
  
  all_permissions_ok = true
  
  # Check notes directory
  if Dir.exist?(NOTES_DIR)
    if File.writable?(NOTES_DIR)
      puts "✓ Notes directory is writable".green
    else
      puts "✗ Notes directory is not writable".red
      all_permissions_ok = false
      
      if options[:fix]
        puts "Fixing permissions for notes directory...".blue
        FileUtils.chmod(0755, NOTES_DIR)
        if File.writable?(NOTES_DIR)
          puts "✓ Fixed permissions for notes directory".green
        else
          puts "✗ Failed to fix permissions for notes directory".red
        end
      else
        puts "Run with --fix to fix permissions".yellow
      end
    end
  end
  
  # Check subdirectories
  NOTES_SUBDIRS.each do |name, dir|
    if Dir.exist?(dir)
      if File.writable?(dir)
        puts "✓ #{name} subdirectory is writable".green
      else
        puts "✗ #{name} subdirectory is not writable".red
        all_permissions_ok = false
        
        if options[:fix]
          puts "Fixing permissions for #{name} subdirectory...".blue
          FileUtils.chmod(0755, dir)
          if File.writable?(dir)
            puts "✓ Fixed permissions for #{name} subdirectory".green
          else
            puts "✗ Failed to fix permissions for #{name} subdirectory".red
          end
        else
          puts "Run with --fix to fix permissions".yellow
        end
      end
    end
  end
  
  all_permissions_ok
end

# Main function
def main
  print_header("Notes System Troubleshooter v#{VERSION}")
  
  # Collect issues
  issues = []
  
  # Check Neovim installation
  puts "Checking Neovim installation...".blue
  neovim_ok = check_neovim_installation
  issues << "Neovim installation" unless neovim_ok
  
  # Check notes directories
  puts "Checking notes directories...".blue
  dirs_ok = check_notes_directories
  issues << "Notes directories" unless dirs_ok
  
  # Check template files
  puts "Checking template files...".blue
  templates_ok = check_template_files
  issues << "Template files" unless templates_ok
  
  # Check Git repository
  puts "Checking Git repository...".blue
  git_ok = check_git_repository
  issues << "Git repository" unless git_ok
  
  # Check notes plugin
  puts "Checking notes plugin...".blue
  plugin_ok = check_notes_plugin
  issues << "Notes plugin" unless plugin_ok
  
  # Check Neovim integration
  puts "Checking Neovim integration...".blue
  integration_ok = check_neovim_integration
  issues << "Neovim integration" unless integration_ok
  
  # Check permissions
  puts "Checking permissions...".blue
  permissions_ok = check_permissions
  issues << "Permissions" unless permissions_ok
  
  # Final report
  print_header("Troubleshooting Summary")
  
  if issues.empty?
    puts "✓ All notes system components are installed and configured correctly".green
  else
    puts "✗ Issues found in the following areas:".red
    issues.each_with_index do |issue, index|
      puts "  #{index + 1}. #{issue}".yellow
    end
    
    if options[:fix]
      puts "\nAttempted to fix all issues. Please check the output above for any remaining problems.".blue
      puts "You may need to restart Neovim to apply the changes.".blue
    else
      puts "\nRun this script with --fix option to attempt automatic fixes for these issues.".blue
    end
  end
  
  # Return success if no issues or all issues fixed
  issues.empty?
end

# Run the script
exit main ? 0 : 1