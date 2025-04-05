#!/usr/bin/env ruby
# Zsh Configuration Uninstaller
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
CONFIG_FILES = {
  zshrc: File.join(HOME_DIR, '.zshrc'),
  p10k: File.join(HOME_DIR, '.p10k.zsh')
}
OH_MY_ZSH_DIR = File.join(HOME_DIR, '.oh-my-zsh')
P10K_THEME_DIR = File.join(OH_MY_ZSH_DIR, 'custom/themes/powerlevel10k')
ZSH_PLUGINS_DIR = File.join(OH_MY_ZSH_DIR, 'custom/plugins')
ZSH_AUTOSUGGESTIONS_DIR = File.join(ZSH_PLUGINS_DIR, 'zsh-autosuggestions')
ZSH_SYNTAX_HIGHLIGHTING_DIR = File.join(ZSH_PLUGINS_DIR, 'zsh-syntax-highlighting')
VERSION = '0.2.0'

# Options parsing
options = { full: false, keep_data: true, force: false }

OptionParser.new do |opts|
  opts.banner = "Usage: zsh_uninstaller.rb [options]"
  
  opts.on("--full", "Full uninstallation (remove Oh My Zsh completely)") do
    options[:full] = true
  end
  
  opts.on("--no-keep-data", "Do not keep custom data") do
    options[:keep_data] = false
  end
  
  opts.on("--force", "Force uninstallation without confirmation") do
    options[:force] = true
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
  backup_dir = File.join(HOME_DIR, "zsh_uninstall_backup_#{timestamp}")
  
  FileUtils.mkdir_p(backup_dir)
  puts "Created backup directory: #{backup_dir}".green
  
  backup_dir
end

def backup_zsh_configs(backup_dir)
  print_header("Backing Up Existing Zsh Configurations")
  
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
  
  # Backup custom plugins if user added any
  if Dir.exist?(ZSH_PLUGINS_DIR)
    plugins_backup = File.join(backup_dir, 'plugins')
    FileUtils.mkdir_p(plugins_backup)
    
    # Find all custom plugins (ones we're not removing specifically)
    Dir.glob("#{ZSH_PLUGINS_DIR}/*").each do |plugin_dir|
      plugin_name = File.basename(plugin_dir)
      next if ['zsh-autosuggestions', 'zsh-syntax-highlighting'].include?(plugin_name)
      
      if File.directory?(plugin_dir)
        begin
          FileUtils.cp_r(plugin_dir, plugins_backup)
          puts "Backed up custom plugin: #{plugin_name}".green
        rescue => e
          puts "Failed to backup plugin #{plugin_name}: #{e.message}".red
        end
      end
    end
  end
  
  # Backup custom themes if user added any
  if Dir.exist?(File.join(OH_MY_ZSH_DIR, 'custom/themes'))
    themes_backup = File.join(backup_dir, 'themes')
    FileUtils.mkdir_p(themes_backup)
    
    # Find all custom themes (ones we're not removing specifically)
    Dir.glob("#{OH_MY_ZSH_DIR}/custom/themes/*").each do |theme_dir|
      theme_name = File.basename(theme_dir)
      next if theme_name == 'powerlevel10k'
      
      if File.directory?(theme_dir)
        begin
          FileUtils.cp_r(theme_dir, themes_backup)
          puts "Backed up custom theme: #{theme_name}".green
        rescue => e
          puts "Failed to backup theme #{theme_name}: #{e.message}".red
        end
      end
    end
  end
  
  puts "All existing Zsh configurations backed up to #{backup_dir}".green
  backup_dir
end

def remove_custom_configuration
  print_header("Removing Custom Configuration")
  success = true
  
  # Remove p10k config
  if File.exist?(CONFIG_FILES[:p10k])
    begin
      File.delete(CONFIG_FILES[:p10k])
      puts "Removed #{CONFIG_FILES[:p10k]}".green
    rescue => e
      puts "Failed to remove #{CONFIG_FILES[:p10k]}: #{e.message}".red
      success = false
    end
  else
    puts "No p10k config to remove".yellow
  end
  
  # Clean up .zshrc (don't delete but remove custom parts)
  if File.exist?(CONFIG_FILES[:zshrc])
    begin
      # Read existing content
      zshrc_content = File.read(CONFIG_FILES[:zshrc])
      
      # Create a backup before modifying
      backup_file = "#{CONFIG_FILES[:zshrc]}.bak.#{Time.now.strftime('%Y%m%d%H%M%S')}"
      File.write(backup_file, zshrc_content)
      puts "Created backup of .zshrc at #{backup_file}".green
      
      # Remove custom aliases, functions and settings sections
      zshrc_content.gsub!(/# ============ Aliases ============.*?# ============/m, '# ============')
      zshrc_content.gsub!(/# ============ Functions ============.*?# ============/m, '# ============')
      
      # Remove P10K theme setting
      zshrc_content.gsub!(/ZSH_THEME="powerlevel10k\/powerlevel10k"/, 'ZSH_THEME="robbyrussell"')
      
      # Remove reference to p10k.zsh
      zshrc_content.gsub!(/\[\[ ! -f ~\/\.p10k\.zsh \]\] \|\| source ~\/\.p10k\.zsh/, '')
      
      # Remove custom plugins
      zshrc_content.gsub!(/zsh-autosuggestions/, '')
      zshrc_content.gsub!(/zsh-syntax-highlighting/, '')
      
      # Clean up any double spaces or empty lines
      zshrc_content.gsub!(/\s+/, ' ')
      zshrc_content.gsub!(/\n\s*\n+/, "\n\n")
      
      # Write back modified content
      File.write(CONFIG_FILES[:zshrc], zshrc_content)
      puts "Cleaned up .zshrc".green
    rescue => e
      puts "Failed to clean up .zshrc: #{e.message}".red
      success = false
    end
  else
    puts "No .zshrc to clean up".yellow
  end
  
  success
end

def remove_plugins
  print_header("Removing Zsh Plugins")
  success = true
  
  # Remove zsh-autosuggestions
  if Dir.exist?(ZSH_AUTOSUGGESTIONS_DIR)
    begin
      FileUtils.rm_rf(ZSH_AUTOSUGGESTIONS_DIR)
      puts "Removed zsh-autosuggestions plugin".green
    rescue => e
      puts "Failed to remove zsh-autosuggestions: #{e.message}".red
      success = false
    end
  else
    puts "zsh-autosuggestions plugin not found".yellow
  end
  
  # Remove zsh-syntax-highlighting
  if Dir.exist?(ZSH_SYNTAX_HIGHLIGHTING_DIR)
    begin
      FileUtils.rm_rf(ZSH_SYNTAX_HIGHLIGHTING_DIR)
      puts "Removed zsh-syntax-highlighting plugin".green
    rescue => e
      puts "Failed to remove zsh-syntax-highlighting: #{e.message}".red
      success = false
    end
  else
    puts "zsh-syntax-highlighting plugin not found".yellow
  end
  
  success
end

def remove_powerlevel10k
  print_header("Removing Powerlevel10k Theme")
  
  if Dir.exist?(P10K_THEME_DIR)
    begin
      FileUtils.rm_rf(P10K_THEME_DIR)
      puts "Removed Powerlevel10k theme".green
      return true
    rescue => e
      puts "Failed to remove Powerlevel10k theme: #{e.message}".red
      return false
    end
  else
    puts "Powerlevel10k theme not found".yellow
    return true
  end
end

def remove_oh_my_zsh
  print_header("Removing Oh My Zsh")
  
  if Dir.exist?(OH_MY_ZSH_DIR)
    begin
      FileUtils.rm_rf(OH_MY_ZSH_DIR)
      puts "Removed Oh My Zsh".green
      return true
    rescue => e
      puts "Failed to remove Oh My Zsh: #{e.message}".red
      return false
    end
  else
    puts "Oh My Zsh not found".yellow
    return true
  end
end

# Main function
def main
  print_header("Zsh Configuration Uninstaller v#{VERSION}")
  
  puts "This script will remove Zsh customizations installed by the terminal-setup project.".yellow
  puts "Running in#{options[:full] ? ' full' : ' soft'} uninstall mode.".yellow
  
  unless options[:force]
    print "Are you sure you want to proceed? (y/n): "
    confirm = gets.chomp.downcase
    
    unless confirm == 'y' || confirm == 'yes'
      puts "Uninstall cancelled.".blue
      return 0
    end
  end
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_zsh_configs(backup_dir)
  
  success = true
  
  # Remove custom configuration
  success &= remove_custom_configuration
  
  # Remove plugins
  success &= remove_plugins
  
  # Remove Powerlevel10k theme
  success &= remove_powerlevel10k
  
  # Remove Oh My Zsh if doing a full uninstall
  if options[:full]
    success &= remove_oh_my_zsh
  end
  
  if success
    print_header("Uninstallation Completed Successfully")
    puts "Zsh configuration has been removed.".green
    puts "Your original configurations were backed up to: #{backup_dir}".green
    
    if options[:full]
      puts "\nYou may want to switch back to bash as your default shell:".yellow
      puts "  chsh -s /bin/bash".yellow
    else
      puts "\nOh My Zsh remains installed with default configuration.".yellow
      puts "You may want to run 'source ~/.zshrc' to reload your shell.".yellow
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