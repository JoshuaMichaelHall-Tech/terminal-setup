#!/usr/bin/env ruby
# Terminal Environment Minimal Update
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

TEMPLATE_DIRS = {
  notes_daily: File.join(CONFIG_DIRS[:notes], 'daily'),
  notes_projects: File.join(CONFIG_DIRS[:notes], 'projects'),
  notes_learning: File.join(CONFIG_DIRS[:notes], 'learning'),
  notes_templates: File.join(CONFIG_DIRS[:notes], 'templates')
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

# Main function for minimal update
def run_minimal_update
  print_header("Running Minimal Update")
  
  # Create backup
  backup_dir = create_backup_directory
  backup_existing_configs(backup_dir)
  
  # Create directories
  CONFIG_DIRS.each { |name, dir| create_directory(dir) }
  TEMPLATE_DIRS.each { |name, dir| create_directory(dir) }
  
  # Update Neovim configuration
  create_directory(File.join(CONFIG_DIRS[:nvim], 'lua'))
  create_directory(File.join(CONFIG_DIRS[:nvim], 'plugin'))
  create_nvim_plugins(CONFIG_FILES[:nvim_plugins])
  create_notes_vim(CONFIG_FILES[:notes_vim])
  
  # Update tmux configuration
  create_tmux_conf(CONFIG_FILES[:tmux_conf])
  
  # Set version file
  version_file = File.join(HOME_DIR, '.terminal_env_version')
  File.write(version_file, "version=0.1.0\ndate=#{Time.now.strftime('%Y-%m-%d')}\nmode=minimal")
  
  puts "\nMinimal update completed successfully!".green
  puts "\nNext steps:"
  puts "1. Restart your terminal"
  puts "2. Start using your updated environment with 'wk dev' or 'wk notes'"
end

# Run the minimal update
run_minimal_update
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