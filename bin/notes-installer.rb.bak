#!/usr/bin/env ruby
# Notes System Installer
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'
require 'open3'
require 'date'
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
NVIM_CONFIG_DIR = File.join(HOME_DIR, '.config/nvim')
NVIM_PLUGIN_DIR = File.join(NVIM_CONFIG_DIR, 'plugin')
NOTES_PLUGIN_FILE = File.join(NVIM_PLUGIN_DIR, 'notes.vim')
VERSION = '0.2.0'

# Options parsing
options = { minimal: false, fix: false }

OptionParser.new do |opts|
  opts.banner = "Usage: notes_installer.rb [options]"
  
  opts.on("--minimal", "Minimal installation (config only)") do
    options[:minimal] = true
  end
  
  opts.on("--fix", "Fix mode (only fix existing installation)") do
    options[:fix] = true
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

def file_contains?(file, pattern)
  return false unless File.exist?(file)
  
  File.read(file) =~ Regexp.new(pattern)
end

def append_to_file(file, content)
  return false unless File.exist?(file)
  
  File.open(file, 'a') do |f|
    f.puts content
  end
  check_result("Updated file: #{file}")
rescue StandardError => e
  puts "Error updating file #{file}: #{e.message}".red
  false
end

def backup_file(file)
  return false unless File.exist?(file)
  
  backup = "#{file}.bak.#{Time.now.strftime('%Y%m%d%H%M%S')}"
  FileUtils.cp(file, backup)
  check_result("Created backup: #{backup}")
rescue StandardError => e
  puts "Error backing up file #{file}: #{e.message}".red
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

def create_backup_directory
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  backup_dir = File.join(HOME_DIR, "notes_backup_#{timestamp}")
  
  create_directory(backup_dir)
  puts "Created backup directory: #{backup_dir}".green
  
  backup_dir
end

def backup_notes(backup_dir)
  print_header("Backing Up Existing Notes")
  
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
  
  puts "Existing notes configuration backed up to #{backup_dir}".green
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

def create_notes_plugin(file)
  content = <<~NOTES
    " Notes System Plugin for Neovim
    " Author: Joshua Michael Hall
    " Description: A simple notes system for daily, project, and learning notes

    " Configuration
    let g:notes_dir = expand('~/notes')
    let g:notes_daily_dir = g:notes_dir . '/daily'
    let g:notes_projects_dir = g:notes_dir . '/projects'
    let g:notes_learning_dir = g:notes_dir . '/learning'
    let g:notes_templates_dir = g:notes_dir . '/templates'

    " Helper function to ensure directories exist
    function! EnsureDirectoryExists(dir)
      if !isdirectory(a:dir)
        call mkdir(a:dir, 'p')
        return 1
      endif
      return 1
    endfunction

    " Helper function to create a directory and initialize git if needed
    function! InitializeDirectory(dir)
      if EnsureDirectoryExists(a:dir)
        " Check if git is initialized
        let l:git_dir = a:dir . '/.git'
        if !isdirectory(l:git_dir)
          " Initialize git repository
          let l:current_dir = getcwd()
          execute 'cd ' . a:dir
          silent !git init
          silent !git add .
          silent !git commit -m "Initialize notes repository" --allow-empty
          execute 'cd ' . l:current_dir
        endif
        return 1
      endif
      return 0
    endfunction

    " Create a new daily note
    function! CreateDailyNote()
      let l:date = strftime('%Y-%m-%d')
      let l:daily_path = g:notes_daily_dir . '/' . l:date . '.md'
      
      " Ensure daily directory exists
      if !EnsureDirectoryExists(g:notes_daily_dir)
        echo "Failed to create daily notes directory"
        return
      endif
      
      " Edit the file
      execute 'edit ' . l:daily_path
      
      " If file is new, populate with template
      if line(') == 1 && getline(1) == ''
        let l:template_path = g:notes_templates_dir . '/daily.md'
        if filereadable(l:template_path)
          let l:template = readfile(l:template_path)
          call setline(1, l:template)
          " Replace placeholders
          execute '%s/{{date}}/' . l:date . '/g'
        else
          " Create basic structure if template doesn't exist
          call setline(1, '# Daily Note: ' . l:date)
          call append(1, '')
          call append(2, '## Focus Areas')
          call append(3, '- ')
          call append(4, '')
          call append(5, '## Notes')
          call append(6, '- ')
          call append(7, '')
          call append(8, '## Tasks')
          call append(9, '- [ ] ')
          call append(10, '')
          call append(11, '## Progress')
          call append(12, '- ')
          call append(13, '')
          call append(14, '## Links')
          call append(15, '- ')
        endif
      endif
    endfunction

    " Create a new project note
    function! CreateProjectNote()
      let l:project_name = input('Project name: ')
      if l:project_name == ''
        return
      endif
      
      let l:project_dir = g:notes_projects_dir . '/' . l:project_name
      let l:notes_path = l:project_dir . '/notes.md'
      
      " Ensure project directory exists
      if !EnsureDirectoryExists(l:project_dir)
        echo "Failed to create project directory"
        return
      endif
      
      " Edit the file
      execute 'edit ' . l:notes_path
      
      " If file is new, populate with template
      if line(') == 1 && getline(1) == ''
        let l:template_path = g:notes_templates_dir . '/project.md'
        if filereadable(l:template_path)
          let l:template = readfile(l:template_path)
          call setline(1, l:template)
          " Replace placeholders
          execute '%s/{{project_name}}/' . l:project_name . '/g'
        else
          " Create basic structure if template doesn't exist
          call setline(1, '# Project: ' . l:project_name)
          call append(1, '')
          call append(2, '## Overview')
          call append(3, '- **Goal**: ')
          call append(4, '- **Timeline**: ')
          call append(5, '- **Status**: ')
          call append(6, '')
          call append(7, '## Requirements')
          call append(8, '- ')
          call append(9, '')
          call append(10, '## Notes')
          call append(11, '- ')
          call append(12, '')
          call append(13, '## Tasks')
          call append(14, '- [ ] ')
          call append(15, '')
          call append(16, '## Resources')
          call append(17, '- ')
        endif
      endif
    endfunction

    " Create a new learning note
    function! CreateLearningNote()
      let l:topic = input('Topic (e.g., ruby, python): ')
      if l:topic == ''
        return
      endif
      
      let l:subject = input('Subject (e.g., classes, functions): ')
      if l:subject == ''
        return
      endif
      
      let l:topic_dir = g:notes_learning_dir . '/' . l:topic
      let l:notes_path = l:topic_dir . '/' . l:subject . '.md'
      
      " Ensure topic directory exists
      if !EnsureDirectoryExists(l:topic_dir)
        echo "Failed to create topic directory"
        return
      endif
      
      " Edit the file
      execute 'edit ' . l:notes_path
      
      " If file is new, populate with template
      if line(') == 1 && getline(1) == ''
        let l:template_path = g:notes_templates_dir . '/learning.md'
        if filereadable(l:template_path)
          let l:template = readfile(l:template_path)
          call setline(1, l:template)
          " Replace placeholders
          execute '%s/{{topic}}/' . l:topic . ': ' . l:subject . '/g'
        else
          " Create basic structure if template doesn't exist
          call setline(1, '# Learning: ' . l:topic . ': ' . l:subject)
          call append(1, '')
          call append(2, '## Objectives')
          call append(3, '- ')
          call append(4, '')
          call append(5, '## Key Concepts')
          call append(6, '- ')
          call append(7, '')
          call append(8, '## Code Examples')
          call append(9, '```')
          call append(10, '# Code example here')
          call append(11, '```')
          call append(12, '')
          call append(13, '## Resources')
          call append(14, '- ')
          call append(15, '')
          call append(16, '## Questions')
          call append(17, '- ')
          call append(18, '')
          call append(19, '## Practice')
          call append(20, '- ')
        endif
      endif
    endfunction

    " Find notes
    function! NotesFiles()
      execute 'Telescope find_files cwd=' . g:notes_dir
    endfunction

    " Search within notes
    function! NotesGrep()
      execute 'Telescope live_grep cwd=' . g:notes_dir
    endfunction

    " Show recently modified notes
    function! RecentNotes()
      execute 'Telescope find_files cwd=' . g:notes_dir . ' sort=modified'
    endfunction

    " Change to notes directory
    function! NotesDir()
      execute 'cd ' . g:notes_dir
      echo "Changed to notes directory"
    endfunction

    " Open notes directory in file explorer
    function! NotesEdit()
      execute 'edit ' . g:notes_dir
    endfunction

    " Define commands
    command! Daily call CreateDailyNote()
    command! Project call CreateProjectNote()
    command! Learning call CreateLearningNote()
    command! Notes call NotesDir()
    command! NotesEdit call NotesEdit()
    command! NotesFiles call NotesFiles()
    command! NotesGrep call NotesGrep()
    command! RecentNotes call RecentNotes()

    " Initialize notes system
    function! InitializeNotesSystem()
      " Ensure all required directories exist
      call EnsureDirectoryExists(g:notes_dir)
      call EnsureDirectoryExists(g:notes_daily_dir)
      call EnsureDirectoryExists(g:notes_projects_dir)
      call EnsureDirectoryExists(g:notes_learning_dir)
      call EnsureDirectoryExists(g:notes_templates_dir)
      
      " Create initial templates if they don't exist
      let l:daily_template = g:notes_templates_dir . '/daily.md'
      if !filereadable(l:daily_template)
        call writefile([
          \\ '# Daily Note: {{date}}',
          \\ '',
          \\ '## Focus Areas',
          \\ '- ',
          \\ '',
          \\ '## Notes',
          \\ '- ',
          \\ '',
          \\ '## Tasks',
          \\ '- [ ] ',
          \\ '',
          \\ '## Progress',
          \\ '- ',
          \\ '',
          \\ '## Links',
          \\ '- '
          \\ ], l:daily_template)
      endif
      
      let l:project_template = g:notes_templates_dir . '/project.md'
      if !filereadable(l:project_template)
        call writefile([
          \\ '# Project: {{project_name}}',
          \\ '',
          \\ '## Overview',
          \\ '- **Goal**: ',
          \\ '- **Timeline**: ',
          \\ '- **Status**: ',
          \\ '',
          \\ '## Requirements',
          \\ '- ',
          \\ '',
          \\ '## Notes',
          \\ '- ',
          \\ '',
          \\ '## Tasks',
          \\ '- [ ] ',
          \\ '',
          \\ '## Resources',
          \\ '- '
          \\ ], l:project_template)
      endif
      
      let l:learning_template = g:notes_templates_dir . '/learning.md'
      if !filereadable(l:learning_template)
        call writefile([
          \\ '# Learning: {{topic}}',
          \\ '',
          \\ '## Objectives',
          \\ '- ',
          \\ '',
          \\ '## Key Concepts',
          \\ '- ',
          \\ '',
          \\ '## Code Examples',
          \\ '```',
          \\ '# Code example here',
          \\ '```',
          \\ '',
          \\ '## Resources',
          \\ '- ',
          \\ '',
          \\ '## Questions',
          \\ '- ',
          \\ '',
          \\ '## Practice',
          \\ '- '
          \\ ], l:learning_template)
      endif
      
      " Initialize git repository
      call InitializeDirectory(g:notes_dir)
      
      " Create .gitignore to exclude certain files
      let l:gitignore_path = g:notes_dir . '/.gitignore'
      if !filereadable(l:gitignore_path)
        call writefile([
          \\ '# Ignore temporary files',
          \\ '*~',
          \\ '*.swp',
          \\ '*.swo',
          \\ '',
          \\ '# Ignore OS files',
          \\ '.DS_Store',
          \\ 'Thumbs.db',
          \\ '',
          \\ '# Ignore private notes',
          \\ 'private/'
          \\ ], l:gitignore_path)
      endif
      
      " Create README
      let l:readme_path = g:notes_dir . '/README.md'
      if !filereadable(l:readme_path)
        call writefile([
          \\ '# Notes System',
          \\ '',
          \\ 'This directory contains a structured notes system for:',
          \\ '',
          \\ '- **Daily notes**: Daily logs and journals',
          \\ '- **Project notes**: Documentation for specific projects',
          \\ '- **Learning notes**: Study materials organized by topic',
          \\ '',
          \\ '## Usage',
          \\ '',
          \\ 'Use the following commands in Neovim:',
          \\ '',
          \\ '- `:Daily` - Create or edit today\\'s daily note',
          \\ '- `:Project` - Create or edit a project note',
          \\ '- `:Learning` - Create or edit a learning note',
          \\ '- `:NotesFiles` - Find notes files',
          \\ '- `:NotesGrep` - Search within notes',
          \\ '- `:RecentNotes` - Show recently modified notes',
          \\ '',
          \\ 'This notes system is managed by a Neovim plugin and is backed by Git for version control.'
          \\ ], l:readme_path)
      endif
      
      echo "Notes system initialized"
    endfunction

    " Ensure everything is set up on plugin load
    call InitializeNotesSystem()

    " Define mappings (can be customized based on preference)
    nnoremap <leader>fn :NotesFiles<CR>
    nnoremap <leader>fg :NotesGrep<CR>
    nnoremap <leader>fr :RecentNotes<CR>
    nnoremap <leader>fd :Daily<CR>
    nnoremap <leader>fp :Project<CR>
    nnoremap <leader>fl :Learning<CR>
  NOTES
  
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

# Installation functions
def check_neovim
  print_header("Checking Neovim Installation")
  
  if command_exists?('nvim')
    version, _ = run_command('nvim --version')
    puts "Neovim is installed: #{version.split("\n").first}".green
    return true
  else
    puts "Neovim is not installed".red
    puts "Notes plugin requires Neovim to be installed".red
    puts "Please install Neovim before continuing".yellow
    return false
  end
end

def create_notes_structure
  print_header("Creating Notes Directory Structure")
  
  # Create main notes directory
  success = create_directory(NOTES_DIR)
  
  # Create subdirectories
  NOTES_SUBDIRS.each do |name, dir|
    success &= create_directory(dir)
  end
  
  # Create templates
  daily_template = File.join(NOTES_SUBDIRS[:templates], 'daily.md')
  project_template = File.join(NOTES_SUBDIRS[:templates], 'project.md')
  learning_template = File.join(NOTES_SUBDIRS[:templates], 'learning.md')
  
  success &= create_daily_template(daily_template)
  success &= create_project_template(project_template)
  success &= create_learning_template(learning_template)
  
  # Create README
  readme_file = File.join(NOTES_DIR, 'README.md')
  success &= create_readme(readme_file)
  
  # Create .gitignore
  gitignore_file = File.join(NOTES_DIR, '.gitignore')
  success &= create_gitignore(gitignore_file)
  
  # Initialize Git repository
  success &= initialize_git_repository(NOTES_DIR)
  
  success
end

def install_notes_plugin
  print_header("Installing Notes Plugin for Neovim")
  
  # Create Neovim plugin directory if it doesn't exist
  create_directory(NVIM_PLUGIN_DIR)
  
  # Create notes.vim plugin file
  create_notes_plugin(NOTES_PLUGIN_FILE)
end

def check_notes_integration
  print_header("Checking Notes Integration with Neovim")
  
  # Check if init.lua sources notes.vim
  init_file = File.join(NVIM_CONFIG_DIR, 'init.lua')
  
  if File.exist?(init_file)
    init_content = File.read(init_file)
    
    if init_content.include?('notes.vim')
      puts "✓ Neovim init.lua includes notes.vim plugin".green
    else
      puts "✗ Neovim init.lua doesn't include notes.vim plugin".red
      
      if options[:fix]
        puts "Adding notes.vim to init.lua...".blue
        append_to_file(init_file, "\n-- Notes system\nvim.cmd('source ' .. vim.fn.stdpath('config') .. '/plugin/notes.vim')")
      else
        puts "Add the following line to your init.lua:".yellow
        puts "vim.cmd('source ' .. vim.fn.stdpath('config') .. '/plugin/notes.vim')".yellow
      end
    end
  else
    puts "✗ Neovim init.lua doesn't exist".red
    puts "Please set up Neovim configuration first".yellow
  end
end

# Main installation functions
def run_full_install
  print_header("Running Full Notes System Installation")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_notes(backup_dir)
  
  # Check Neovim installation
  success = check_neovim
  
  # Create notes directory structure
  success &&= create_notes_structure
  
  # Install notes plugin for Neovim
  success &&= install_notes_plugin
  
  # Check notes integration with Neovim
  check_notes_integration
  
  # Set version marker
  version_file = File.join(HOME_DIR, '.notes_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}")
  
  success
end

def run_minimal_update
  print_header("Running Minimal Notes System Update")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_notes(backup_dir)
  
  # Create missing directories and files
  success = true
  
  # Create notes directory if it doesn't exist
  success &= create_directory(NOTES_DIR) unless Dir.exist?(NOTES_DIR)
  
  # Create subdirectories if they don't exist
  NOTES_SUBDIRS.each do |name, dir|
    success &= create_directory(dir) unless Dir.exist?(dir)
  end
  
  # Create templates if they don't exist
  daily_template = File.join(NOTES_SUBDIRS[:templates], 'daily.md')
  project_template = File.join(NOTES_SUBDIRS[:templates], 'project.md')
  learning_template = File.join(NOTES_SUBDIRS[:templates], 'learning.md')
  
  success &= create_daily_template(daily_template) unless File.exist?(daily_template)
  success &= create_project_template(project_template) unless File.exist?(project_template)
  success &= create_learning_template(learning_template) unless File.exist?(learning_template)
  
  # Create README if it doesn't exist
  readme_file = File.join(NOTES_DIR, 'README.md')
  success &= create_readme(readme_file) unless File.exist?(readme_file)
  
  # Create .gitignore if it doesn't exist
  gitignore_file = File.join(NOTES_DIR, '.gitignore')
  success &= create_gitignore(gitignore_file) unless File.exist?(gitignore_file)
  
  # Initialize Git repository if it doesn't exist
  success &= initialize_git_repository(NOTES_DIR) unless Dir.exist?(File.join(NOTES_DIR, '.git'))
  
  # Create notes plugin file if it doesn't exist
  if Dir.exist?(NVIM_PLUGIN_DIR) && !File.exist?(NOTES_PLUGIN_FILE)
    success &= create_notes_plugin(NOTES_PLUGIN_FILE)
  end
  
  # Update version marker
  version_file = File.join(HOME_DIR, '.notes_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}\nmode=minimal")
  
  success
end

def run_fix_mode
  print_header("Running Fix Mode for Notes System")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_notes(backup_dir)
  
  # Fix notes directory structure
  success = true
  
  # Create notes directory if it doesn't exist
  success &= create_directory(NOTES_DIR) unless Dir.exist?(NOTES_DIR)
  
  # Create subdirectories if they don't exist
  NOTES_SUBDIRS.each do |name, dir|
    success &= create_directory(dir) unless Dir.exist?(dir)
  end
  
  # Create templates if they don't exist
  daily_template = File.join(NOTES_SUBDIRS[:templates], 'daily.md')
  project_template = File.join(NOTES_SUBDIRS[:templates], 'project.md')
  learning_template = File.join(NOTES_SUBDIRS[:templates], 'learning.md')
  
  success &= create_daily_template(daily_template) unless File.exist?(daily_template)
  success &= create_project_template(project_template) unless File.exist?(project_template)
  success &= create_learning_template(learning_template) unless File.exist?(learning_template)
  
  # Create README if it doesn't exist
  readme_file = File.join(NOTES_DIR, 'README.md')
  success &= create_readme(readme_file) unless File.exist?(readme_file)
  
  # Create .gitignore if it doesn't exist
  gitignore_file = File.join(NOTES_DIR, '.gitignore')
  success &= create_gitignore(gitignore_file) unless File.exist?(gitignore_file)
  
  # Initialize Git repository if it doesn't exist
  success &= initialize_git_repository(NOTES_DIR) unless Dir.exist?(File.join(NOTES_DIR, '.git'))
  
  # Create Neovim plugin directory if it doesn't exist
  success &= create_directory(NVIM_PLUGIN_DIR) unless Dir.exist?(NVIM_PLUGIN_DIR)
  
  # Create notes plugin file
  if !File.exist?(NOTES_PLUGIN_FILE) || options[:fix]
    backup_file(NOTES_PLUGIN_FILE) if File.exist?(NOTES_PLUGIN_FILE)
    success &= create_notes_plugin(NOTES_PLUGIN_FILE)
  end
  
  # Check notes integration with Neovim
  check_notes_integration
  
  success
end

# Main entry point
def main
  print_header("Notes System Installer v#{VERSION}")
  
  if options[:fix]
    success = run_fix_mode
  elsif options[:minimal]
    success = run_minimal_update
  else
    success = run_full_install
  end
  
  if success
    print_header("Notes System Installation Completed Successfully")
    puts "Your notes system is now set up.".green
    puts "\nNext steps:".blue
    puts "1. Start Neovim with 'nvim'"
    puts "2. Create a daily note with :Daily"
    puts "3. Create a project note with :Project"
    puts "4. Create a learning note with :Learning"
    puts "5. Search notes with :NotesFiles or :NotesGrep"
  else
    print_header("Installation Completed with Errors")
    puts "Some components may not have installed correctly.".red
    puts "Please check the error messages above.".yellow
  end
  
  return success ? 0 : 1
end

# Run the script
exit main