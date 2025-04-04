#!/usr/bin/env ruby
# Neovim Configuration Installer
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
VERSION = '0.2.1'

# Parse options at the top level so it's available throughout the script
OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: fix-all-scripts.rb [options]"
  
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


# Options parsing
options = { minimal: false, fix: false }

OptionParser.new do |opts|
  opts.banner = "Usage: nvim_installer.rb [options]"
  
  opts.on("--minimal", "Minimal installation (config only)") do
    OPTIONS[:$1] = true
  end
  
  opts.on("--fix", "Fix mode (only fix existing installation)") do
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
  backup_dir = File.join(HOME_DIR, "nvim_env_backup_#{timestamp}")
  
  begin
    FileUtils.mkdir_p(backup_dir)
    puts "Created backup directory: #{backup_dir}".green
    return backup_dir
  rescue StandardError => e
    puts "Error creating backup directory #{backup_dir}: #{e.message}".red
    return backup_dir # Still return the intended path even if creation failed
  end
end


def backup_nvim_configs(backup_dir)
  print_header("Backing Up Existing Neovim Configuration")
  
  # Backup nvim config directory
  if Dir.exist?(CONFIG_DIRS[:nvim])
    nvim_backup = File.join(backup_dir, 'nvim')
    FileUtils.cp_r(CONFIG_DIRS[:nvim], nvim_backup)
    puts "Backed up Neovim config to #{nvim_backup}".green
  end
  
  puts "All existing Neovim configurations backed up to #{backup_dir}".green
end

# Installation functions
def install_neovim
  print_header("Installing/Updating Neovim")
  
  if command_exists?('nvim')
    version, _ = run_command('nvim --version')
    puts "Neovim is already installed: #{version.split("\n").first}".green
    
    if !OPTIONS[:$1]
      puts "Updating Neovim...".blue
      if command_exists?('brew')
        output, success = run_command('brew upgrade neovim')
        check_result("Updated Neovim", success)
      else
        puts "Homebrew not found, cannot automatically update Neovim".yellow
        puts "Please update Neovim manually if needed".yellow
      end
    end
    
    return true
  else
    puts "Neovim is not installed".red
    
    if !OPTIONS[:$1] && command_exists?('brew')
      puts "Installing Neovim...".blue
      output, success = run_command('brew install neovim')
      
      if success && command_exists?('nvim')
        version, _ = run_command('nvim --version')
        puts "Neovim installed successfully: #{version.split("\n").first}".green
        return true
      else
        puts "Failed to install Neovim".red
        puts "Please install Neovim manually with: brew install neovim".yellow
        return false
      end
    else
      puts "Please install Neovim manually with: brew install neovim".yellow
      return false
    end
  end
end

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
      if line('$') == 1 && getline(1) == ''
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
      if line('$') == 1 && getline(1) == ''
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
      if line('$') == 1 && getline(1) == ''
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

def install_lazy_nvim
  print_header("Installing Lazy.nvim Plugin Manager")
  
  lazy_dir = File.join(CONFIG_DIRS[:nvim_data], 'lazy/lazy.nvim')
  
  if Dir.exist?(lazy_dir)
    puts "Lazy.nvim is already installed, updating...".yellow
    Dir.chdir(lazy_dir) do
      run_command('git pull')
    end
    check_result("Updated Lazy.nvim")
    return true
  end
  
  puts "Installing Lazy.nvim...".blue
  parent_dir = File.dirname(lazy_dir)
  create_directory(parent_dir)
  
  install_cmd = "git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable #{lazy_dir}"
  output, success = run_command(install_cmd)
  
  if success
    puts "Lazy.nvim installed successfully".green
    return true
  else
    puts "Failed to install Lazy.nvim".red
    puts "Manual installation will be attempted when Neovim is first started".yellow
    return false
  end
end

def check_nvim_setup
  print_header("Checking Neovim Setup")
  
  # Check if Neovim is installed
  if command_exists?('nvim')
    version, _ = run_command('nvim --version')
    puts "Neovim is installed: #{version.split("\n").first}".green
  else
    puts "Neovim is not installed".red
    puts "Please install Neovim before continuing".yellow
    return false
  end
  
  # Check required directories
  success = true
  CONFIG_DIRS.each do |name, dir|
    if Dir.exist?(dir)
      puts "#{name} directory exists: #{dir}".green
    else
      puts "#{name} directory doesn't exist: #{dir}".yellow
      success = false
    end
  end
  
  CONFIG_SUBDIRS.each do |name, dir|
    if Dir.exist?(dir)
      puts "#{name} subdirectory exists: #{dir}".green
    else
      puts "#{name} subdirectory doesn't exist: #{dir}".yellow
      success = false
    end
  end
  
  # Check for required config files
  CONFIG_FILES.each do |name, file|
    if File.exist?(file)
      puts "#{name} configuration exists: #{file}".green
    else
      puts "#{name} configuration doesn't exist: #{file}".yellow
      success = false
    end
  end
  
  success
end

# Main installation functions
def run_full_install
  print_header("Running Full Neovim Installation")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_nvim_configs(backup_dir)
  
  # Install or update Neovim
  success = install_neovim
  
  # Create directories
  CONFIG_DIRS.each { |name, dir| success &= create_directory(dir) }
  CONFIG_SUBDIRS.each { |name, dir| success &= create_directory(dir) }
  
  # Create configuration files
  success &= create_init_lua(CONFIG_FILES[:init])
  success &= create_settings_lua(CONFIG_FILES[:settings])
  success &= create_keymaps_lua(CONFIG_FILES[:keymaps])
  success &= create_plugins_lua(CONFIG_FILES[:plugins])
  success &= create_notes_vim(CONFIG_FILES[:notes_vim])
  
  # Install Lazy.nvim plugin manager
  success &= install_lazy_nvim
  
  # Set version marker
  version_file = File.join(HOME_DIR, '.nvim_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}")
  
  success
end

def run_minimal_update
  print_header("Running Minimal Neovim Update")
  
  # Create backup first
  backup_dir = create_backup_directory
  backup_nvim_configs(backup_dir)
  
  # Create directories if they don't exist
  CONFIG_DIRS.each do |name, dir|
    create_directory(dir) unless Dir.exist?(dir)
  end
  
  CONFIG_SUBDIRS.each do |name, dir|
    create_directory(dir) unless Dir.exist?(dir)
  end
  
  # Ensure configuration files exist
  success = true
  CONFIG_FILES.each do |name, file|
    if !File.exist?(file)
      puts "#{name} configuration doesn't exist, creating...".yellow
      case name
      when :init
        success &= create_init_lua(file)
      when :settings
        success &= create_settings_lua(file)
      when :keymaps
        success &= create_keymaps_lua(file)
      when :plugins
        success &= create_plugins_lua(file)
      when :notes_vim
        success &= create_notes_vim(file)
      end
    end
  end
  
  # Update version marker
  version_file = File.join(HOME_DIR, '.nvim_version')
  File.write(version_file, "version=#{VERSION}\ndate=#{Time.now.strftime('%Y-%m-%d')}\nmode=minimal")
  
  success
end

def run_fix_mode
  print_header("Running Fix Mode for Neovim Configuration")
  
  # Check existing setup
  check_nvim_setup
  
  # Create directories if they don't exist
  CONFIG_DIRS.each do |name, dir|
    create_directory(dir) unless Dir.exist?(dir)
  end
  
  CONFIG_SUBDIRS.each do |name, dir|
    create_directory(dir) unless Dir.exist?(dir)
  end
  
  # Fix configuration files if needed
  success = true
  CONFIG_FILES.each do |name, file|
    if !File.exist?(file) || OPTIONS[:$1]
      puts "#{name} configuration needs to be created/updated...".yellow
      case name
      when :init
        backup_file(file) if File.exist?(file)
        success &= create_init_lua(file)
      when :settings
        backup_file(file) if File.exist?(file)
        success &= create_settings_lua(file)
      when :keymaps
        backup_file(file) if File.exist?(file)
        success &= create_keymaps_lua(file)
      when :plugins
        backup_file(file) if File.exist?(file)
        success &= create_plugins_lua(file)
      when :notes_vim
        backup_file(file) if File.exist?(file)
        success &= create_notes_vim(file)
      end
    end
  end
  
  # Fix plugin manager if needed
  lazy_dir = File.join(CONFIG_DIRS[:nvim_data], 'lazy/lazy.nvim')
  if !Dir.exist?(lazy_dir)
    success &= install_lazy_nvim
  end
  
  success
end

# Main entry point
def main
  print_header("Neovim Configuration Installer v#{VERSION}")
  
  if OPTIONS[:$1]
    success = run_fix_mode
  elsif OPTIONS[:$1]
    success = run_minimal_update
  else
    success = run_full_install
  end
  
  if success
    print_header("Neovim Configuration Installation Completed Successfully")
    puts "Your Neovim environment is now configured.".green
    puts "\nNext steps:".blue
    puts "1. Start Neovim with 'nvim'"
    puts "2. Wait for plugins to install automatically"
    puts "3. Use the notes system with :Daily, :Project, and :Learning commands"
  else
    print_header("Installation Completed with Errors")
    puts "Some components may not have installed correctly.".red
    puts "Please check the error messages above.".yellow
  end
  
  return success ? 0 : 1
end

# Run the script
exit main