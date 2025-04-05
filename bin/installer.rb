#!/usr/bin/env ruby
# Terminal Environment Installer
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'
require 'open3'
require 'date'

# Color definitions
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

# Main installer function
def main
  print_header("Terminal Environment Installer")
  
  puts "This script will install and configure a terminal-based development environment."
  puts "Components to be installed:"
  puts "  1. Zsh with Oh My Zsh and Powerlevel10k"
  puts "  2. Neovim with plugins for development"
  puts "  3. tmux with custom configuration"
  puts "  4. Notes system for organizing information"
  puts "  5. Various utilities and tools"
  puts ""
  
  # Determine installation mode
  puts "Available installation modes:"
  puts "  1. Full installation (install all tools and configurations)"
  puts "  2. Minimal update (update configurations without reinstalling tools)"
  puts "  3. Permissions fix only (fix file permissions issues)"
  puts "  4. Uninstall (remove configurations and optionally tools)"
  puts ""
  
  print "Select installation mode (1-4, default: 1): "
  mode = gets.chomp.to_i
  mode = FULL_INSTALL if mode <= 0 || mode > 4
  
  case mode
  when FULL_INSTALL
    puts "Running full installation...".blue
    
    # Create backup
    backup_dir = create_backup_directory
    backup_existing_configs(backup_dir)
    
    # Install tools
    install_homebrew
    install_required_tools
    install_fonts
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    install_tmux_plugin_manager
    install_rectangle
  CONFIG_DIRS.each { |name, dir| create_directory(dir) }
  TEMPLATE_DIRS.each { |name, dir| create_directory(dir) }
  create_zshrc(CONFIG_FILES[:zshrc])
  create_tmux_conf(CONFIG_FILES[:tmux_conf])
  create_p10k_conf(CONFIG_FILES[:p10k])
  create_nvim_init(CONFIG_FILES[:nvim_init])
  create_directory(File.join(CONFIG_DIRS[:nvim], 'lua'))
  create_directory(File.join(CONFIG_DIRS[:nvim], 'plugin'))
  create_nvim_plugins(CONFIG_FILES[:nvim_plugins])
  create_notes_vim(CONFIG_FILES[:notes_vim])
  version_file = File.join(HOME_DIR, '.terminal_env_version')
  File.write(version_file, "version=0.1.0\ndate=#{Time.now.strftime('%Y-%m-%d')}\nmode=full")
  puts "\nFull installation completed successfully!".green
  puts "\nNext steps:"
  puts "1. Restart your terminal"
  puts "2. Run 'p10k configure' to customize your prompt"
  puts "3. Start using your new environment with 'wk dev' or 'wk notes'"

when MINIMAL_UPDATE
  puts "Running minimal update...".blue
  backup_dir = create_backup_directory
  backup_existing_configs(backup_dir)
  CONFIG_DIRS.each { |name, dir| create_directory(dir) }
  TEMPLATE_DIRS.each { |name, dir| create_directory(dir) }
  create_directory(File.join(CONFIG_DIRS[:nvim], 'lua'))
  create_directory(File.join(CONFIG_DIRS[:nvim], 'plugin'))
  create_nvim_plugins(CONFIG_FILES[:nvim_plugins])
  create_notes_vim(CONFIG_FILES[:notes_vim])
  create_tmux_conf(CONFIG_FILES[:tmux_conf])
  version_file = File.join(HOME_DIR, '.terminal_env_version')
  File.write(version_file, "version=0.1.0\ndate=#{Time.now.strftime('%Y-%m-%d')}\nmode=minimal")
  puts "\nMinimal update completed successfully!".green
  puts "\nNext steps:"
  puts "1. Restart your terminal"
  puts "2. Start using your updated environment with 'wk dev' or 'wk notes'"

when PERMISSIONS_FIX
  puts "Running permissions fix...".blue
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      FileUtils.chmod_R(0755, dir)
      puts "Fixed permissions for #{dir}".green
    end
  end
  CONFIG_FILES.each do |name, file|
    if File.exist?(file)
      FileUtils.chmod(0644, file)
      puts "Fixed permissions for #{file}".green
    end
  end
  puts "\nPermissions fix completed successfully!".green

when UNINSTALL
  puts "Uninstall mode selected. This will remove the terminal environment configurations.".yellow
  puts "Your personal data and notes will be preserved, but configurations will be removed.".yellow
  puts "Proceeding with non-interactive uninstall..."
  
  backup_dir = create_backup_directory
  backup_existing_configs(backup_dir)
  
  if Dir.exist?(CONFIG_DIRS[:nvim])
    FileUtils.rm_rf(CONFIG_DIRS[:nvim])
    puts "Removed Neovim configuration directory".green
  end
  
  if File.exist?(CONFIG_FILES[:tmux_conf])
    FileUtils.rm(CONFIG_FILES[:tmux_conf])
    puts "Removed tmux configuration file".green
  end
  
  if File.exist?(CONFIG_FILES[:zshrc])
    FileUtils.cp(CONFIG_FILES[:zshrc], "#{CONFIG_FILES[:zshrc]}.bak")
    zshrc_content = File.read(CONFIG_FILES[:zshrc])
    zshrc_content.gsub!(/# ============ Aliases ============.*?# ============/m, '# ============')
    zshrc_content.gsub!(/# ============ Functions ============.*?# ============/m, '# ============')
    zshrc_content.gsub!(/# Terminal Development Environment.*?\n/m, '')
    File.write(CONFIG_FILES[:zshrc], zshrc_content)
    puts "Cleaned up Zsh configuration file".green
  end
  
  version_file = File.join(HOME_DIR, '.terminal_env_version')
  if File.exist?(version_file)
    FileUtils.rm(version_file)
    puts "Removed version file".green
  end
  
  puts "\nUninstall completed successfully!".green
  puts "Your configurations have been backed up to: #{backup_dir}".green
  puts "Note: Your notes and data in ~/notes are preserved.".blue
end
    
    # Create directories
    CONFIG_DIRS.each do |name, dir|
      create_directory(dir)
    end
    
    TEMPLATE_DIRS.each do |name, dir|
      create_directory(dir)
    end
    
    # Create config files
    create_zshrc(CONFIG_FILES[:zshrc])
    create_tmux_conf(CONFIG_FILES[:tmux_conf])
    create_p10k_conf(CONFIG_FILES[:p10k])
    create_nvim_init(CONFIG_FILES[:nvim_init])
    
    # Create lua directory for Neovim
    create_directory(File.join(CONFIG_DIRS[:nvim], 'lua'))
    create_directory(File.join(CONFIG_DIRS[:nvim], 'plugin'))
    
    # Create Neovim plugin configuration
    create_nvim_plugins(CONFIG_FILES[:nvim_plugins])
    create_notes_vim(CONFIG_FILES[:notes_vim])
    
    # Set version file
    version_file = File.join(HOME_DIR, '.terminal_env_version')
    File.write(version_file, "version=0.1.0\\ndate=#{Time.now.strftime('%Y-%m-%d')}\\nmode=full")
    
    puts "\\nFull installation completed successfully!".green
    puts "\\nNext steps:"
    puts "1. Restart your terminal"
    puts "2. Run 'p10k configure' to customize your prompt"
    puts "3. Start using your new environment with 'wk dev' or 'wk notes'"
    
  when MINIMAL_UPDATE
    puts "Running minimal update...".blue
    
    # Create backup
    backup_dir = create_backup_directory
    backup_existing_configs(backup_dir)
    
    # Create directories
    CONFIG_DIRS.each do |name, dir|
      create_directory(dir)
    end
    
    TEMPLATE_DIRS.each do |name, dir|
      create_directory(dir)
    end
    
    # Update Neovim configuration
    create_directory(File.join(CONFIG_DIRS[:nvim], 'lua'))
    create_directory(File.join(CONFIG_DIRS[:nvim], 'plugin'))
    create_nvim_plugins(CONFIG_FILES[:nvim_plugins])
    create_notes_vim(CONFIG_FILES[:notes_vim])
    
    # Update tmux configuration
    create_tmux_conf(CONFIG_FILES[:tmux_conf])
    
    # Set version file
    version_file = File.join(HOME_DIR, '.terminal_env_version')
    File.write(version_file, "version=0.1.0\\ndate=#{Time.now.strftime('%Y-%m-%d')}\\nmode=minimal")
    
    puts "\\nMinimal update completed successfully!".green
    puts "\\nNext steps:"
    puts "1. Restart your terminal"
    puts "2. Start using your updated environment with 'wk dev' or 'wk notes'"
    
  when PERMISSIONS_FIX
    puts "Running permissions fix...".blue
    
    # Fix permissions for config directories
    CONFIG_DIRS.each do |name, dir|
      if Dir.exist?(dir)
        FileUtils.chmod_R(0755, dir)
        puts "Fixed permissions for #{dir}".green
      end
    end
    
    # Fix permissions for config files
    CONFIG_FILES.each do |name, file|
      if File.exist?(file)
        FileUtils.chmod(0644, file)
        puts "Fixed permissions for #{file}".green
      end
    end
    
    puts "\\nPermissions fix completed successfully!".green
    
  when UNINSTALL
    puts "Uninstall mode selected. This will remove the terminal environment configurations.".yellow
    puts "Your personal data and notes will be preserved, but configurations will be removed.".yellow
    print "Are you sure you want to proceed? (y/n): "
    confirm = gets.chomp.downcase
    
    if confirm == 'y' || confirm == 'yes'
      puts "Running uninstall...".blue
      
      # Create backup
      backup_dir = create_backup_directory
      backup_existing_configs(backup_dir)
      
      # Remove Neovim config
      if Dir.exist?(CONFIG_DIRS[:nvim])
        FileUtils.rm_rf(CONFIG_DIRS[:nvim])
        puts "Removed Neovim configuration directory".green
      end
      
      # Remove tmux config
      if File.exist?(CONFIG_FILES[:tmux_conf])
        FileUtils.rm(CONFIG_FILES[:tmux_conf])
        puts "Removed tmux configuration file".green
      end
      
      # Clean up Zsh configuration
      if File.exist?(CONFIG_FILES[:zshrc])
        # Create a backup of existing .zshrc
        FileUtils.cp(CONFIG_FILES[:zshrc], "#{CONFIG_FILES[:zshrc]}.bak")
        
        # Create a new .zshrc without our custom configurations
        zshrc_content = File.read(CONFIG_FILES[:zshrc])
        
        # Remove our custom sections
        zshrc_content.gsub!(/# ============ Aliases ============.*?# ============/m, '# ============')
        zshrc_content.gsub!(/# ============ Functions ============.*?# ============/m, '# ============')
        zshrc_content.gsub!(/# Terminal Development Environment.*?\\n/m, '')
        
        # Write cleaned file
        File.write(CONFIG_FILES[:zshrc], zshrc_content)
        puts "Cleaned up Zsh configuration file".green
      end
      
      # Remove version file
      version_file = File.join(HOME_DIR, '.terminal_env_version')
      if File.exist?(version_file)
        FileUtils.rm(version_file)
        puts "Removed version file".green
      end
      
      puts "\\nUninstall completed successfully!".green
      puts "Your configurations have been backed up to: #{backup_dir}".green
      puts "Note: Your notes and data in ~/notes are preserved.".blue
    else
      puts "Uninstall cancelled.".blue
    end
  end
end

# Parse command line arguments
if ARGV.include?('--help') || ARGV.include?('-h')
  puts "Terminal Environment Installer"
  puts "Usage: ruby installer.rb [options]"
  puts ""
  puts "Options:"
  puts "  --full       Run full installation (default)"
  puts "  --minimal    Run minimal update"
  puts "  --fix        Fix permissions only"
  puts "  --uninstall  Remove configurations"
  puts "  --help, -h   Show this help message"
  exit
elsif ARGV.include?('--full')
  mode = FULL_INSTALL
elsif ARGV.include?('--minimal')
  mode = MINIMAL_UPDATE
elsif ARGV.include?('--fix')
  mode = PERMISSIONS_FIX
elsif ARGV.include?('--uninstall')
  mode = UNINSTALL
else
  # If no arguments provided, execute interactive main function
  main
  exit
end

# Execute non-interactive mode if arguments were provided
print_header("Terminal Environment Installer (Non-Interactive Mode)")

case mode
when FULL_INSTALL
  puts "Running full installation...".blue
  backup_dir = create_backup_directory
  backup_existing_configs(backup_dir)
  install_homebrew
  install_required_tools
  install_fonts
  install_oh_my_zsh
  install_powerlevel10k
  install_zsh_plugins
  install_tmux_plugin_manager
  install_rectangle
  

def create_notes_vim(file)
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
      if line('

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
INSTALL_DIR = File.join(HOME_DIR, '.terminal-env')
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

TEMPLATE_DIRS = {
  notes_daily: File.join(CONFIG_DIRS[:notes], 'daily'),
  notes_projects: File.join(CONFIG_DIRS[:notes], 'projects'),
  notes_learning: File.join(CONFIG_DIRS[:notes], 'learning'),
  notes_templates: File.join(CONFIG_DIRS[:notes], 'templates')
}

REQUIRED_TOOLS = {
  'zsh' => 'brew install zsh',
  'nvim' => 'brew install neovim',
  'tmux' => 'brew install tmux',
  'git' => 'brew install git',
  'watchman' => 'brew install watchman',
  'fzf' => 'brew install fzf'
}

# Installation modes
FULL_INSTALL = 1
MINIMAL_UPDATE = 2
PERMISSIONS_FIX = 3
UNINSTALL = 4

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

def add_line_if_not_exists(file, line)
  return false unless File.exist?(file)
  return true if file_contains?(file, Regexp.escape(line))
  
  append_to_file(file, line)
end

def check_and_add_alias(file, alias_name, command)
  pattern = "alias\\s+#{alias_name}\\s*="
  
  if !file_contains?(file, pattern)
    append_to_file(file, "\n# Added by installer script\nalias #{alias_name}='#{command}'")
    puts "Added alias #{alias_name} to #{file}".green
    return true
  end
  
  puts "Alias #{alias_name} already exists in #{file}".green
  true
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
  backup_dir = File.join(HOME_DIR, "terminal_env_backup_#{timestamp}")
  
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
  
  # Backup notes templates if they exist
  if Dir.exist?(File.join(CONFIG_DIRS[:notes], 'templates'))
    templates_backup = File.join(backup_dir, 'notes_templates')
    FileUtils.mkdir_p(templates_backup)
    FileUtils.cp_r(Dir.glob(File.join(CONFIG_DIRS[:notes], 'templates', '*')), templates_backup)
    puts "Backed up notes templates to #{templates_backup}".green
  end
  
  puts "All existing configurations backed up to #{backup_dir}".green
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
      if !file_contains?(CONFIG_FILES[:zshrc], 'eval.*brew shellenv')
        add_line_if_not_exists(CONFIG_FILES[:zshrc], 'eval "$(/opt/homebrew/bin/brew shellenv)"')
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
  
  success = true
  REQUIRED_TOOLS.each do |tool, install_cmd|
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

def install_oh_my_zsh
  print_header("Installing Oh My Zsh")
  
  if Dir.exist?(File.join(HOME_DIR, '.oh-my-zsh'))
    puts "Oh My Zsh is already installed".green
    return true
  end
  
  puts "Installing Oh My Zsh...".blue
  install_cmd = 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
  output, success = run_command(install_cmd)
  
  if success
    puts "Oh My Zsh installed successfully".green
    return true
  else
    puts "Failed to install Oh My Zsh".red
    puts "Please install Oh My Zsh manually".yellow
    return false
  end
end

def install_powerlevel10k
  print_header("Installing Powerlevel10k")
  
  p10k_theme_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/themes/powerlevel10k')
  
  if Dir.exist?(p10k_theme_dir)
    puts "Powerlevel10k theme is already installed, updating...".yellow
    Dir.chdir(p10k_theme_dir) do
      run_command('git pull')
    end
    check_result("Updated Powerlevel10k theme")
    return true
  end
  
  puts "Installing Powerlevel10k theme...".blue
  install_cmd = "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git #{p10k_theme_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "Powerlevel10k theme installed successfully".green
    return true
  else
    puts "Failed to install Powerlevel10k theme".red
    puts "Please install Powerlevel10k theme manually".yellow
    return false
  end
end

def install_zsh_plugins
  print_header("Installing Zsh Plugins")
  
  custom_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/plugins')
  
  # Install zsh-autosuggestions
  autosuggestions_dir = File.join(custom_dir, 'zsh-autosuggestions')
  if Dir.exist?(autosuggestions_dir)
    puts "zsh-autosuggestions is already installed, updating...".yellow
    Dir.chdir(autosuggestions_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-autosuggestions")
  else
    puts "Installing zsh-autosuggestions...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-autosuggestions #{autosuggestions_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-autosuggestions", success)
  end
  
  # Install zsh-syntax-highlighting
  syntax_highlighting_dir = File.join(custom_dir, 'zsh-syntax-highlighting')
  if Dir.exist?(syntax_highlighting_dir)
    puts "zsh-syntax-highlighting is already installed, updating...".yellow
    Dir.chdir(syntax_highlighting_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-syntax-highlighting")
  else
    puts "Installing zsh-syntax-highlighting...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git #{syntax_highlighting_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-syntax-highlighting", success)
  end
  
  true
end

def install_tmux_plugin_manager
  print_header("Installing tmux Plugin Manager")
  
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  
  if Dir.exist?(tpm_dir)
    puts "tmux plugin manager is already installed, updating...".yellow
    Dir.chdir(tpm_dir) do
      run_command('git pull')
    end
    check_result("Updated tmux plugin manager")
    return true
  end
  
  puts "Installing tmux plugin manager...".blue
  create_directory(File.join(CONFIG_DIRS[:tmux], 'plugins'))
  install_cmd = "git clone https://github.com/tmux-plugins/tpm #{tpm_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "tmux plugin manager installed successfully".green
    return true
  else
    puts "Failed to install tmux plugin manager".red
    puts "Please install tmux plugin manager manually".yellow
    return false
  end
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

def create_zshrc(file)
  content = <<~ZSH
    # ZSH Configuration created by terminal-installer script

    # Enable Powerlevel10k instant prompt
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    # Path to Oh My Zsh installation
    export ZSH="$HOME/.oh-my-zsh"

    # Theme
    ZSH_THEME="powerlevel10k/powerlevel10k"

    # Plugins
    plugins=(
      git
      ruby
      python
      node
      macos
      tmux
      zsh-autosuggestions
      zsh-syntax-highlighting
    )

    source $ZSH/oh-my-zsh.sh

    # ============ Aliases ============
    # Git aliases
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit -m"
    alias gp="git push"
    alias gl="git pull"

    # Navigation aliases
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # Directory listing aliases
    alias ll="ls -la"
    alias la="ls -a"

    # Neovim alias
    alias v="nvim"
    alias vi="nvim"
    alias vim="nvim"

    # Tmux aliases
    alias ta="tmux attach -t"
    alias tls="tmux list-sessions"
    alias tn="tmux new -s"
    alias tk="tmux kill-session -t"

    # Development workflow aliases
    alias dev="tmux attach -t dev || tmux new -s dev"
    alias notes="tmux attach -t notes || tmux new -s notes"

    # ============ Functions ============
    # Create and change to directory in one command
    mcd() {
      mkdir -p "$1" && cd "$1"
    }

    # Find and open file with Neovim
    nvimf() {
      local file
      file=$(find . -name "*$1*" | fzf)
      if [[ -n "$file" ]]; then
        nvim "$file"
      fi
    }

    # Check if functions are properly loaded
    check-functions() {
      echo "Testing key functions..."
      declare -f mcd > /dev/null && echo "✓ mcd (make directory and cd) function is available" || echo "✗ mcd function is not available"
      declare -f nvimf > /dev/null && echo "✓ nvimf (find and edit with neovim) function is available" || echo "✗ nvimf function is not available"
      declare -f wk > /dev/null && echo "✓ wk (session manager) function is available" || echo "✗ wk function is not available"
    }

    # Unified session manager for both dev and notes
    wk() {
      local session=$1
      
      case "$session" in
        dev)
          if ! tmux has-session -t dev 2>/dev/null; then
            # Create development session with windows for code, server, and git
            tmux new-session -d -s dev -n code
            tmux new-window -t dev:1 -n server
            tmux new-window -t dev:2 -n git
            tmux select-window -t dev:0
          fi
          tmux attach -t dev
          ;;
        notes)
          if ! tmux has-session -t notes 2>/dev/null; then
            # Create notes session with windows for main, daily, projects, and learning
            tmux new-session -d -s notes -n main -c ~/notes
            tmux new-window -t notes:1 -n daily -c ~/notes/daily
            tmux new-window -t notes:2 -n projects -c ~/notes/projects
            tmux new-window -t notes:3 -n learning -c ~/notes/learning
            tmux select-window -t notes:0
          fi
          tmux attach -t notes
          ;;
        *)
          echo "Usage: wk [dev|notes]"
          echo "  dev   - Start or resume development session"
          echo "  notes - Start or resume notes session"
          ;;
      esac
    }

    # ============ Zsh-specific settings ============
    setopt AUTO_PUSHD        # Push directories onto the directory stack
    setopt PUSHD_IGNORE_DUPS # Do not push duplicates
    setopt PUSHD_SILENT      # Do not print the directory stack after pushd/popd
    setopt EXTENDED_GLOB     # Use extended globbing
    setopt AUTO_CD           # Type directory name to cd

    # fzf configuration
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git || find . -type f -not -path '*/\.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

    # Add ~/bin to PATH
    export PATH="$HOME/bin:$PATH"

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  ZSH
  
  create_file(file, content)
end

def create_tmux_conf(file)
  content = <<~TMUX
    # Terminal Development Environment tmux Configuration

    # Remap prefix from 'C-b' to 'C-a'
    unbind C-b
    set-option -g prefix C-a
    bind-key C-a send-prefix

    # Split panes using | and -
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %

    # Reload config file
    bind r source-file ~/.tmux.conf \\; display "Config reloaded!"

    # Switch panes using Alt-arrow without prefix
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Enable mouse control
    set -g mouse on

    # Don't rename windows automatically
    set-option -g allow-rename off

    # Improve colors
    set -g default-terminal "screen-256color"
    set -ga terminal-overrides ",xterm-256color:Tc"

    # Start window numbering at 1
    set -g base-index 1
    setw -g pane-base-index 1

    # Increase scrollback buffer size
    set -g history-limit 10000

    # Display tmux messages for 4 seconds
    set -g display-time 4000

    # Vim-like copy mode
    setw -g mode-keys vi
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # Status bar
    set -g status-style bg=default
    set -g status-left-length 40
    set -g status-right-length 60
    set -g status-position bottom
    set -g status-left '#[fg=green]#S #[fg=black]• #[fg=green,bright]#(whoami)#[fg=black] • #[fg=green]#h '
    set -g status-right '#[fg=white,bg=default]%a %H:%M #[fg=white,bg=default]%Y-%m-%d '

    # List of plugins
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'tmux-plugins/tmux-resurrect'
    set -g @plugin 'tmux-plugins/tmux-continuum'
    set -g @plugin 'tmux-plugins/tmux-yank'

    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    run '~/.tmux/plugins/tpm/tpm'
  TMUX
  
  create_file(file, content)
end

def create_p10k_conf(file)
  content = <<~P10K
    # Generated by terminal-installer
    # Config file for Powerlevel10k with minimal settings.
    # Wizard for this theme can be run by `p10k configure`.

    # Temporarily change options.
    'builtin' 'local' '-a' 'p10k_config_opts'
    [[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
    [[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
    [[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
    'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

    () {
      emulate -L zsh -o extended_glob

      # Unset all configuration options.
      unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

      # Zsh >= 5.1.1 is required.
      [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

      # Left prompt segments.
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        dir                       # current directory
        vcs                       # git status
        prompt_char               # prompt symbol
      )

      # Right prompt segments.
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status                    # exit code of the last command
        command_execution_time    # duration of the last command
        background_jobs           # presence of background jobs
        virtualenv                # python virtual environment
        time                      # current time
      )

      # Basic style options
      typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
      typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''
      
      # Install gitstatus plugin
      source ${0:A:h}/gitstatus/gitstatus.plugin.zsh || source /usr/local/opt/powerlevel10k/gitstatus/gitstatus.plugin.zsh || return
    }

    (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
    'builtin' 'unset' 'p10k_config_opts'
  P10K
  
  create_file(file, content)
end

def create_nvim_init(file)
  content = <<~INIT
    -- Terminal Development Environment Neovim Configuration

    -- Initialize Lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- ============ Basic settings ============
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.smartindent = true
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undodir = vim.fn.expand('~/.vim/undodir')
    vim.opt.undofile = true
    vim.opt.hlsearch = false
    vim.opt.incsearch = true
    vim.opt.termguicolors = true
    vim.opt.scrolloff = 8
    vim.opt.updatetime = 50
    vim.opt.colorcolumn = "80"
    vim.g.mapleader = " " -- Space as leader key

    -- ============ Key mappings ============
    -- Better window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h')
    vim.keymap.set('n', '<C-j>', '<C-w>j')
    vim.keymap.set('n', '<C-k>', '<C-w>k')
    vim.keymap.set('n', '<C-l>', '<C-w>l')

    -- Basic utilities
    vim.keymap.set('n', '<leader>w', ':w<CR>')   -- Save
    vim.keymap.set('n', '<leader>q', ':q<CR>')   -- Quit
    vim.keymap.set('n', '<leader>h', ':nohl<CR>') -- Clear search highlighting

    -- Help keymap for showing common mappings
    vim.keymap.set('n', '<leader>?', function()
      print("Common mappings:")
      print("  <leader>e  - Toggle file explorer")
      print("  <leader>ff - Find files")
      print("  <leader>fg - Live grep")
      print("  <leader>fb - Browse buffers")
      print("  <leader>w  - Save file")
      print("  <leader>q  - Quit")
      print("  gd         - Go to definition")
      print("  K          - Show documentation")
    end, { noremap = true, silent = true })

    -- ============ Load plugins ============
    require("lazy").setup("plugins")

    -- ============ LSP Server Naming Guide ============
    -- When configuring Mason LSP, use these server names:
    -- Ruby: ruby_ls
    -- TypeScript: tsserver
    -- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
  INIT
  
  create_file(file, content)
end

def create_nvim_plugins(file)
  content = <<~PLUGINS
    return {
      -- Colorscheme
      {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
          vim.cmd.colorscheme "tokyonight"
        end,
      },
      
      -- Status line
      {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
          require('lualine').setup()
        end,
      },
      
      -- File explorer
      {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          require("nvim-tree").setup {}
          vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
        end,
      },
      
      -- Fuzzy finder
      {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files)
          vim.keymap.set('n', '<leader>fg', builtin.live_grep)
          vim.keymap.set('n', '<leader>fb', builtin.buffers)
          vim.keymap.set('n', '<leader>fh', builtin.help_tags)
        end,
      },
      
      -- LSP configuration
      {
        'neovim/nvim-lspconfig',
        dependencies = {
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',
        },
        config = function()
          require('mason').setup()
          require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'ruby_ls', 'pyright', 'tsserver' }
          })
          
          local lspconfig = require('lspconfig')
          
          -- Configure language servers
          lspconfig.lua_ls.setup{}      -- Lua language server
          lspconfig.ruby_ls.setup{}     -- Ruby language server
          lspconfig.pyright.setup{}     -- Python language server
          lspconfig.tsserver.setup{}    -- TypeScript/JavaScript language server
          
          -- Global LSP mappings
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          
          -- Check for format function (handles version differences)
          if vim.lsp.buf.format then
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
          else
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting)
          end
        end,
      },
      
      -- Treesitter
      {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
          require('nvim-treesitter.configs').setup {
            ensure_installed = { "lua", "ruby", "python", "javascript", "typescript", "markdown" },
            highlight = {
              enable = true,
            },
          }
        end,
      },
      
      -- Git integration
      {
        'tpope/vim-fugitive',
        config = function()
          vim.keymap.set('n', '<leader>gs', ':Git<CR>')
          vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
          vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
        end,
      },
      
      -- Auto-completion
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-path',
          'L3MON4D3/LuaSnip',
          'saadparwaiz1/cmp_luasnip',
        },
        config = function()
          local cmp = require('cmp')
          local luasnip = require('luasnip')
          
          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              { name = 'buffer' },
              { name = 'path' }
            }),
          }
        end,
      },
      
      -- Commenting
      {
        'numToStr/Comment.nvim',
        config = function()
          require('Comment').setup()
        end,
      },
      
      -- Markdown preview
      {
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        build = function()
          vim.fn['mkdp#util#install']()
        end,
      },
      
      -- Autopairs
      {
        'windwp/nvim-autopairs',
        config = function()
          require('nvim-autopairs').setup()
        end,
      },
      
      -- Indentation guides
      {
        'lukas-reineke/indent-blankline.nvim',
        main = "ibl",
        config = function()
          require('ibl').setup()
        end,
      },
      
      -- Notes system support (optional plugins for notes)
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable('make') == 1,
        config = function()
          require('telescope').load_extension('fzf')
        end,
      },
      
      -- Which-key for showing key mappings
      {
        'folke/which-key.nvim',
        config = function()
          require('which-key').setup()
        end,
      },
    }
  PLUGINS
  
  create_file(file, content)
end) == 1 && getline(1) == ''
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
      if line('

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
INSTALL_DIR = File.join(HOME_DIR, '.terminal-env')
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

TEMPLATE_DIRS = {
  notes_daily: File.join(CONFIG_DIRS[:notes], 'daily'),
  notes_projects: File.join(CONFIG_DIRS[:notes], 'projects'),
  notes_learning: File.join(CONFIG_DIRS[:notes], 'learning'),
  notes_templates: File.join(CONFIG_DIRS[:notes], 'templates')
}

REQUIRED_TOOLS = {
  'zsh' => 'brew install zsh',
  'nvim' => 'brew install neovim',
  'tmux' => 'brew install tmux',
  'git' => 'brew install git',
  'watchman' => 'brew install watchman',
  'fzf' => 'brew install fzf'
}

# Installation modes
FULL_INSTALL = 1
MINIMAL_UPDATE = 2
PERMISSIONS_FIX = 3
UNINSTALL = 4

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

def add_line_if_not_exists(file, line)
  return false unless File.exist?(file)
  return true if file_contains?(file, Regexp.escape(line))
  
  append_to_file(file, line)
end

def check_and_add_alias(file, alias_name, command)
  pattern = "alias\\s+#{alias_name}\\s*="
  
  if !file_contains?(file, pattern)
    append_to_file(file, "\n# Added by installer script\nalias #{alias_name}='#{command}'")
    puts "Added alias #{alias_name} to #{file}".green
    return true
  end
  
  puts "Alias #{alias_name} already exists in #{file}".green
  true
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
  backup_dir = File.join(HOME_DIR, "terminal_env_backup_#{timestamp}")
  
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
  
  # Backup notes templates if they exist
  if Dir.exist?(File.join(CONFIG_DIRS[:notes], 'templates'))
    templates_backup = File.join(backup_dir, 'notes_templates')
    FileUtils.mkdir_p(templates_backup)
    FileUtils.cp_r(Dir.glob(File.join(CONFIG_DIRS[:notes], 'templates', '*')), templates_backup)
    puts "Backed up notes templates to #{templates_backup}".green
  end
  
  puts "All existing configurations backed up to #{backup_dir}".green
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
      if !file_contains?(CONFIG_FILES[:zshrc], 'eval.*brew shellenv')
        add_line_if_not_exists(CONFIG_FILES[:zshrc], 'eval "$(/opt/homebrew/bin/brew shellenv)"')
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
  
  success = true
  REQUIRED_TOOLS.each do |tool, install_cmd|
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

def install_oh_my_zsh
  print_header("Installing Oh My Zsh")
  
  if Dir.exist?(File.join(HOME_DIR, '.oh-my-zsh'))
    puts "Oh My Zsh is already installed".green
    return true
  end
  
  puts "Installing Oh My Zsh...".blue
  install_cmd = 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
  output, success = run_command(install_cmd)
  
  if success
    puts "Oh My Zsh installed successfully".green
    return true
  else
    puts "Failed to install Oh My Zsh".red
    puts "Please install Oh My Zsh manually".yellow
    return false
  end
end

def install_powerlevel10k
  print_header("Installing Powerlevel10k")
  
  p10k_theme_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/themes/powerlevel10k')
  
  if Dir.exist?(p10k_theme_dir)
    puts "Powerlevel10k theme is already installed, updating...".yellow
    Dir.chdir(p10k_theme_dir) do
      run_command('git pull')
    end
    check_result("Updated Powerlevel10k theme")
    return true
  end
  
  puts "Installing Powerlevel10k theme...".blue
  install_cmd = "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git #{p10k_theme_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "Powerlevel10k theme installed successfully".green
    return true
  else
    puts "Failed to install Powerlevel10k theme".red
    puts "Please install Powerlevel10k theme manually".yellow
    return false
  end
end

def install_zsh_plugins
  print_header("Installing Zsh Plugins")
  
  custom_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/plugins')
  
  # Install zsh-autosuggestions
  autosuggestions_dir = File.join(custom_dir, 'zsh-autosuggestions')
  if Dir.exist?(autosuggestions_dir)
    puts "zsh-autosuggestions is already installed, updating...".yellow
    Dir.chdir(autosuggestions_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-autosuggestions")
  else
    puts "Installing zsh-autosuggestions...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-autosuggestions #{autosuggestions_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-autosuggestions", success)
  end
  
  # Install zsh-syntax-highlighting
  syntax_highlighting_dir = File.join(custom_dir, 'zsh-syntax-highlighting')
  if Dir.exist?(syntax_highlighting_dir)
    puts "zsh-syntax-highlighting is already installed, updating...".yellow
    Dir.chdir(syntax_highlighting_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-syntax-highlighting")
  else
    puts "Installing zsh-syntax-highlighting...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git #{syntax_highlighting_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-syntax-highlighting", success)
  end
  
  true
end

def install_tmux_plugin_manager
  print_header("Installing tmux Plugin Manager")
  
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  
  if Dir.exist?(tpm_dir)
    puts "tmux plugin manager is already installed, updating...".yellow
    Dir.chdir(tpm_dir) do
      run_command('git pull')
    end
    check_result("Updated tmux plugin manager")
    return true
  end
  
  puts "Installing tmux plugin manager...".blue
  create_directory(File.join(CONFIG_DIRS[:tmux], 'plugins'))
  install_cmd = "git clone https://github.com/tmux-plugins/tpm #{tpm_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "tmux plugin manager installed successfully".green
    return true
  else
    puts "Failed to install tmux plugin manager".red
    puts "Please install tmux plugin manager manually".yellow
    return false
  end
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

def create_zshrc(file)
  content = <<~ZSH
    # ZSH Configuration created by terminal-installer script

    # Enable Powerlevel10k instant prompt
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    # Path to Oh My Zsh installation
    export ZSH="$HOME/.oh-my-zsh"

    # Theme
    ZSH_THEME="powerlevel10k/powerlevel10k"

    # Plugins
    plugins=(
      git
      ruby
      python
      node
      macos
      tmux
      zsh-autosuggestions
      zsh-syntax-highlighting
    )

    source $ZSH/oh-my-zsh.sh

    # ============ Aliases ============
    # Git aliases
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit -m"
    alias gp="git push"
    alias gl="git pull"

    # Navigation aliases
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # Directory listing aliases
    alias ll="ls -la"
    alias la="ls -a"

    # Neovim alias
    alias v="nvim"
    alias vi="nvim"
    alias vim="nvim"

    # Tmux aliases
    alias ta="tmux attach -t"
    alias tls="tmux list-sessions"
    alias tn="tmux new -s"
    alias tk="tmux kill-session -t"

    # Development workflow aliases
    alias dev="tmux attach -t dev || tmux new -s dev"
    alias notes="tmux attach -t notes || tmux new -s notes"

    # ============ Functions ============
    # Create and change to directory in one command
    mcd() {
      mkdir -p "$1" && cd "$1"
    }

    # Find and open file with Neovim
    nvimf() {
      local file
      file=$(find . -name "*$1*" | fzf)
      if [[ -n "$file" ]]; then
        nvim "$file"
      fi
    }

    # Check if functions are properly loaded
    check-functions() {
      echo "Testing key functions..."
      declare -f mcd > /dev/null && echo "✓ mcd (make directory and cd) function is available" || echo "✗ mcd function is not available"
      declare -f nvimf > /dev/null && echo "✓ nvimf (find and edit with neovim) function is available" || echo "✗ nvimf function is not available"
      declare -f wk > /dev/null && echo "✓ wk (session manager) function is available" || echo "✗ wk function is not available"
    }

    # Unified session manager for both dev and notes
    wk() {
      local session=$1
      
      case "$session" in
        dev)
          if ! tmux has-session -t dev 2>/dev/null; then
            # Create development session with windows for code, server, and git
            tmux new-session -d -s dev -n code
            tmux new-window -t dev:1 -n server
            tmux new-window -t dev:2 -n git
            tmux select-window -t dev:0
          fi
          tmux attach -t dev
          ;;
        notes)
          if ! tmux has-session -t notes 2>/dev/null; then
            # Create notes session with windows for main, daily, projects, and learning
            tmux new-session -d -s notes -n main -c ~/notes
            tmux new-window -t notes:1 -n daily -c ~/notes/daily
            tmux new-window -t notes:2 -n projects -c ~/notes/projects
            tmux new-window -t notes:3 -n learning -c ~/notes/learning
            tmux select-window -t notes:0
          fi
          tmux attach -t notes
          ;;
        *)
          echo "Usage: wk [dev|notes]"
          echo "  dev   - Start or resume development session"
          echo "  notes - Start or resume notes session"
          ;;
      esac
    }

    # ============ Zsh-specific settings ============
    setopt AUTO_PUSHD        # Push directories onto the directory stack
    setopt PUSHD_IGNORE_DUPS # Do not push duplicates
    setopt PUSHD_SILENT      # Do not print the directory stack after pushd/popd
    setopt EXTENDED_GLOB     # Use extended globbing
    setopt AUTO_CD           # Type directory name to cd

    # fzf configuration
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git || find . -type f -not -path '*/\.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

    # Add ~/bin to PATH
    export PATH="$HOME/bin:$PATH"

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  ZSH
  
  create_file(file, content)
end

def create_tmux_conf(file)
  content = <<~TMUX
    # Terminal Development Environment tmux Configuration

    # Remap prefix from 'C-b' to 'C-a'
    unbind C-b
    set-option -g prefix C-a
    bind-key C-a send-prefix

    # Split panes using | and -
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %

    # Reload config file
    bind r source-file ~/.tmux.conf \\; display "Config reloaded!"

    # Switch panes using Alt-arrow without prefix
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Enable mouse control
    set -g mouse on

    # Don't rename windows automatically
    set-option -g allow-rename off

    # Improve colors
    set -g default-terminal "screen-256color"
    set -ga terminal-overrides ",xterm-256color:Tc"

    # Start window numbering at 1
    set -g base-index 1
    setw -g pane-base-index 1

    # Increase scrollback buffer size
    set -g history-limit 10000

    # Display tmux messages for 4 seconds
    set -g display-time 4000

    # Vim-like copy mode
    setw -g mode-keys vi
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # Status bar
    set -g status-style bg=default
    set -g status-left-length 40
    set -g status-right-length 60
    set -g status-position bottom
    set -g status-left '#[fg=green]#S #[fg=black]• #[fg=green,bright]#(whoami)#[fg=black] • #[fg=green]#h '
    set -g status-right '#[fg=white,bg=default]%a %H:%M #[fg=white,bg=default]%Y-%m-%d '

    # List of plugins
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'tmux-plugins/tmux-resurrect'
    set -g @plugin 'tmux-plugins/tmux-continuum'
    set -g @plugin 'tmux-plugins/tmux-yank'

    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    run '~/.tmux/plugins/tpm/tpm'
  TMUX
  
  create_file(file, content)
end

def create_p10k_conf(file)
  content = <<~P10K
    # Generated by terminal-installer
    # Config file for Powerlevel10k with minimal settings.
    # Wizard for this theme can be run by `p10k configure`.

    # Temporarily change options.
    'builtin' 'local' '-a' 'p10k_config_opts'
    [[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
    [[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
    [[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
    'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

    () {
      emulate -L zsh -o extended_glob

      # Unset all configuration options.
      unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

      # Zsh >= 5.1.1 is required.
      [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

      # Left prompt segments.
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        dir                       # current directory
        vcs                       # git status
        prompt_char               # prompt symbol
      )

      # Right prompt segments.
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status                    # exit code of the last command
        command_execution_time    # duration of the last command
        background_jobs           # presence of background jobs
        virtualenv                # python virtual environment
        time                      # current time
      )

      # Basic style options
      typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
      typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''
      
      # Install gitstatus plugin
      source ${0:A:h}/gitstatus/gitstatus.plugin.zsh || source /usr/local/opt/powerlevel10k/gitstatus/gitstatus.plugin.zsh || return
    }

    (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
    'builtin' 'unset' 'p10k_config_opts'
  P10K
  
  create_file(file, content)
end

def create_nvim_init(file)
  content = <<~INIT
    -- Terminal Development Environment Neovim Configuration

    -- Initialize Lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- ============ Basic settings ============
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.smartindent = true
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undodir = vim.fn.expand('~/.vim/undodir')
    vim.opt.undofile = true
    vim.opt.hlsearch = false
    vim.opt.incsearch = true
    vim.opt.termguicolors = true
    vim.opt.scrolloff = 8
    vim.opt.updatetime = 50
    vim.opt.colorcolumn = "80"
    vim.g.mapleader = " " -- Space as leader key

    -- ============ Key mappings ============
    -- Better window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h')
    vim.keymap.set('n', '<C-j>', '<C-w>j')
    vim.keymap.set('n', '<C-k>', '<C-w>k')
    vim.keymap.set('n', '<C-l>', '<C-w>l')

    -- Basic utilities
    vim.keymap.set('n', '<leader>w', ':w<CR>')   -- Save
    vim.keymap.set('n', '<leader>q', ':q<CR>')   -- Quit
    vim.keymap.set('n', '<leader>h', ':nohl<CR>') -- Clear search highlighting

    -- Help keymap for showing common mappings
    vim.keymap.set('n', '<leader>?', function()
      print("Common mappings:")
      print("  <leader>e  - Toggle file explorer")
      print("  <leader>ff - Find files")
      print("  <leader>fg - Live grep")
      print("  <leader>fb - Browse buffers")
      print("  <leader>w  - Save file")
      print("  <leader>q  - Quit")
      print("  gd         - Go to definition")
      print("  K          - Show documentation")
    end, { noremap = true, silent = true })

    -- ============ Load plugins ============
    require("lazy").setup("plugins")

    -- ============ LSP Server Naming Guide ============
    -- When configuring Mason LSP, use these server names:
    -- Ruby: ruby_ls
    -- TypeScript: tsserver
    -- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
  INIT
  
  create_file(file, content)
end

def create_nvim_plugins(file)
  content = <<~PLUGINS
    return {
      -- Colorscheme
      {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
          vim.cmd.colorscheme "tokyonight"
        end,
      },
      
      -- Status line
      {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
          require('lualine').setup()
        end,
      },
      
      -- File explorer
      {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          require("nvim-tree").setup {}
          vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
        end,
      },
      
      -- Fuzzy finder
      {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files)
          vim.keymap.set('n', '<leader>fg', builtin.live_grep)
          vim.keymap.set('n', '<leader>fb', builtin.buffers)
          vim.keymap.set('n', '<leader>fh', builtin.help_tags)
        end,
      },
      
      -- LSP configuration
      {
        'neovim/nvim-lspconfig',
        dependencies = {
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',
        },
        config = function()
          require('mason').setup()
          require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'ruby_ls', 'pyright', 'tsserver' }
          })
          
          local lspconfig = require('lspconfig')
          
          -- Configure language servers
          lspconfig.lua_ls.setup{}      -- Lua language server
          lspconfig.ruby_ls.setup{}     -- Ruby language server
          lspconfig.pyright.setup{}     -- Python language server
          lspconfig.tsserver.setup{}    -- TypeScript/JavaScript language server
          
          -- Global LSP mappings
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          
          -- Check for format function (handles version differences)
          if vim.lsp.buf.format then
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
          else
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting)
          end
        end,
      },
      
      -- Treesitter
      {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
          require('nvim-treesitter.configs').setup {
            ensure_installed = { "lua", "ruby", "python", "javascript", "typescript", "markdown" },
            highlight = {
              enable = true,
            },
          }
        end,
      },
      
      -- Git integration
      {
        'tpope/vim-fugitive',
        config = function()
          vim.keymap.set('n', '<leader>gs', ':Git<CR>')
          vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
          vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
        end,
      },
      
      -- Auto-completion
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-path',
          'L3MON4D3/LuaSnip',
          'saadparwaiz1/cmp_luasnip',
        },
        config = function()
          local cmp = require('cmp')
          local luasnip = require('luasnip')
          
          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              { name = 'buffer' },
              { name = 'path' }
            }),
          }
        end,
      },
      
      -- Commenting
      {
        'numToStr/Comment.nvim',
        config = function()
          require('Comment').setup()
        end,
      },
      
      -- Markdown preview
      {
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        build = function()
          vim.fn['mkdp#util#install']()
        end,
      },
      
      -- Autopairs
      {
        'windwp/nvim-autopairs',
        config = function()
          require('nvim-autopairs').setup()
        end,
      },
      
      -- Indentation guides
      {
        'lukas-reineke/indent-blankline.nvim',
        main = "ibl",
        config = function()
          require('ibl').setup()
        end,
      },
      
      -- Notes system support (optional plugins for notes)
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable('make') == 1,
        config = function()
          require('telescope').load_extension('fzf')
        end,
      },
      
      -- Which-key for showing key mappings
      {
        'folke/which-key.nvim',
        config = function()
          require('which-key').setup()
        end,
      },
    }
  PLUGINS
  
  create_file(file, content)
end) == 1 && getline(1) == ''
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
      if line('

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
INSTALL_DIR = File.join(HOME_DIR, '.terminal-env')
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

TEMPLATE_DIRS = {
  notes_daily: File.join(CONFIG_DIRS[:notes], 'daily'),
  notes_projects: File.join(CONFIG_DIRS[:notes], 'projects'),
  notes_learning: File.join(CONFIG_DIRS[:notes], 'learning'),
  notes_templates: File.join(CONFIG_DIRS[:notes], 'templates')
}

REQUIRED_TOOLS = {
  'zsh' => 'brew install zsh',
  'nvim' => 'brew install neovim',
  'tmux' => 'brew install tmux',
  'git' => 'brew install git',
  'watchman' => 'brew install watchman',
  'fzf' => 'brew install fzf'
}

# Installation modes
FULL_INSTALL = 1
MINIMAL_UPDATE = 2
PERMISSIONS_FIX = 3
UNINSTALL = 4

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

def add_line_if_not_exists(file, line)
  return false unless File.exist?(file)
  return true if file_contains?(file, Regexp.escape(line))
  
  append_to_file(file, line)
end

def check_and_add_alias(file, alias_name, command)
  pattern = "alias\\s+#{alias_name}\\s*="
  
  if !file_contains?(file, pattern)
    append_to_file(file, "\n# Added by installer script\nalias #{alias_name}='#{command}'")
    puts "Added alias #{alias_name} to #{file}".green
    return true
  end
  
  puts "Alias #{alias_name} already exists in #{file}".green
  true
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
  backup_dir = File.join(HOME_DIR, "terminal_env_backup_#{timestamp}")
  
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
  
  # Backup notes templates if they exist
  if Dir.exist?(File.join(CONFIG_DIRS[:notes], 'templates'))
    templates_backup = File.join(backup_dir, 'notes_templates')
    FileUtils.mkdir_p(templates_backup)
    FileUtils.cp_r(Dir.glob(File.join(CONFIG_DIRS[:notes], 'templates', '*')), templates_backup)
    puts "Backed up notes templates to #{templates_backup}".green
  end
  
  puts "All existing configurations backed up to #{backup_dir}".green
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
      if !file_contains?(CONFIG_FILES[:zshrc], 'eval.*brew shellenv')
        add_line_if_not_exists(CONFIG_FILES[:zshrc], 'eval "$(/opt/homebrew/bin/brew shellenv)"')
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
  
  success = true
  REQUIRED_TOOLS.each do |tool, install_cmd|
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

def install_oh_my_zsh
  print_header("Installing Oh My Zsh")
  
  if Dir.exist?(File.join(HOME_DIR, '.oh-my-zsh'))
    puts "Oh My Zsh is already installed".green
    return true
  end
  
  puts "Installing Oh My Zsh...".blue
  install_cmd = 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
  output, success = run_command(install_cmd)
  
  if success
    puts "Oh My Zsh installed successfully".green
    return true
  else
    puts "Failed to install Oh My Zsh".red
    puts "Please install Oh My Zsh manually".yellow
    return false
  end
end

def install_powerlevel10k
  print_header("Installing Powerlevel10k")
  
  p10k_theme_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/themes/powerlevel10k')
  
  if Dir.exist?(p10k_theme_dir)
    puts "Powerlevel10k theme is already installed, updating...".yellow
    Dir.chdir(p10k_theme_dir) do
      run_command('git pull')
    end
    check_result("Updated Powerlevel10k theme")
    return true
  end
  
  puts "Installing Powerlevel10k theme...".blue
  install_cmd = "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git #{p10k_theme_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "Powerlevel10k theme installed successfully".green
    return true
  else
    puts "Failed to install Powerlevel10k theme".red
    puts "Please install Powerlevel10k theme manually".yellow
    return false
  end
end

def install_zsh_plugins
  print_header("Installing Zsh Plugins")
  
  custom_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/plugins')
  
  # Install zsh-autosuggestions
  autosuggestions_dir = File.join(custom_dir, 'zsh-autosuggestions')
  if Dir.exist?(autosuggestions_dir)
    puts "zsh-autosuggestions is already installed, updating...".yellow
    Dir.chdir(autosuggestions_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-autosuggestions")
  else
    puts "Installing zsh-autosuggestions...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-autosuggestions #{autosuggestions_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-autosuggestions", success)
  end
  
  # Install zsh-syntax-highlighting
  syntax_highlighting_dir = File.join(custom_dir, 'zsh-syntax-highlighting')
  if Dir.exist?(syntax_highlighting_dir)
    puts "zsh-syntax-highlighting is already installed, updating...".yellow
    Dir.chdir(syntax_highlighting_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-syntax-highlighting")
  else
    puts "Installing zsh-syntax-highlighting...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git #{syntax_highlighting_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-syntax-highlighting", success)
  end
  
  true
end

def install_tmux_plugin_manager
  print_header("Installing tmux Plugin Manager")
  
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  
  if Dir.exist?(tpm_dir)
    puts "tmux plugin manager is already installed, updating...".yellow
    Dir.chdir(tpm_dir) do
      run_command('git pull')
    end
    check_result("Updated tmux plugin manager")
    return true
  end
  
  puts "Installing tmux plugin manager...".blue
  create_directory(File.join(CONFIG_DIRS[:tmux], 'plugins'))
  install_cmd = "git clone https://github.com/tmux-plugins/tpm #{tpm_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "tmux plugin manager installed successfully".green
    return true
  else
    puts "Failed to install tmux plugin manager".red
    puts "Please install tmux plugin manager manually".yellow
    return false
  end
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

def create_zshrc(file)
  content = <<~ZSH
    # ZSH Configuration created by terminal-installer script

    # Enable Powerlevel10k instant prompt
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    # Path to Oh My Zsh installation
    export ZSH="$HOME/.oh-my-zsh"

    # Theme
    ZSH_THEME="powerlevel10k/powerlevel10k"

    # Plugins
    plugins=(
      git
      ruby
      python
      node
      macos
      tmux
      zsh-autosuggestions
      zsh-syntax-highlighting
    )

    source $ZSH/oh-my-zsh.sh

    # ============ Aliases ============
    # Git aliases
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit -m"
    alias gp="git push"
    alias gl="git pull"

    # Navigation aliases
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # Directory listing aliases
    alias ll="ls -la"
    alias la="ls -a"

    # Neovim alias
    alias v="nvim"
    alias vi="nvim"
    alias vim="nvim"

    # Tmux aliases
    alias ta="tmux attach -t"
    alias tls="tmux list-sessions"
    alias tn="tmux new -s"
    alias tk="tmux kill-session -t"

    # Development workflow aliases
    alias dev="tmux attach -t dev || tmux new -s dev"
    alias notes="tmux attach -t notes || tmux new -s notes"

    # ============ Functions ============
    # Create and change to directory in one command
    mcd() {
      mkdir -p "$1" && cd "$1"
    }

    # Find and open file with Neovim
    nvimf() {
      local file
      file=$(find . -name "*$1*" | fzf)
      if [[ -n "$file" ]]; then
        nvim "$file"
      fi
    }

    # Check if functions are properly loaded
    check-functions() {
      echo "Testing key functions..."
      declare -f mcd > /dev/null && echo "✓ mcd (make directory and cd) function is available" || echo "✗ mcd function is not available"
      declare -f nvimf > /dev/null && echo "✓ nvimf (find and edit with neovim) function is available" || echo "✗ nvimf function is not available"
      declare -f wk > /dev/null && echo "✓ wk (session manager) function is available" || echo "✗ wk function is not available"
    }

    # Unified session manager for both dev and notes
    wk() {
      local session=$1
      
      case "$session" in
        dev)
          if ! tmux has-session -t dev 2>/dev/null; then
            # Create development session with windows for code, server, and git
            tmux new-session -d -s dev -n code
            tmux new-window -t dev:1 -n server
            tmux new-window -t dev:2 -n git
            tmux select-window -t dev:0
          fi
          tmux attach -t dev
          ;;
        notes)
          if ! tmux has-session -t notes 2>/dev/null; then
            # Create notes session with windows for main, daily, projects, and learning
            tmux new-session -d -s notes -n main -c ~/notes
            tmux new-window -t notes:1 -n daily -c ~/notes/daily
            tmux new-window -t notes:2 -n projects -c ~/notes/projects
            tmux new-window -t notes:3 -n learning -c ~/notes/learning
            tmux select-window -t notes:0
          fi
          tmux attach -t notes
          ;;
        *)
          echo "Usage: wk [dev|notes]"
          echo "  dev   - Start or resume development session"
          echo "  notes - Start or resume notes session"
          ;;
      esac
    }

    # ============ Zsh-specific settings ============
    setopt AUTO_PUSHD        # Push directories onto the directory stack
    setopt PUSHD_IGNORE_DUPS # Do not push duplicates
    setopt PUSHD_SILENT      # Do not print the directory stack after pushd/popd
    setopt EXTENDED_GLOB     # Use extended globbing
    setopt AUTO_CD           # Type directory name to cd

    # fzf configuration
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git || find . -type f -not -path '*/\.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

    # Add ~/bin to PATH
    export PATH="$HOME/bin:$PATH"

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  ZSH
  
  create_file(file, content)
end

def create_tmux_conf(file)
  content = <<~TMUX
    # Terminal Development Environment tmux Configuration

    # Remap prefix from 'C-b' to 'C-a'
    unbind C-b
    set-option -g prefix C-a
    bind-key C-a send-prefix

    # Split panes using | and -
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %

    # Reload config file
    bind r source-file ~/.tmux.conf \\; display "Config reloaded!"

    # Switch panes using Alt-arrow without prefix
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Enable mouse control
    set -g mouse on

    # Don't rename windows automatically
    set-option -g allow-rename off

    # Improve colors
    set -g default-terminal "screen-256color"
    set -ga terminal-overrides ",xterm-256color:Tc"

    # Start window numbering at 1
    set -g base-index 1
    setw -g pane-base-index 1

    # Increase scrollback buffer size
    set -g history-limit 10000

    # Display tmux messages for 4 seconds
    set -g display-time 4000

    # Vim-like copy mode
    setw -g mode-keys vi
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # Status bar
    set -g status-style bg=default
    set -g status-left-length 40
    set -g status-right-length 60
    set -g status-position bottom
    set -g status-left '#[fg=green]#S #[fg=black]• #[fg=green,bright]#(whoami)#[fg=black] • #[fg=green]#h '
    set -g status-right '#[fg=white,bg=default]%a %H:%M #[fg=white,bg=default]%Y-%m-%d '

    # List of plugins
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'tmux-plugins/tmux-resurrect'
    set -g @plugin 'tmux-plugins/tmux-continuum'
    set -g @plugin 'tmux-plugins/tmux-yank'

    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    run '~/.tmux/plugins/tpm/tpm'
  TMUX
  
  create_file(file, content)
end

def create_p10k_conf(file)
  content = <<~P10K
    # Generated by terminal-installer
    # Config file for Powerlevel10k with minimal settings.
    # Wizard for this theme can be run by `p10k configure`.

    # Temporarily change options.
    'builtin' 'local' '-a' 'p10k_config_opts'
    [[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
    [[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
    [[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
    'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

    () {
      emulate -L zsh -o extended_glob

      # Unset all configuration options.
      unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

      # Zsh >= 5.1.1 is required.
      [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

      # Left prompt segments.
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        dir                       # current directory
        vcs                       # git status
        prompt_char               # prompt symbol
      )

      # Right prompt segments.
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status                    # exit code of the last command
        command_execution_time    # duration of the last command
        background_jobs           # presence of background jobs
        virtualenv                # python virtual environment
        time                      # current time
      )

      # Basic style options
      typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
      typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''
      
      # Install gitstatus plugin
      source ${0:A:h}/gitstatus/gitstatus.plugin.zsh || source /usr/local/opt/powerlevel10k/gitstatus/gitstatus.plugin.zsh || return
    }

    (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
    'builtin' 'unset' 'p10k_config_opts'
  P10K
  
  create_file(file, content)
end

def create_nvim_init(file)
  content = <<~INIT
    -- Terminal Development Environment Neovim Configuration

    -- Initialize Lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- ============ Basic settings ============
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.smartindent = true
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undodir = vim.fn.expand('~/.vim/undodir')
    vim.opt.undofile = true
    vim.opt.hlsearch = false
    vim.opt.incsearch = true
    vim.opt.termguicolors = true
    vim.opt.scrolloff = 8
    vim.opt.updatetime = 50
    vim.opt.colorcolumn = "80"
    vim.g.mapleader = " " -- Space as leader key

    -- ============ Key mappings ============
    -- Better window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h')
    vim.keymap.set('n', '<C-j>', '<C-w>j')
    vim.keymap.set('n', '<C-k>', '<C-w>k')
    vim.keymap.set('n', '<C-l>', '<C-w>l')

    -- Basic utilities
    vim.keymap.set('n', '<leader>w', ':w<CR>')   -- Save
    vim.keymap.set('n', '<leader>q', ':q<CR>')   -- Quit
    vim.keymap.set('n', '<leader>h', ':nohl<CR>') -- Clear search highlighting

    -- Help keymap for showing common mappings
    vim.keymap.set('n', '<leader>?', function()
      print("Common mappings:")
      print("  <leader>e  - Toggle file explorer")
      print("  <leader>ff - Find files")
      print("  <leader>fg - Live grep")
      print("  <leader>fb - Browse buffers")
      print("  <leader>w  - Save file")
      print("  <leader>q  - Quit")
      print("  gd         - Go to definition")
      print("  K          - Show documentation")
    end, { noremap = true, silent = true })

    -- ============ Load plugins ============
    require("lazy").setup("plugins")

    -- ============ LSP Server Naming Guide ============
    -- When configuring Mason LSP, use these server names:
    -- Ruby: ruby_ls
    -- TypeScript: tsserver
    -- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
  INIT
  
  create_file(file, content)
end

def create_nvim_plugins(file)
  content = <<~PLUGINS
    return {
      -- Colorscheme
      {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
          vim.cmd.colorscheme "tokyonight"
        end,
      },
      
      -- Status line
      {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
          require('lualine').setup()
        end,
      },
      
      -- File explorer
      {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          require("nvim-tree").setup {}
          vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
        end,
      },
      
      -- Fuzzy finder
      {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files)
          vim.keymap.set('n', '<leader>fg', builtin.live_grep)
          vim.keymap.set('n', '<leader>fb', builtin.buffers)
          vim.keymap.set('n', '<leader>fh', builtin.help_tags)
        end,
      },
      
      -- LSP configuration
      {
        'neovim/nvim-lspconfig',
        dependencies = {
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',
        },
        config = function()
          require('mason').setup()
          require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'ruby_ls', 'pyright', 'tsserver' }
          })
          
          local lspconfig = require('lspconfig')
          
          -- Configure language servers
          lspconfig.lua_ls.setup{}      -- Lua language server
          lspconfig.ruby_ls.setup{}     -- Ruby language server
          lspconfig.pyright.setup{}     -- Python language server
          lspconfig.tsserver.setup{}    -- TypeScript/JavaScript language server
          
          -- Global LSP mappings
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          
          -- Check for format function (handles version differences)
          if vim.lsp.buf.format then
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
          else
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting)
          end
        end,
      },
      
      -- Treesitter
      {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
          require('nvim-treesitter.configs').setup {
            ensure_installed = { "lua", "ruby", "python", "javascript", "typescript", "markdown" },
            highlight = {
              enable = true,
            },
          }
        end,
      },
      
      -- Git integration
      {
        'tpope/vim-fugitive',
        config = function()
          vim.keymap.set('n', '<leader>gs', ':Git<CR>')
          vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
          vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
        end,
      },
      
      -- Auto-completion
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-path',
          'L3MON4D3/LuaSnip',
          'saadparwaiz1/cmp_luasnip',
        },
        config = function()
          local cmp = require('cmp')
          local luasnip = require('luasnip')
          
          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              { name = 'buffer' },
              { name = 'path' }
            }),
          }
        end,
      },
      
      -- Commenting
      {
        'numToStr/Comment.nvim',
        config = function()
          require('Comment').setup()
        end,
      },
      
      -- Markdown preview
      {
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        build = function()
          vim.fn['mkdp#util#install']()
        end,
      },
      
      -- Autopairs
      {
        'windwp/nvim-autopairs',
        config = function()
          require('nvim-autopairs').setup()
        end,
      },
      
      -- Indentation guides
      {
        'lukas-reineke/indent-blankline.nvim',
        main = "ibl",
        config = function()
          require('ibl').setup()
        end,
      },
      
      -- Notes system support (optional plugins for notes)
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable('make') == 1,
        config = function()
          require('telescope').load_extension('fzf')
        end,
      },
      
      -- Which-key for showing key mappings
      {
        'folke/which-key.nvim',
        config = function()
          require('which-key').setup()
        end,
      },
    }
  PLUGINS
  
  create_file(file, content)
end) == 1 && getline(1) == ''
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
INSTALL_DIR = File.join(HOME_DIR, '.terminal-env')
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

TEMPLATE_DIRS = {
  notes_daily: File.join(CONFIG_DIRS[:notes], 'daily'),
  notes_projects: File.join(CONFIG_DIRS[:notes], 'projects'),
  notes_learning: File.join(CONFIG_DIRS[:notes], 'learning'),
  notes_templates: File.join(CONFIG_DIRS[:notes], 'templates')
}

REQUIRED_TOOLS = {
  'zsh' => 'brew install zsh',
  'nvim' => 'brew install neovim',
  'tmux' => 'brew install tmux',
  'git' => 'brew install git',
  'watchman' => 'brew install watchman',
  'fzf' => 'brew install fzf'
}

# Installation modes
FULL_INSTALL = 1
MINIMAL_UPDATE = 2
PERMISSIONS_FIX = 3
UNINSTALL = 4

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

def add_line_if_not_exists(file, line)
  return false unless File.exist?(file)
  return true if file_contains?(file, Regexp.escape(line))
  
  append_to_file(file, line)
end

def check_and_add_alias(file, alias_name, command)
  pattern = "alias\\s+#{alias_name}\\s*="
  
  if !file_contains?(file, pattern)
    append_to_file(file, "\n# Added by installer script\nalias #{alias_name}='#{command}'")
    puts "Added alias #{alias_name} to #{file}".green
    return true
  end
  
  puts "Alias #{alias_name} already exists in #{file}".green
  true
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
  backup_dir = File.join(HOME_DIR, "terminal_env_backup_#{timestamp}")
  
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
  
  # Backup notes templates if they exist
  if Dir.exist?(File.join(CONFIG_DIRS[:notes], 'templates'))
    templates_backup = File.join(backup_dir, 'notes_templates')
    FileUtils.mkdir_p(templates_backup)
    FileUtils.cp_r(Dir.glob(File.join(CONFIG_DIRS[:notes], 'templates', '*')), templates_backup)
    puts "Backed up notes templates to #{templates_backup}".green
  end
  
  puts "All existing configurations backed up to #{backup_dir}".green
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
      if !file_contains?(CONFIG_FILES[:zshrc], 'eval.*brew shellenv')
        add_line_if_not_exists(CONFIG_FILES[:zshrc], 'eval "$(/opt/homebrew/bin/brew shellenv)"')
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
  
  success = true
  REQUIRED_TOOLS.each do |tool, install_cmd|
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

def install_oh_my_zsh
  print_header("Installing Oh My Zsh")
  
  if Dir.exist?(File.join(HOME_DIR, '.oh-my-zsh'))
    puts "Oh My Zsh is already installed".green
    return true
  end
  
  puts "Installing Oh My Zsh...".blue
  install_cmd = 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
  output, success = run_command(install_cmd)
  
  if success
    puts "Oh My Zsh installed successfully".green
    return true
  else
    puts "Failed to install Oh My Zsh".red
    puts "Please install Oh My Zsh manually".yellow
    return false
  end
end

def install_powerlevel10k
  print_header("Installing Powerlevel10k")
  
  p10k_theme_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/themes/powerlevel10k')
  
  if Dir.exist?(p10k_theme_dir)
    puts "Powerlevel10k theme is already installed, updating...".yellow
    Dir.chdir(p10k_theme_dir) do
      run_command('git pull')
    end
    check_result("Updated Powerlevel10k theme")
    return true
  end
  
  puts "Installing Powerlevel10k theme...".blue
  install_cmd = "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git #{p10k_theme_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "Powerlevel10k theme installed successfully".green
    return true
  else
    puts "Failed to install Powerlevel10k theme".red
    puts "Please install Powerlevel10k theme manually".yellow
    return false
  end
end

def install_zsh_plugins
  print_header("Installing Zsh Plugins")
  
  custom_dir = File.join(HOME_DIR, '.oh-my-zsh/custom/plugins')
  
  # Install zsh-autosuggestions
  autosuggestions_dir = File.join(custom_dir, 'zsh-autosuggestions')
  if Dir.exist?(autosuggestions_dir)
    puts "zsh-autosuggestions is already installed, updating...".yellow
    Dir.chdir(autosuggestions_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-autosuggestions")
  else
    puts "Installing zsh-autosuggestions...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-autosuggestions #{autosuggestions_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-autosuggestions", success)
  end
  
  # Install zsh-syntax-highlighting
  syntax_highlighting_dir = File.join(custom_dir, 'zsh-syntax-highlighting')
  if Dir.exist?(syntax_highlighting_dir)
    puts "zsh-syntax-highlighting is already installed, updating...".yellow
    Dir.chdir(syntax_highlighting_dir) do
      run_command('git pull')
    end
    check_result("Updated zsh-syntax-highlighting")
  else
    puts "Installing zsh-syntax-highlighting...".blue
    install_cmd = "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git #{syntax_highlighting_dir}"
    output, success = run_command(install_cmd)
    check_result("Installed zsh-syntax-highlighting", success)
  end
  
  true
end

def install_tmux_plugin_manager
  print_header("Installing tmux Plugin Manager")
  
  tpm_dir = File.join(CONFIG_DIRS[:tmux], 'plugins/tpm')
  
  if Dir.exist?(tpm_dir)
    puts "tmux plugin manager is already installed, updating...".yellow
    Dir.chdir(tpm_dir) do
      run_command('git pull')
    end
    check_result("Updated tmux plugin manager")
    return true
  end
  
  puts "Installing tmux plugin manager...".blue
  create_directory(File.join(CONFIG_DIRS[:tmux], 'plugins'))
  install_cmd = "git clone https://github.com/tmux-plugins/tpm #{tpm_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "tmux plugin manager installed successfully".green
    return true
  else
    puts "Failed to install tmux plugin manager".red
    puts "Please install tmux plugin manager manually".yellow
    return false
  end
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

def create_zshrc(file)
  content = <<~ZSH
    # ZSH Configuration created by terminal-installer script

    # Enable Powerlevel10k instant prompt
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    # Path to Oh My Zsh installation
    export ZSH="$HOME/.oh-my-zsh"

    # Theme
    ZSH_THEME="powerlevel10k/powerlevel10k"

    # Plugins
    plugins=(
      git
      ruby
      python
      node
      macos
      tmux
      zsh-autosuggestions
      zsh-syntax-highlighting
    )

    source $ZSH/oh-my-zsh.sh

    # ============ Aliases ============
    # Git aliases
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit -m"
    alias gp="git push"
    alias gl="git pull"

    # Navigation aliases
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # Directory listing aliases
    alias ll="ls -la"
    alias la="ls -a"

    # Neovim alias
    alias v="nvim"
    alias vi="nvim"
    alias vim="nvim"

    # Tmux aliases
    alias ta="tmux attach -t"
    alias tls="tmux list-sessions"
    alias tn="tmux new -s"
    alias tk="tmux kill-session -t"

    # Development workflow aliases
    alias dev="tmux attach -t dev || tmux new -s dev"
    alias notes="tmux attach -t notes || tmux new -s notes"

    # ============ Functions ============
    # Create and change to directory in one command
    mcd() {
      mkdir -p "$1" && cd "$1"
    }

    # Find and open file with Neovim
    nvimf() {
      local file
      file=$(find . -name "*$1*" | fzf)
      if [[ -n "$file" ]]; then
        nvim "$file"
      fi
    }

    # Check if functions are properly loaded
    check-functions() {
      echo "Testing key functions..."
      declare -f mcd > /dev/null && echo "✓ mcd (make directory and cd) function is available" || echo "✗ mcd function is not available"
      declare -f nvimf > /dev/null && echo "✓ nvimf (find and edit with neovim) function is available" || echo "✗ nvimf function is not available"
      declare -f wk > /dev/null && echo "✓ wk (session manager) function is available" || echo "✗ wk function is not available"
    }

    # Unified session manager for both dev and notes
    wk() {
      local session=$1
      
      case "$session" in
        dev)
          if ! tmux has-session -t dev 2>/dev/null; then
            # Create development session with windows for code, server, and git
            tmux new-session -d -s dev -n code
            tmux new-window -t dev:1 -n server
            tmux new-window -t dev:2 -n git
            tmux select-window -t dev:0
          fi
          tmux attach -t dev
          ;;
        notes)
          if ! tmux has-session -t notes 2>/dev/null; then
            # Create notes session with windows for main, daily, projects, and learning
            tmux new-session -d -s notes -n main -c ~/notes
            tmux new-window -t notes:1 -n daily -c ~/notes/daily
            tmux new-window -t notes:2 -n projects -c ~/notes/projects
            tmux new-window -t notes:3 -n learning -c ~/notes/learning
            tmux select-window -t notes:0
          fi
          tmux attach -t notes
          ;;
        *)
          echo "Usage: wk [dev|notes]"
          echo "  dev   - Start or resume development session"
          echo "  notes - Start or resume notes session"
          ;;
      esac
    }

    # ============ Zsh-specific settings ============
    setopt AUTO_PUSHD        # Push directories onto the directory stack
    setopt PUSHD_IGNORE_DUPS # Do not push duplicates
    setopt PUSHD_SILENT      # Do not print the directory stack after pushd/popd
    setopt EXTENDED_GLOB     # Use extended globbing
    setopt AUTO_CD           # Type directory name to cd

    # fzf configuration
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git || find . -type f -not -path '*/\.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

    # Add ~/bin to PATH
    export PATH="$HOME/bin:$PATH"

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
  ZSH
  
  create_file(file, content)
end

def create_tmux_conf(file)
  content = <<~TMUX
    # Terminal Development Environment tmux Configuration

    # Remap prefix from 'C-b' to 'C-a'
    unbind C-b
    set-option -g prefix C-a
    bind-key C-a send-prefix

    # Split panes using | and -
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %

    # Reload config file
    bind r source-file ~/.tmux.conf \\; display "Config reloaded!"

    # Switch panes using Alt-arrow without prefix
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Enable mouse control
    set -g mouse on

    # Don't rename windows automatically
    set-option -g allow-rename off

    # Improve colors
    set -g default-terminal "screen-256color"
    set -ga terminal-overrides ",xterm-256color:Tc"

    # Start window numbering at 1
    set -g base-index 1
    setw -g pane-base-index 1

    # Increase scrollback buffer size
    set -g history-limit 10000

    # Display tmux messages for 4 seconds
    set -g display-time 4000

    # Vim-like copy mode
    setw -g mode-keys vi
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # Status bar
    set -g status-style bg=default
    set -g status-left-length 40
    set -g status-right-length 60
    set -g status-position bottom
    set -g status-left '#[fg=green]#S #[fg=black]• #[fg=green,bright]#(whoami)#[fg=black] • #[fg=green]#h '
    set -g status-right '#[fg=white,bg=default]%a %H:%M #[fg=white,bg=default]%Y-%m-%d '

    # List of plugins
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    set -g @plugin 'tmux-plugins/tmux-resurrect'
    set -g @plugin 'tmux-plugins/tmux-continuum'
    set -g @plugin 'tmux-plugins/tmux-yank'

    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    run '~/.tmux/plugins/tpm/tpm'
  TMUX
  
  create_file(file, content)
end

def create_p10k_conf(file)
  content = <<~P10K
    # Generated by terminal-installer
    # Config file for Powerlevel10k with minimal settings.
    # Wizard for this theme can be run by `p10k configure`.

    # Temporarily change options.
    'builtin' 'local' '-a' 'p10k_config_opts'
    [[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
    [[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
    [[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
    'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

    () {
      emulate -L zsh -o extended_glob

      # Unset all configuration options.
      unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

      # Zsh >= 5.1.1 is required.
      [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

      # Left prompt segments.
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        dir                       # current directory
        vcs                       # git status
        prompt_char               # prompt symbol
      )

      # Right prompt segments.
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status                    # exit code of the last command
        command_execution_time    # duration of the last command
        background_jobs           # presence of background jobs
        virtualenv                # python virtual environment
        time                      # current time
      )

      # Basic style options
      typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
      typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
      typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''
      
      # Install gitstatus plugin
      source ${0:A:h}/gitstatus/gitstatus.plugin.zsh || source /usr/local/opt/powerlevel10k/gitstatus/gitstatus.plugin.zsh || return
    }

    (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
    'builtin' 'unset' 'p10k_config_opts'
  P10K
  
  create_file(file, content)
end

def create_nvim_init(file)
  content = <<~INIT
    -- Terminal Development Environment Neovim Configuration

    -- Initialize Lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- ============ Basic settings ============
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.smartindent = true
    vim.opt.wrap = false
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undodir = vim.fn.expand('~/.vim/undodir')
    vim.opt.undofile = true
    vim.opt.hlsearch = false
    vim.opt.incsearch = true
    vim.opt.termguicolors = true
    vim.opt.scrolloff = 8
    vim.opt.updatetime = 50
    vim.opt.colorcolumn = "80"
    vim.g.mapleader = " " -- Space as leader key

    -- ============ Key mappings ============
    -- Better window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h')
    vim.keymap.set('n', '<C-j>', '<C-w>j')
    vim.keymap.set('n', '<C-k>', '<C-w>k')
    vim.keymap.set('n', '<C-l>', '<C-w>l')

    -- Basic utilities
    vim.keymap.set('n', '<leader>w', ':w<CR>')   -- Save
    vim.keymap.set('n', '<leader>q', ':q<CR>')   -- Quit
    vim.keymap.set('n', '<leader>h', ':nohl<CR>') -- Clear search highlighting

    -- Help keymap for showing common mappings
    vim.keymap.set('n', '<leader>?', function()
      print("Common mappings:")
      print("  <leader>e  - Toggle file explorer")
      print("  <leader>ff - Find files")
      print("  <leader>fg - Live grep")
      print("  <leader>fb - Browse buffers")
      print("  <leader>w  - Save file")
      print("  <leader>q  - Quit")
      print("  gd         - Go to definition")
      print("  K          - Show documentation")
    end, { noremap = true, silent = true })

    -- ============ Load plugins ============
    require("lazy").setup("plugins")

    -- ============ LSP Server Naming Guide ============
    -- When configuring Mason LSP, use these server names:
    -- Ruby: ruby_ls
    -- TypeScript: tsserver
    -- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
  INIT
  
  create_file(file, content)
end

def create_nvim_plugins(file)
  content = <<~PLUGINS
    return {
      -- Colorscheme
      {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
          vim.cmd.colorscheme "tokyonight"
        end,
      },
      
      -- Status line
      {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
          require('lualine').setup()
        end,
      },
      
      -- File explorer
      {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          require("nvim-tree").setup {}
          vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
        end,
      },
      
      -- Fuzzy finder
      {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files)
          vim.keymap.set('n', '<leader>fg', builtin.live_grep)
          vim.keymap.set('n', '<leader>fb', builtin.buffers)
          vim.keymap.set('n', '<leader>fh', builtin.help_tags)
        end,
      },
      
      -- LSP configuration
      {
        'neovim/nvim-lspconfig',
        dependencies = {
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',
        },
        config = function()
          require('mason').setup()
          require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'ruby_ls', 'pyright', 'tsserver' }
          })
          
          local lspconfig = require('lspconfig')
          
          -- Configure language servers
          lspconfig.lua_ls.setup{}      -- Lua language server
          lspconfig.ruby_ls.setup{}     -- Ruby language server
          lspconfig.pyright.setup{}     -- Python language server
          lspconfig.tsserver.setup{}    -- TypeScript/JavaScript language server
          
          -- Global LSP mappings
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          
          -- Check for format function (handles version differences)
          if vim.lsp.buf.format then
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
          else
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting)
          end
        end,
      },
      
      -- Treesitter
      {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
          require('nvim-treesitter.configs').setup {
            ensure_installed = { "lua", "ruby", "python", "javascript", "typescript", "markdown" },
            highlight = {
              enable = true,
            },
          }
        end,
      },
      
      -- Git integration
      {
        'tpope/vim-fugitive',
        config = function()
          vim.keymap.set('n', '<leader>gs', ':Git<CR>')
          vim.keymap.set('n', '<leader>gc', ':Git commit<CR>')
          vim.keymap.set('n', '<leader>gp', ':Git push<CR>')
        end,
      },
      
      -- Auto-completion
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-path',
          'L3MON4D3/LuaSnip',
          'saadparwaiz1/cmp_luasnip',
        },
        config = function()
          local cmp = require('cmp')
          local luasnip = require('luasnip')
          
          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
              { name = 'buffer' },
              { name = 'path' }
            }),
          }
        end,
      },
      
      -- Commenting
      {
        'numToStr/Comment.nvim',
        config = function()
          require('Comment').setup()
        end,
      },
      
      -- Markdown preview
      {
        'iamcco/markdown-preview.nvim',
        ft = 'markdown',
        build = function()
          vim.fn['mkdp#util#install']()
        end,
      },
      
      -- Autopairs
      {
        'windwp/nvim-autopairs',
        config = function()
          require('nvim-autopairs').setup()
        end,
      },
      
      -- Indentation guides
      {
        'lukas-reineke/indent-blankline.nvim',
        main = "ibl",
        config = function()
          require('ibl').setup()
        end,
      },
      
      -- Notes system support (optional plugins for notes)
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable('make') == 1,
        config = function()
          require('telescope').load_extension('fzf')
        end,
      },
      
      -- Which-key for showing key mappings
      {
        'folke/which-key.nvim',
        config = function()
          require('which-key').setup()
        end,
      },
    }
  PLUGINS
  
  create_file(file, content)
end