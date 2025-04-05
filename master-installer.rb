#!/usr/bin/env ruby
# Terminal Environment Master Installer
# Author: Joshua Michael Hall
# License: MIT
# Date: April 4, 2025

require 'fileutils'
require 'optparse'

# Color definitions for terminal output
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
SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))
BIN_DIR = File.join(SCRIPT_DIR, 'bin')
VERSION = '0.2.0'

# Installation modes
MODES = {
  full: 'Full installation (all components)',
  minimal: 'Minimal update (configurations only)',
  core: 'Core components only',
  zsh: 'Zsh configuration only',
  nvim: 'Neovim configuration only',
  tmux: 'tmux configuration only',
  notes: 'Notes system only',
  fix: 'Fix permissions only'
}

# Installation components with their respective scripts
COMPONENTS = {
  core: %w[core_installer.rb core_troubleshooter.rb],
  zsh: %w[zsh_installer.rb zsh_troubleshooter.rb],
  nvim: %w[nvim_installer.rb nvim_troubleshooter.rb],
  tmux: %w[tmux_installer.rb tmux_troubleshooter.rb],
  notes: %w[notes_installer.rb notes_troubleshooter.rb]
}

# Helper methods
def print_header(text)
  puts "\n#{"=" * 70}".blue
  puts "  #{text}".blue
  puts "#{"=" * 70}".blue
  puts
end

def run_script(script, args = [])
  script_path = File.join(BIN_DIR, script)
  
  unless File.exist?(script_path)
    puts "Error: Script not found: #{script_path}".red
    return false
  end

  unless File.executable?(script_path)
    puts "Making script executable: #{script_path}".yellow
    FileUtils.chmod('+x', script_path)
  end

  puts "Running: #{script} #{args.join(' ')}".blue
  system(script_path, *args)
  
  if $?.success?
    puts "✓ Successfully ran #{script}".green
    return true
  else
    puts "✗ Error executing #{script}".red
    return false
  end
end

def verify_component_scripts(component)
  COMPONENTS[component].each do |script|
    script_path = File.join(BIN_DIR, script)
    
    unless File.exist?(script_path)
      puts "Error: Required script not found: #{script_path}".red
      return false
    end
  end
  
  true
end

def verify_and_create_bin_dir
  unless Dir.exist?(BIN_DIR)
    puts "Creating bin directory: #{BIN_DIR}".yellow
    FileUtils.mkdir_p(BIN_DIR)
  end
  
  unless Dir.exist?(BIN_DIR)
    puts "Error: Failed to create bin directory".red
    return false
  end
  
  true
end

def parse_options
  options = { mode: nil, components: [] }
  
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: install.rb [options]"
    
    opts.on("--mode MODE", "Installation mode (#{MODES.keys.join(', ')})") do |mode|
      options[:mode] = mode.to_sym if MODES.key?(mode.to_sym)
    end
    
    opts.on("--component COMPONENT", "Install specific component (#{COMPONENTS.keys.join(', ')})") do |component|
      options[:components] << component.to_sym if COMPONENTS.key?(component.to_sym)
    end
    
    opts.on("--fix", "Fix permissions only") do
      options[:mode] = :fix
    end
    
    opts.on("--help", "Show this help message") do
      puts opts
      exit
    end
    
    opts.on("--version", "Show version") do
      puts "Terminal Environment Installer v#{VERSION}"
      exit
    end
  end
  
  parser.parse!
  
  options
end

def prompt_for_mode
  puts "Please select an installation mode:".blue
  
  MODES.each_with_index do |(mode, description), index|
    puts "  #{index + 1}. #{description}"
  end
  
  print "\nEnter your choice (1-#{MODES.size}): "
  choice = gets.chomp.to_i
  
  if choice.between?(1, MODES.size)
    MODES.keys[choice - 1]
  else
    puts "Invalid choice. Using 'full' mode.".yellow
    :full
  end
end

def run_component_installation(component, fix_mode = false)
  print_header("Installing #{component.to_s.capitalize} Component")
  
  return false unless verify_component_scripts(component)
  
  # Run installer
  installer_script = COMPONENTS[component][0]
  if fix_mode
    run_script(installer_script, ["--fix"])
  else
    run_script(installer_script)
  end
  
  # Run troubleshooter
  troubleshooter_script = COMPONENTS[component][1]
  run_script(troubleshooter_script, ["--fix"])
end

# Main function
def main
  # Print welcome message
  print_header("Terminal Environment Installer v#{VERSION}")
  puts "This script will set up your terminal development environment.".green
  puts "Make sure you have the following prerequisites installed:".yellow
  puts "  - Ruby"
  puts "  - Git"
  puts "  - Homebrew (for macOS)"
  puts
  
  # Create bin directory if it doesn't exist
  return 1 unless verify_and_create_bin_dir
  
  # Parse command line options
  options = parse_options
  
  # Prompt for mode if not specified
  options[:mode] ||= prompt_for_mode
  
  # Handle fix mode
  if options[:mode] == :fix
    print_header("Running Fix Mode")
    
    # Fix permissions for all scripts in bin directory
    Dir.glob(File.join(BIN_DIR, "*.rb")).each do |script|
      puts "Making script executable: #{script}".yellow
      FileUtils.chmod('+x', script)
    end
    
    # Run troubleshooters for all components in fix mode
    COMPONENTS.each do |component, scripts|
      troubleshooter = scripts[1]
      run_script(troubleshooter, ["--fix"])
    end
    
    puts "\nFix mode completed.".green
    return 0
  end
  
  # Handle specific components if requested
  if !options[:components].empty?
    options[:components].each do |component|
      run_component_installation(component, options[:mode] == :fix)
    end
    return 0
  end
  
  # Handle different installation modes
  case options[:mode]
  when :full
    print_header("Running Full Installation")
    
    # Run all component installers in the correct order
    success = true
    success &= run_component_installation(:core)
    success &= run_component_installation(:zsh)
    success &= run_component_installation(:nvim)
    success &= run_component_installation(:tmux)
    success &= run_component_installation(:notes)
    
    if success
      print_header("Full Installation Completed Successfully")
      puts "Your terminal development environment is now set up.".green
      puts "\nNext steps:".blue
      puts "1. Restart your terminal"
      puts "2. Run 'p10k configure' to customize your prompt"
      puts "3. Start using your new environment with 'wk dev' or 'wk notes'"
    else
      print_header("Installation Completed with Errors")
      puts "Some components may not have installed correctly.".red
      puts "Please check the error messages above.".yellow
    end
    
  when :minimal
    print_header("Running Minimal Update")
    
    # Run all component installers with minimal flag
    success = true
    COMPONENTS.each do |component, _|
      success &= run_component_installation(component, true)
    end
    
    if success
      print_header("Minimal Update Completed Successfully")
      puts "Your terminal development environment has been updated.".green
      puts "\nNext steps:".blue
      puts "1. Restart your terminal"
      puts "2. Start using your updated environment with 'wk dev' or 'wk notes'"
    else
      print_header("Update Completed with Errors")
      puts "Some components may not have updated correctly.".red
      puts "Please check the error messages above.".yellow
    end
    
  # Handle individual component modes
  when :core, :zsh, :nvim, :tmux, :notes
    run_component_installation(options[:mode])
  end
  
  0 # Return success
end

# Run the main function
exit main
