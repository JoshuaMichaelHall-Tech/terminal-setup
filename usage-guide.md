# Complete Usage Guide: Terminal-Centric Workflow

This comprehensive guide will help you master your terminal-centric workflow, combining development and notes capabilities using Neovim, tmux, and Zsh.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Session Management](#session-management)
3. [Development Workflow](#development-workflow)
4. [Notes System Workflow](#notes-system-workflow)
5. [Neovim Core Commands](#neovim-core-commands)
6. [Efficient Navigation](#efficient-navigation)
7. [Git Integration](#git-integration)
8. [Advanced Techniques](#advanced-techniques)
9. [Customization and Extension](#customization-and-extension)
10. [Tips and Best Practices](#tips-and-best-practices)

## Getting Started

### Starting Your Environment

Begin by launching your terminal application (iTerm2 recommended).

#### Development Session

To start or resume a development session:

```zsh
wk dev
```

This creates a specialized tmux session with windows for:
- **code (0)**: Main coding window
- **server (1)**: Running servers, tests, or databases
- **git (2)**: Git operations and version control

#### Notes Session

To start or resume your notes session:

```zsh
wk notes
```

This creates a specialized tmux session with windows for:
- **main (0)**: Repository overview
- **daily (1)**: Daily journals and logs
- **projects (2)**: Project documentation
- **learning (3)**: Study materials by topic

### Environment Check

Verify your environment is set up correctly:

```zsh
# Check function availability
check-functions

# Check that key plugins are loaded in Neovim
nvim --headless "+echo 'Plugins: ' . len(vim.fn.keys(require('lazy.core.config').plugins))" "+qa"

# Check tmux version and running sessions
tmux -V
tmux ls
```

## Session Management

### Working with tmux Sessions

| Command | Action |
|---------|--------|
| `wk dev` | Start or resume development session |
| `wk notes` | Start or resume notes session |
| `tls` | List all tmux sessions |
| `ta [name]` | Attach to session [name] |
| `tk [name]` | Kill session [name] |
| `prefix + d` | Detach from current session |
| `prefix + s` | List and select sessions |

### Window Management

| Command | Action |
|---------|--------|
| `prefix + c` | Create new window |
| `prefix + ,` | Rename current window |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + [number]` | Go to window [number] |
| `prefix + &` | Kill window |
| `prefix + w` | List and select windows |

### Pane Management

| Command | Action |
|---------|--------|
| `prefix + |` | Split vertically |
| `prefix + -` | Split horizontally |
| `prefix + Left/Right/Up/Down` | Navigate between panes |
| `prefix + z` | Toggle pane zoom |
| `prefix + x` | Kill pane |
| `prefix + q` | Show pane numbers |
| `prefix + Ctrl+Left/Right/Up/Down` | Resize pane |

## Development Workflow

### Project Setup

1. **Start development session**:
   ```zsh
   wk dev
   ```

2. **Navigate to your project directory**:
   ```zsh
   cd ~/projects/my-project
   ```

3. **Open project in Neovim**:
   ```zsh
   nvim
   ```

4. **Use NvimTree to explore project files**:
   Press `<leader>e` to toggle the file explorer

### Code Editing Workflow

1. **Find files with Telescope**:
   Press `<leader>ff` and type part of the filename

2. **Search within project**:
   Press `<leader>fg` to live grep for text

3. **Navigate with LSP**:
   - `gd` - Go to definition
   - `gr` - Go to references
   - `K` - Show documentation
   - `<leader>rn` - Rename symbol
   - `<leader>ca` - Code action

4. **Save and build**:
   - `<leader>w` - Save file
   - Switch to server window: `Ctrl-a 1`
   - Run build/test commands
   - Return to code window: `Ctrl-a 0`

### Running and Testing

1. **Switch to server window**:
   ```
   Ctrl-a 1
   ```

2. **Start your development server**:
   ```zsh
   # For Rails
   rails server
   
   # For Node.js
   npm start
   
   # For Python
   python manage.py runserver
   ```

3. **Split window for tests**:
   ```
   Ctrl-a |
   ```

4. **Run tests**:
   ```zsh
   # For Rails
   rspec
   
   # For Node.js
   npm test
   
   # For Python
   pytest
   ```

### Git Operations

1. **Switch to git window**:
   ```
   Ctrl-a 2
   ```

2. **Check status and stage changes**:
   ```zsh
   gs  # alias for git status
   ga .  # alias for git add .
   ```

3. **Commit and push changes**:
   ```zsh
   gc "Add new feature"  # alias for git commit -m
   gp  # alias for git push
   ```

4. **Alternatively, use Fugitive in Neovim**:
   - `<leader>gs` - Open Git status
   - In the status window:
     - `-` to stage/unstage files
     - `cc` to commit
     - `gp` to push

## Notes System Workflow

### Daily Notes

1. **Start notes session**:
   ```zsh
   wk notes
   ```

2. **Go to daily notes window**:
   ```
   Ctrl-a 1
   ```

3. **Create today's daily note**:
   ```
   # In Neovim
   :Daily
   ```

4. **Fill in sections**:
   - Focus Areas: What you plan to work on
   - Tasks: Things to accomplish
   - Notes: General observations
   - Progress: What you've achieved
   - Links: References to other notes or resources

5. **Save automatically syncs**:
   - `<leader>w` to save

### Project Notes

1. **Go to projects window**:
   ```
   Ctrl-a 2
   ```

2. **Create or edit a project note**:
   ```
   # In Neovim
   :Project
   ```

3. **When prompted, enter the project name**:
   - This creates or opens `~/notes/projects/[name]/notes.md`

4. **Alternative: Find existing project notes**:
   Press `<leader>fn` and search for the project name

### Learning Notes

1. **Go to learning window**:
   ```
   Ctrl-a 3
   ```

2. **Create a learning note**:
   ```
   # In Neovim
   :Learning
   ```

3. **When prompted**:
   - Enter topic (e.g., ruby, python)
   - Enter subject (e.g., classes, decorators)

4. **This creates or opens**:
   - `~/notes/learning/[topic]/[subject].md`

### Finding and Searching Notes

1. **Find notes files**:
   Press `<leader>fn` or run `:NotesFiles`

2. **Search within notes**:
   Press `<leader>fg` or run `:NotesGrep`

3. **View recently modified notes**:
   Press `<leader>fr` or run `:RecentNotes`

## Neovim Core Commands

### Basic Operations

| Command | Action |
|---------|--------|
| `:w` | Save file |
| `:q` | Quit |
| `:wq` or `:x` | Save and quit |
| `:qa` | Quit all |
| `:e [file]` | Edit file |
| `:sp [file]` | Split horizontally and open file |
| `:vsp [file]` | Split vertically and open file |
| `:bd` | Close buffer |
| `<leader>w` | Save file (custom mapping) |
| `<leader>q` | Quit (custom mapping) |
| `<leader>h` | Clear search highlighting (custom mapping) |

### Mode Switching

| Command | Action |
|---------|--------|
| `i` | Enter insert mode |
| `a` | Enter insert mode after cursor |
| `A` | Enter insert mode at end of line |
| `o` | Insert new line below and enter insert mode |
| `O` | Insert new line above and enter insert mode |
| `Esc` or `Ctrl + [` | Return to normal mode |
| `v` | Enter visual mode |
| `V` | Enter visual line mode |
| `Ctrl + v` | Enter visual block mode |

### File Navigation with Telescope

| Command | Action |
|---------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in all files) |
| `<leader>fb` | Search open buffers |
| `<leader>fh` | Search help tags |

### Notes System Commands

| Command | Action |
|---------|--------|
| `:Daily` | Create/edit today's daily note |
| `:Project` | Create/edit a project note |
| `:Learning` | Create/edit a learning note |
| `:Notes` | Change to notes directory |
| `:NotesEdit` | Open notes directory in editor |
| `:NotesFind` | Find notes with FZF |
| `:NotesFiles` | List all notes files |
| `:NotesGrep` | Search text within notes |
| `:RecentNotes` | Show recently modified notes |

## Efficient Navigation

### Vim Motions

| Motion | Action |
|--------|--------|
| `h/j/k/l` | Move left/down/up/right |
| `w` | Move to start of next word |
| `b` | Move backward to start of word |
| `e` | Move to end of word |
| `0` | Move to start of line |
| `$` | Move to end of line |
| `gg` | Go to top of file |
| `G` | Go to bottom of file |
| `{` | Jump to previous paragraph |
| `}` | Jump to next paragraph |
| `Ctrl + u` | Move half page up |
| `Ctrl + d` | Move half page down |
| `Ctrl + b` | Move page up |
| `Ctrl + f` | Move page down |
| `%` | Jump to matching bracket |
| `*` | Search for word under cursor |
| `#` | Search backward for word under cursor |
| `/pattern` | Search forward for pattern |
| `?pattern` | Search backward for pattern |
| `n` | Next search result |
| `N` | Previous search result |

### Terminal Navigation

| Command | Action |
|---------|--------|
| `cd -` | Go to previous directory |
| `cd -<TAB>` | Show directory history |
| `cd ..` or `..` | Go up one directory |
| `cd ...` or `...` | Go up two directories |
| `cd ....` or `....` | Go up three directories |
| `pushd directory` | Change to directory and add to stack |
| `popd` | Pop top directory from stack and change to it |
| `dirs -v` | List directory stack with numbers |

### Neovim Window Navigation

| Command | Action |
|---------|--------|
| `Ctrl + h` | Move to window left |
| `Ctrl + j` | Move to window below |
| `Ctrl + k` | Move to window above |
| `Ctrl + l` | Move to window right |
| `:resize +5` | Increase window height |
| `:resize -5` | Decrease window height |
| `:vertical resize +5` | Increase window width |
| `:vertical resize -5` | Decrease window width |

### Buffer Navigation

| Command | Action |
|---------|--------|
| `:bnext` or `:bn` | Next buffer |
| `:bprev` or `:bp` | Previous buffer |
| `:buffer [name]` | Switch to buffer by name |
| `:ls` | List all buffers |
| `:bd` | Delete current buffer |
| `:bd [num]` | Delete buffer by number |

### Using Marks

| Command | Action |
|---------|--------|
| `ma` | Set mark 'a' at current position |
| `'a` | Jump to line of mark 'a' |
| `` `a `` | Jump to exact position of mark 'a' |
| `:marks` | List all marks |

## Git Integration

### Command Line Git

| Command | Action |
|---------|--------|
| `gs` | Git status (alias) |
| `ga` | Git add (alias) |
| `gc "message"` | Git commit with message (alias) |
| `gp` | Git push (alias) |
| `gl` | Git pull (alias) |
| `git checkout -b feature/name` | Create and switch to new branch |
| `git branch -d branch_name` | Delete branch |
| `git merge branch_name` | Merge branch into current branch |
| `git stash` | Stash changes |
| `git stash pop` | Apply stashed changes |

### Fugitive (in Neovim)

| Command | Action |
|---------|--------|
| `<leader>gs` | Open Git status |
| `<leader>gc` | Git commit |
| `<leader>gp` | Git push |

In the Git status window:
- `-` to stage/unstage files
- `cc` to create a commit
- `ca` to amend previous commit
- `=` to show inline diff
- `dv` to view file diff in vertical split
- `?` to show help

### Common Git Workflows

#### Feature Branch Workflow

```zsh
# Create and checkout feature branch
git checkout -b feature/new-feature

# Make changes and commit
ga .
gc "Implement new feature"

# Push to remote
gp -u origin feature/new-feature

# When ready to merge
git checkout main
gl
git merge feature/new-feature
gp
```

#### Stashing Workflow

```zsh
# Stash current changes
git stash save "Work in progress"

# Switch branches
git checkout another-branch

# Do other work
# ...

# Return to original branch
git checkout original-branch

# Apply stashed changes
git stash pop
```

## Advanced Techniques

### Custom Zsh Functions

#### Using the `mcd` function

Create and change to a directory in one command:

```zsh
# Create project directory and navigate to it
mcd ~/projects/new-project

# Create nested directories
mcd ~/projects/client/frontend/components
```

#### Using the `nvimf` function

Find and open files with fuzzy matching:

```zsh
# Find and open files containing "controller"
nvimf controller

# Find and open files containing "user"
nvimf user

```

#### Using the `wk` Function

Create and manage specialized tmux sessions:

```zsh
# Create or resume development session
wk dev

# Create or resume notes session
wk notes

# Get usage help
wk
```

### Advanced Neovim Techniques

#### Text Objects

Vim text objects let you operate on semantic units:

| Command | Action |
|---------|--------|
| `diw` | Delete inside word |
| `ciw` | Change inside word |
| `yi"` | Yank (copy) inside double quotes |
| `da(` | Delete around parentheses (including them) |
| `ci{` | Change inside curly braces |
| `>at` | Indent a tag block (HTML/XML) |
| `=ap` | Auto-indent a paragraph |

#### Macros

Record and play back sequences of commands:

```
# Recording
qa     # Start recording to register 'a'
...    # Your commands
q      # Stop recording

# Playback
@a     # Play macro 'a' once
10@a   # Play macro 'a' 10 times
@@     # Repeat last played macro
```

#### Advanced Search and Replace

Global search and replace:

```
:%s/old/new/g           # Replace all occurrences in file
:%s/old/new/gc          # Replace with confirmation
:5,20s/old/new/g        # Replace between lines 5-20
:g/pattern/d            # Delete all lines matching pattern
:g!/pattern/d           # Delete all lines NOT matching pattern
:g/TODO/normal A [REVIEW]  # Append text to lines matching pattern
```

### Power User tmux

#### Session Management

Create a complex session setup script:

```zsh
# Add to your .zshrc
function fullstack() {
  # Create or attach to session
  if ! tmux has-session -t fullstack 2>/dev/null; then
    # Create session with window for frontend
    tmux new-session -d -s fullstack -n frontend -c ~/projects/app/frontend
    tmux send-keys -t fullstack:frontend 'nvim' C-m
    
    # Create window for backend
    tmux new-window -t fullstack:1 -n backend -c ~/projects/app/backend
    tmux send-keys -t fullstack:backend 'nvim' C-m
    
    # Create window for servers
    tmux new-window -t fullstack:2 -n servers -c ~/projects/app
    tmux split-window -h -t fullstack:servers
    tmux send-keys -t fullstack:servers.0 'cd frontend && npm start' C-m
    tmux send-keys -t fullstack:servers.1 'cd backend && rails s' C-m
    
    # Create window for tests
    tmux new-window -t fullstack:3 -n tests -c ~/projects/app
    
    # Select frontend window
    tmux select-window -t fullstack:frontend
  fi
  
  # Attach to session
  tmux attach -t fullstack
}
```

#### Copy Mode and Scrollback

Navigate and copy text from scrollback:

1. Enter copy mode: `prefix + [`
2. Navigate with vim keys
3. Start selection: `v` (or `Space` in older tmux versions)
4. End selection: `Enter`
5. Paste: `prefix + ]`

### Advanced Notes Techniques

#### Creating Links Between Notes

In your markdown notes, create links:

```markdown
# Project Note: API Integration

See also: [Authentication System](../auth-system/notes.md)

Related learning: [OAuth2 Basics](../../learning/security/oauth2.md)

Today's tasks: [2025-03-31](../../daily/2025-03-31.md)
```

#### Creating Tag Systems

Add tags to your notes for better organization:

```markdown
# Learning: Ruby Metaprogramming

Tags: #ruby #advanced #metaprogramming #reflection

## Objectives
...
```

Search for tags with:

```zsh
cd ~/notes
grep -r "#ruby" --include="*.md" .
```

Or in Neovim:

```
:NotesGrep "#ruby"
```

#### Setting Up Meeting Notes Template

Create a custom template in `~/notes/templates/meeting.md`:

```markdown
# Meeting: {{meeting_title}}

Date: {{date}}

## Attendees
- 

## Agenda
1. 
2. 
3. 

## Notes
- 

## Action Items
- [ ] 
- [ ] 

## Follow-up
- 
```

Add to your Neovim notes.vim plugin:

```vim
" Create a new meeting note
function! CreateMeetingNote()
  let l:title = input('Meeting title: ')
  if l:title == ''
    return
  endif
  
  let l:date = strftime('%Y-%m-%d')
  let l:meeting_dir = g:notes_dir . '/meetings'
  
  " Ensure directory exists
  if !EnsureDirectoryExists(l:meeting_dir)
    return
  endif
  
  let l:filename = l:date . '-' . substitute(tolower(l:title), ' ', '-', 'g') . '.md'
  let l:file_path = l:meeting_dir . '/' . l:filename
  execute 'edit ' . l:file_path
  
  " If file is new, populate with template
  if line('$') == 1 && getline(1) == ''
    let l:template_path = g:notes_dir . '/templates/meeting.md'
    if filereadable(l:template_path)
      let l:template = readfile(l:template_path)
      call setline(1, l:template)
      " Replace placeholders
      execute '%s/{{meeting_title}}/' . l:title . '/g'
      execute '%s/{{date}}/' . l:date . '/g'
    else
      echoerr "Template not found: " . l:template_path
    endif
  endif
endfunction

command! Meeting call CreateMeetingNote()
```

## Customization and Extension

### Customizing Neovim

#### Adding New Plugins

To add a new plugin, edit your `~/.config/nvim/lua/plugins.lua` file:

```lua
-- Add a new plugin entry
{
  'folke/which-key.nvim',
  config = function()
    require('which-key').setup {}
  end,
}
```

Next time you start Neovim, the plugin will be automatically installed.

#### Creating Custom Key Mappings

Add to your `init.lua`:

```lua
-- Add custom mappings
vim.keymap.set('n', '<leader>o', ':only<CR>', { noremap = true, silent = true }) -- Close other windows
vim.keymap.set('n', '<leader>bd', ':bd<CR>', { noremap = true, silent = true }) -- Close buffer
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { noremap = true, silent = true }) -- Next buffer
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { noremap = true, silent = true }) -- Previous buffer
```

#### Creating Custom Commands

Add to your `init.lua`:

```lua
-- Create a custom command
vim.api.nvim_create_user_command('Format', function()
  vim.lsp.buf.formatting_sync()
end, {})

-- Create a command with arguments
vim.api.nvim_create_user_command('Grep', function(opts)
  vim.fn.system('grep -r "' .. opts.args .. '" .')
end, { nargs = 1 })
```

### Customizing tmux

#### Custom Key Bindings

Edit your `~/.tmux.conf`:

```
# Custom key bindings
bind-key T new-window -n "Time" "date; read"
bind-key C new-window -n "Calendar" "cal -3; read"
bind-key S command-prompt -p "SSH to host:" "new-window -n '%1' 'ssh %1'"
```

Reload config with `prefix + r`.

#### Custom Status Bar

Edit your `~/.tmux.conf`:

```
# Status bar customization
set -g status-style bg=black,fg=white
set -g window-status-current-style bg=blue,fg=white,bold
set -g status-left "#[fg=green][#S] #[fg=yellow]W:#I #[fg=cyan]P:#P"
set -g status-right "#[fg=cyan]%d %b %R"
```

### Customizing Zsh

#### Adding New Aliases

Edit your `~/.zshrc`:

```zsh
# Git aliases
alias gmb='git merge-base'
alias grbm='git rebase -i $(git merge-base HEAD origin/main)'

# Project shortcuts
alias proj="cd ~/projects"
alias docs="cd ~/Documents"

# Quick edits
alias zshrc="nvim ~/.zshrc && source ~/.zshrc"
alias vimrc="nvim ~/.config/nvim/init.lua"
alias tmuxconf="nvim ~/.tmux.conf"
```

#### Creating Advanced Functions

Add to your `~/.zshrc`:

```zsh
# Create a new project with basic setup
new-project() {
  local project_name=$1
  local git_url=$2
  
  if [[ -z "$project_name" ]]; then
    echo "Usage: new-project <name> [git-url]"
    return 1
  fi
  
  mkdir -p ~/projects/$project_name
  cd ~/projects/$project_name
  
  # Create initial files
  touch README.md
  echo "# $project_name" > README.md
  mkdir -p src test
  
  # Initialize git
  git init
  
  # Add remote if provided
  if [[ -n "$git_url" ]]; then
    git remote add origin $git_url
  fi
  
  # Initial commit
  git add .
  git commit -m "Initial commit"
  
  # Open in editor
  nvim .
}

# Search and replace in multiple files
search-replace() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: search-replace <search-pattern> <replacement>"
    return 1
  fi
  
  grep -l "$1" $(find . -type f -not -path "*/node_modules/*" -not -path "*/\.git/*") | xargs sed -i '' "s/$1/$2/g"
}
```

#### Adding FZF Integration

Enhance your Zsh with FZF:

```zsh
# FZF key bindings and completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF enhancement - cd to directories with preview
function fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m --preview 'ls -la {}')
  cd "$dir"
}

# FZF history search with preview
function fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

# FZF process killer
function fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}
```

### Extending the Notes System

#### Creating a Weekly Review System

Add to your `~/.config/nvim/plugin/notes.vim`:

```vim
" Create a weekly review note
function! CreateWeeklyReview()
  let l:week = strftime('%Y-W%V')  " ISO week format
  let l:review_dir = g:notes_dir . '/reviews'
  
  " Ensure review directory exists
  if !EnsureDirectoryExists(l:review_dir)
    return
  endif
  
  let l:file_path = l:review_dir . '/weekly-' . l:week . '.md'
  execute 'edit ' . l:file_path
  
  " If file is new, populate with template
  if line('$') == 1 && getline(1) == ''
    " Find daily notes from this week
    let l:week_start = system('date -v-' . strftime('%u') . 'd +%Y-%m-%d')
    let l:week_start = substitute(l:week_start, '\n', '', '')
    let l:daily_notes = []
    
    for i in range(0, 6)
      let l:day = system('date -v' . l:week_start . ' -v+' . i . 'd +%Y-%m-%d')
      let l:day = substitute(l:day, '\n', '', '')
      let l:day_path = g:notes_dir . '/daily/' . l:day . '.md'
      if filereadable(l:day_path)
        call add(l:daily_notes, l:day_path)
      endif
    endfor
    
    " Create review template
    call setline(1, '# Weekly Review: ' . l:week)
    call append(1, '')
    call append(2, '## Accomplishments')
    call append(3, '- ')
    call append(4, '')
    call append(5, '## Challenges')
    call append(6, '- ')
    call append(7, '')
    call append(8, '## Learnings')
    call append(9, '- ')
    call append(10, '')
    call append(11, '## Next Week Goals')
    call append(12, '- ')
    call append(13, '')
    call append(14, '## Notes from the Week')
    
    let l:line = 15
    for note_path in l:daily_notes
      let l:day = fnamemodify(note_path, ':t:r')
      call append(l:line, '### ' . l:day)
      let l:note_content = readfile(note_path)
      let l:in_progress = 0
      let l:progress_content = []
      
      for line in l:note_content
        if line =~ '^## Progress'
          let l:in_progress = 1
        elseif line =~ '^##' && l:in_progress
          let l:in_progress = 0
        elseif l:in_progress && line !~ '^$'
          call add(l:progress_content, line)
        endif
      endfor
      
      if len(l:progress_content) > 0
        let l:line += 1
        for progress_line in l:progress_content
          call append(l:line, progress_line)
          let l:line += 1
        endfor
      else
        call append(l:line, 'No progress recorded.')
        let l:line += 1
      endif
      
      call append(l:line, '')
      let l:line += 1
    endfor
  endif
endfunction

command! WeeklyReview call CreateWeeklyReview()
```

Use with `:WeeklyReview` in Neovim.

## Tips and Best Practices

### General Workflow Tips

1. **Work in sessions**:
   - Create persistent tmux sessions for different contexts
   - Use `wk dev` and `wk notes` to switch contexts
   - Maintain separate contexts for separate projects

2. **Use keyboard for everything**:
   - Learn and use keyboard shortcuts
   - Avoid reaching for the mouse
   - Build muscle memory through practice

3. **Learn incrementally**:
   - Focus on a few new commands/shortcuts each week
   - Review the shortcuts reference regularly
   - Use `<leader>?` in Neovim to see common mappings

4. **Document your workflows**:
   - Create notes about your own shortcuts and commands
   - Document project-specific workflows
   - Update documentation as you refine your setup

### Neovim Best Practices

1. **Use text objects and operators**:
   - Learn the combinations (e.g., `ciw`, `da"`, `>ap`)
   - Think in terms of operations on text objects
   - Combine with counts for power (e.g., `d3w`, `y5j`)

2. **Use buffers efficiently**:
   - Instead of constantly opening/closing files
   - Navigate between buffers with `:bp` and `:bn`
   - Use `:ls` to see open buffers

3. **Leverage marks and jumps**:
   - Set marks at important positions
   - Use `Ctrl+o` and `Ctrl+i` to navigate through jump list
   - Use `'.` to jump to last edit position

4. **Customize for your workflow**:
   - Add mappings for frequent operations
   - Set options that match your preferences
   - Create custom commands for repeated tasks

5. **Keep plugins minimal**:
   - Only add plugins you understand and need
   - Configure them properly
   - Remove unused plugins to maintain speed

### tmux Best Practices

1. **Name your sessions and windows**:
   - Use descriptive names for sessions
   - Name windows based on their purpose
   - Makes navigation easier with multiple sessions

2. **Use pane layouts effectively**:
   - Vertical splits for code and documentation
   - Horizontal splits for terminals and logs
   - Zoom (`prefix + z`) when you need focus

3. **Use copy mode for scrollback**:
   - Enter copy mode (`prefix + [`) to view history
   - Navigate with vim keys
   - Copy text for use in other panes/windows

4. **Save and restore sessions**:
   - Use tmux-resurrect plugin
   - Save sessions before shutdown
   - Restore when you restart

5. **Use tmux scripting for complex setups**:
   - Create shell scripts for project setups
   - Automate window and pane creation
   - Configure starting directories and commands

### Zsh Best Practices

1. **Master directory navigation**:
   - Use AUTO_PUSHD and related options
   - Learn the directory stack (`dirs -v`)
   - Navigate with `cd -<number>`

2. **Use globbing and pattern matching**:
   - Learn extended glob patterns
   - Use qualifiers (e.g., `*(.)` for regular files)
   - Combine with pipes and redirection

3. **Create custom functions for repetitive tasks**:
   - Start simple and build up complexity
   - Add parameters for flexibility
   - Document with comments

4. **Leverage history effectively**:
   - Use `Ctrl+R` for history search
   - Use `!$` for last argument
   - Use history expansion (e.g., `!-2:0` for command of 2 commands ago)

5. **Set up completion properly**:
   - Enable case-insensitive completion
   - Configure completion styles
   - Add custom completions for your commands

### Notes System Best Practices

1. **Maintain consistent structure**:
   - Use templates for consistency
   - Follow the same format for similar notes
   - Create sections with clear headings

2. **Link notes together**:
   - Create references between related notes
   - Use relative paths in markdown links
   - Build a knowledge graph over time

3. **Use daily notes effectively**:
   - Start each day with a daily note
   - Review previous day's notes
   - Track tasks and progress

4. **Implement a review system**:
   - Weekly reviews to summarize progress
   - Monthly reviews to identify patterns
   - Quarterly reviews to set goals

5. **Search and retrieve efficiently**:
   - Add tags to notes (`#tag`)
   - Use full-text search with `:NotesGrep`
   - Create specialized search commands

### Common Anti-Patterns to Avoid

1. **Configuration hoarding**:
   - Adding plugins you don't use
   - Copying configurations you don't understand
   - Over-customizing without purpose

2. **Inefficient workflows**:
   - Constantly reaching for the mouse
   - Repeating the same keystrokes manually
   - Opening/closing files instead of using buffers

3. **Incomplete documentation**:
   - Setting up without documenting
   - Forgetting custom functions and shortcuts
   - Not updating docs when changing configs

4. **Nested tmux sessions**:
   - Running tmux inside another tmux session
   - Confusing prefix keys
   - Lost in layers of sessions

5. **Not backing up configurations**:
   - Losing custom settings
   - Inability to replicate environment
   - No version control for configurations

### Final Thoughts

Your terminal-centric environment is designed to be a complete development and notes workflow system. As you become more familiar with these tools and techniques, you'll develop your own preferences and workflows.

Remember that mastery comes through consistent practice. Start with the basics, gradually incorporate more advanced techniques, and periodically review and refine your workflow.

Keep this guide handy as a reference, and don't hesitate to explore the other documentation files:
- **zsh_essential_shortcuts.md**: Quick reference for common shortcuts
- **comprehensive-shortcuts.md**: Complete list of all available shortcuts
- **setup-guide.md**: Detailed installation and configuration instructions

Happy coding and note-taking!

