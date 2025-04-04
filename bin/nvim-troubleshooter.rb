#!/usr/bin/env ruby
# Neovim Configuration Troubleshooter
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
  nvim: File.join(HOME_DIR, '.config/nvim'),
  nvim_data: File.join(HOME_DIR, '.local/share/nvim'),
  undodir: File.join(HOME_DIR, '.vim/undodir')
}
CONFIG_SUBDIRS = {
  lua: File.join(CONFIG_DIRS[:nvim], 'lua'),
  plugin: File.join(CONFIG_DIRS[:nvim], 'plugin'),
  colors: File.join(CONFIG_DIRS[:nvim], 'colors'),
  syntax: File.join(CONFIG_DIRS[:nvim], 'syntax'),
  ftplugin: File.join(CONFIG_DIRS[:nvim], 'ftplugin'),
  after: File.join(CONFIG_DIRS[:nvim], 'after')
}
CONFIG_FILES = {
  init: File.join(CONFIG_DIRS[:nvim], 'init.lua'),
  plugins: File.join(CONFIG_SUBDIRS[:lua], 'plugins.lua'),
  settings: File.join(CONFIG_SUBDIRS[:lua], 'settings.lua'),
  keymaps: File.join(CONFIG_SUBDIRS[:lua], 'keymaps.lua'),
  notes_vim: File.join(CONFIG_SUBDIRS[:plugin], 'notes.vim')
}
LAZY_DIR = File.join(CONFIG_DIRS[:nvim_data], 'lazy/lazy.nvim')
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
  opts.banner = "Usage: nvim_troubleshooter.rb [options]"
  
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


def create_file(file, content)
  create_directory(File.dirname(file))
  
  begin
    File.write(file, content)
    puts "✓ Created file: #{file}".green
    return true
  rescue StandardError => e
    puts "✗ Error creating file #{file}: #{e.message}".red
    return false
  end
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

# Configuration file creation functions
def create_init_lua(file)
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

    -- Load core configuration files
    require('settings')  -- Basic Vim settings
    require('keymaps')   -- Key mappings
    require('plugins')   -- Plugin configurations

    -- Notes system
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/plugin/notes.vim')

    -- ============ LSP Server Naming Guide ============
    -- When configuring Mason LSP, use these server names:
    -- Ruby: ruby_ls
    -- TypeScript: tsserver
    -- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
  INIT
  
  create_file(file, content)
end

def create_settings_lua(file)
  content = <<~SETTINGS
    -- Terminal Development Environment Neovim Settings

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

    -- File type specific settings
    vim.cmd('filetype plugin indent on')
    vim.cmd('syntax enable')

    -- Set proper terminal colors
    vim.opt.termguicolors = true

    -- Better completion experience
    vim.opt.completeopt = {'menuone', 'noselect'}

    -- Better searching
    vim.opt.ignorecase = true
    vim.opt.smartcase = true

    -- Clipboard
    vim.opt.clipboard = 'unnamedplus'

    -- Split behavior
    vim.opt.splitright = true
    vim.opt.splitbelow = true

    -- Command line
    vim.opt.wildmenu = true
    vim.opt.wildmode = 'longest:full,full'

    -- Pum (popup menu)
    vim.opt.pumheight = 10
    vim.opt.pumblend = 10

    -- Visual
    vim.opt.showmode = false
    vim.opt.showcmd = true
    vim.opt.cmdheight = 1
    vim.opt.laststatus = 3 -- Global statusline
    vim.opt.list = true
    vim.opt.listchars = { tab = '→ ', trail = '·', extends = '›', precedes = '‹', nbsp = '␣' }
    vim.opt.showbreak = '↪ '
    vim.opt.conceallevel = 0

    -- Performance
    vim.opt.hidden = true
    vim.opt.history = 500
    vim.opt.timeoutlen = 250
    vim.opt.updatetime = 100
    vim.opt.redrawtime = 1500
    vim.opt.lazyredraw = true

    -- Formatting
    vim.opt.formatoptions = vim.opt.formatoptions
      - 'a' -- Auto formatting
      - 't' -- Auto wrap text
      + 'c' -- Auto wrap comments
      + 'q' -- Allow formatting comments with gq
      - 'o' -- O and o don't continue comments
      + 'r' -- Continue comments after return
      + 'n' -- Recognize numbered lists
      + '2' -- Use second line indent for paragraph
      - 'l' -- Long lines not broken in insert mode
      + 'j' -- Remove comment leader when joining lines
  SETTINGS
  
  create_file(file, content)
end

def create_keymaps_lua(file)
  content = <<~KEYMAPS
    -- Terminal Development Environment Neovim Key Mappings

    -- ============ Key mappings ============
    -- Better window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h')
    vim.keymap.set('n', '<C-j>', '<C-w>j')
    vim.keymap.set('n', '<C-k>', '<C-w>k')
    vim.keymap.set('n', '<C-l>', '<C-w>l')

    -- Resize windows with arrows
    vim.keymap.set('n', '<C-Up>', ':resize -2<CR>')
    vim.keymap.set('n', '<C-Down>', ':resize +2<CR>')
    vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>')
    vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>')

    -- Basic utilities
    vim.keymap.set('n', '<leader>w', ':w<CR>')   -- Save
    vim.keymap.set('n', '<leader>q', ':q<CR>')   -- Quit
    vim.keymap.set('n', '<leader>h', ':nohl<CR>') -- Clear search highlighting

    -- Buffer navigation
    vim.keymap.set('n', '<leader>bn', ':bnext<CR>')    -- Next buffer
    vim.keymap.set('n', '<leader>bp', ':bprevious<CR>') -- Previous buffer
    vim.keymap.set('n', '<leader>bd', ':bdelete<CR>')   -- Delete buffer

    -- Tab navigation
    vim.keymap.set('n', '<leader>tn', ':tabnext<CR>')     -- Next tab
    vim.keymap.set('n', '<leader>tp', ':tabprevious<CR>') -- Previous tab
    vim.keymap.set('n', '<leader>tc', ':tabnew<CR>')      -- Create new tab
    vim.keymap.set('n', '<leader>tx', ':tabclose<CR>')    -- Close tab

    -- Keep visual selection when indenting
    vim.keymap.set('v', '<', '<gv')
    vim.keymap.set('v', '>', '>gv')

    -- Move lines up and down in visual mode
    vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
    vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

    -- Keep cursor centered when scrolling
    vim.keymap.set('n', '<C-d>', '<C-d>zz')
    vim.keymap.set('n', '<C-u>', '<C-u>zz')

    -- Keep cursor centered when searching
    vim.keymap.set('n', 'n', 'nzzzv')
    vim.keymap.set('n', 'N', 'Nzzzv')

    -- Paste without yanking the replaced text
    vim.keymap.set('x', '<leader>p', "\"_dP")

    -- Quick access to common commands
    vim.keymap.set('n', '<leader>/', ':Telescope live_grep<CR>')
    vim.keymap.set('n', '<leader>.', ':Telescope find_files<CR>')
    vim.keymap.set('n', '<leader>,', ':Telescope buffers<CR>')

    -- Terminal mappings
    vim.keymap.set('t', '<Esc>', '<C-\\><C-n>') -- Exit terminal mode

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
  KEYMAPS
  
  create_file(file, content)
end

def create_plugins_lua(file)
  content = <<~PLUGINS
    -- Terminal Development Environment Neovim Plugins

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

def create_notes_vim(file)
  # This function creates the notes.vim file with the notes system implementation
  # Content omitted for brevity - use the same content as in the nvim-installer.rb
  content = File.exist?("#{File.dirname(__FILE__)}/nvim_installer.rb") ? 
    File.read("#{File.dirname(__FILE__)}/nvim_installer.rb").match(/def create_notes_vim.*?content = <<~NOTES\n(.*?)  NOTES\n/m)[1] :
    "\" Notes System Plugin for Neovim (placeholder)\n"
  
  create_file(file, content)
end

# Troubleshooting functions
def check_nvim_installation
  print_header("Checking Neovim Installation")
  
  # Check if Neovim is installed
  if command_exists?('nvim')
    version, success = run_command('nvim --version')
    if success
      puts "✓ Neovim is installed: #{version.split("\n").first}".green
    else
      puts "✗ Neovim seems to be installed but version check failed".red
      return false
    end
  else
    puts "✗ Neovim is not installed".red
    if OPTIONS[:$1]
      puts "Attempting to install Neovim...".blue
      if command_exists?('brew')
        output, success = run_command('brew install neovim')
        if success && command_exists?('nvim')
          puts "✓ Neovim installed successfully".green
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
  
  true
end

def check_nvim_directories
  print_header("Checking Neovim Directories")
  
  all_dirs_ok = true
  
  # Check main directories
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
  
  # Check subdirectories
  CONFIG_SUBDIRS.each do |name, dir|
    if Dir.exist?(dir)
      puts "✓ #{name} subdirectory exists: #{dir}".green
    else
      puts "✗ #{name} subdirectory doesn't exist: #{dir}".red
      all_dirs_ok = false
      
      if OPTIONS[:$1]
        puts "Creating #{name} subdirectory...".blue
        if create_directory(dir)
          puts "✓ Created #{name} subdirectory".green
        else
          puts "✗ Failed to create #{name} subdirectory".red
        end
      end
    end
  end
  
  if !all_dirs_ok && !OPTIONS[:$1]
    puts "Run with --fix to create missing directories".yellow
  end
  
  all_dirs_ok
end

def check_nvim_configuration_files
  print_header("Checking Neovim Configuration Files")
  
  all_files_ok = true
  
  CONFIG_FILES.each do |name, file|
    if File.exist?(file)
      puts "✓ #{name} configuration file exists: #{file}".green
    else
      puts "✗ #{name} configuration file doesn't exist: #{file}".red
      all_files_ok = false
      
      if OPTIONS[:$1]
        puts "Creating #{name} configuration file...".blue
        case name
        when :init
          create_init_lua(file)
        when :settings
          create_settings_lua(file)
        when :keymaps
          create_keymaps_lua(file)
        when :plugins
          create_plugins_lua(file)
        when :notes_vim
          create_notes_vim(file)
        end
      end
    end
  end
  
  if !all_files_ok && !OPTIONS[:$1]
    puts "Run with --fix to create missing configuration files".yellow
  end
  
  all_files_ok
end

def check_plugin_manager
  print_header("Checking Neovim Plugin Manager")
  
  if Dir.exist?(LAZY_DIR)
    puts "✓ Lazy.nvim plugin manager is installed: #{LAZY_DIR}".green
    return true
  else
    puts "✗ Lazy.nvim plugin manager is not installed: #{LAZY_DIR}".red
    
    if OPTIONS[:$1]
      puts "Attempting to install Lazy.nvim...".blue
      parent_dir = File.dirname(LAZY_DIR)
      create_directory(parent_dir)
      
      install_cmd = "git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable #{LAZY_DIR}"
      output, success = run_command(install_cmd)
      
      if success && Dir.exist?(LAZY_DIR)
        puts "✓ Lazy.nvim installed successfully".green
        return true
      else
        puts "✗ Failed to install Lazy.nvim".red
        puts "  Manual installation will be attempted when Neovim is first started".yellow
        puts "  Lazy.nvim will be installed automatically when Neovim is first started if the init.lua configuration is correct".green
        return false
      end
    else
      puts "Run with --fix to install Lazy.nvim, or it will be installed automatically when Neovim is first started".yellow
      return false
    end
  end
end

def check_permissions
  print_header("Checking Neovim Directory Permissions")
  
  all_perms_ok = true
  
  # Check main directories
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      if File.stat(dir).mode & 0777 == 0755
        puts "✓ #{name} directory has correct permissions".green
      else
        puts "✗ #{name} directory has incorrect permissions".red
        all_perms_ok = false
        
        if OPTIONS[:$1]
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
  
  # Check subdirectories
  CONFIG_SUBDIRS.each do |name, dir|
    if Dir.exist?(dir)
      if File.stat(dir).mode & 0777 == 0755
        puts "✓ #{name} subdirectory has correct permissions".green
      else
        puts "✗ #{name} subdirectory has incorrect permissions".red
        all_perms_ok = false
        
        if OPTIONS[:$1]
          begin
            FileUtils.chmod(0755, dir)
            puts "✓ Fixed permissions for #{name} subdirectory".green
          rescue => e
            puts "✗ Failed to fix permissions for #{name} subdirectory: #{e.message}".red
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

def check_init_lua_content
  print_header("Checking init.lua Content")
  
  init_file = CONFIG_FILES[:init]
  if !File.exist?(init_file)
    puts "✗ init.lua doesn't exist, cannot check content".red
    return false
  end
  
  init_content = File.read(init_file)
  
  # Check for key components
  required_components = {
    "Lazy.nvim initialization" => "local lazypath = vim.fn.stdpath",
    "Settings load" => "require('settings')",
    "Keymaps load" => "require('keymaps')",
    "Plugins load" => "require('plugins')",
    "Notes system" => "source.*notes.vim"
  }
  
  missing_components = []
  required_components.each do |name, pattern|
    if init_content.match?(pattern)
      puts "✓ init.lua includes #{name}".green
    else
      puts "✗ init.lua is missing #{name}".red
      missing_components << name
    end
  end
  
  if !missing_components.empty?
    if OPTIONS[:$1]
      puts "Creating backup of existing init.lua and creating new one...".blue
      create_backup(init_file)
      create_init_lua(init_file)
      puts "✓ Created new init.lua with all required components".green
    else
      puts "Run with --fix to update init.lua with missing components".yellow
    end
    return false
  end
  
  true
end

# Main function
def main
  print_header("Neovim Configuration Troubleshooter v#{VERSION}")
  
  # Collect issues
  issues = []
  
  # Check Neovim installation
  puts "Checking Neovim installation...".blue
  nvim_ok = check_nvim_installation
  issues << "Neovim installation" unless nvim_ok
  
  # Check Neovim directories
  puts "Checking Neovim directories...".blue
  dirs_ok = check_nvim_directories
  issues << "Neovim directories" unless dirs_ok
  
  # Check Neovim configuration files
  puts "Checking Neovim configuration files...".blue
  files_ok = check_nvim_configuration_files
  issues << "Neovim configuration files" unless files_ok
  
  # Check plugin manager
  puts "Checking plugin manager...".blue
  plugin_manager_ok = check_plugin_manager
  issues << "Plugin manager" unless plugin_manager_ok
  
  # Check permissions
  puts "Checking permissions...".blue
  permissions_ok = check_permissions
  issues << "Permissions" unless permissions_ok
  
  # Check init.lua content
  puts "Checking init.lua content...".blue
  init_content_ok = check_init_lua_content
  issues << "init.lua content" unless init_content_ok
  
  # Final report
  print_header("Troubleshooting Summary")
  
  if issues.empty?
    puts "✓ All Neovim components are installed and configured correctly".green
  else
    puts "✗ Issues found in the following areas:".red
    issues.each_with_index do |issue, index|
      puts "  #{index + 1}. #{issue}".yellow
    end
    
    if OPTIONS[:$1]
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