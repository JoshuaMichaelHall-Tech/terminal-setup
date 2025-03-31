# Terminal Development Environment: Comprehensive Shortcuts Guide

> A comprehensive reference for your terminal-centric workflow using Zsh, Neovim, tmux, and related tools

## Table of Contents
- [System Navigation](#system-navigation)
- [Terminal (iTerm2)](#terminal-iterm2)
- [Rectangle Window Management](#rectangle-window-management)
- [Zsh Navigation](#zsh-navigation)
- [Zsh Command Editing](#zsh-command-editing)
- [Zsh Command History](#zsh-command-history)
- [Zsh File Operations](#zsh-file-operations)
- [Zsh File Globbing & Pattern Matching](#zsh-file-globbing--pattern-matching)
- [Zsh Advanced Features](#zsh-advanced-features)
- [tmux](#tmux)
- [tmux Commands](#tmux-commands)
- [Neovim Basics](#neovim-basics)
- [Neovim File Navigation](#neovim-file-navigation)
- [Neovim Editing](#neovim-editing)
- [Neovim LSP Integration](#neovim-lsp-integration)
- [Git Operations](#git-operations)
- [Development Workflows](#development-workflows)
- [Notes System](#notes-system)
- [Custom Functions](#custom-functions)
- [Productivity Tips](#productivity-tips)

## System Navigation
| Shortcut | Description |
|----------|-------------|
| `Cmd + Space` | Spotlight search |
| `Cmd + Tab` | Switch applications |
| `Cmd + ~` | Cycle through windows of the same application |
| `Cmd + Q` | Quit application |
| `Cmd + W` | Close window/tab |
| `Cmd + M` | Minimize window |
| `Cmd + H` | Hide application |
| `Cmd + Opt + H` | Hide all other applications |
| `Cmd + ,` | Open preferences for current application |
| `Cmd + Shift + 3` | Screenshot entire screen |
| `Cmd + Shift + 4` | Screenshot selected area |
| `Cmd + Shift + 5` | Screenshot options |
| `Ctrl + Up/Down` | Mission Control/App Exposé |
| `Ctrl + Left/Right` | Switch between spaces |

## Terminal (iTerm2)
| Shortcut | Description |
|----------|-------------|
| `Cmd + T` | New tab |
| `Cmd + D` | Split vertically |
| `Cmd + Shift + D` | Split horizontally |
| `Cmd + Opt + ←/→/↑/↓` | Navigate between panes |
| `Cmd + [number]` | Go to tab [number] |
| `Cmd + W` | Close current tab/pane |
| `Cmd + Shift + [/]` | Go to previous/next tab |

## Rectangle Window Management
| Shortcut | Description |
|----------|-------------|
| `Ctrl + Opt + ←` | Left half |
| `Ctrl + Opt + →` | Right half |
| `Ctrl + Opt + ↑` | Top half |
| `Ctrl + Opt + ↓` | Bottom half |
| `Ctrl + Opt + U` | Top left quarter |
| `Ctrl + Opt + I` | Top right quarter |
| `Ctrl + Opt + J` | Bottom left quarter |
| `Ctrl + Opt + K` | Bottom right quarter |
| `Ctrl + Opt + Enter` | Maximize |
| `Ctrl + Opt + C` | Center window |
| `Ctrl + Opt + F` | Full screen |
| `Ctrl + Opt + +` | Make larger |
| `Ctrl + Opt + -` | Make smaller |
| `Ctrl + Opt + /` | Next display |
| `Ctrl + Opt + Backspace` | Restore to original size/position |

## Zsh Navigation
| Command | Description |
|---------|-------------|
| `cd -` | Navigate to previous directory |
| `cd -<TAB>` | Show directory history with numbers |
| `cd -2` | Go to the second most recent directory |
| `..` | Go up one directory (alias) |
| `...` | Go up two directories (alias) |
| `....` | Go up three directories (alias) |
| `/path/to/directory` | Navigate to directory without typing 'cd' |
| `dirs -v` | List directory stack with numbers |
| `pushd directory` | Change to directory and add to stack |
| `popd` | Pop top directory from stack and change to it |

## Zsh Command Editing
| Shortcut | Description |
|----------|-------------|
| `Ctrl + A` | Move cursor to beginning of line |
| `Ctrl + E` | Move cursor to end of line |
| `Ctrl + U` | Clear line before cursor |
| `Ctrl + K` | Clear line after cursor |
| `Ctrl + W` | Delete word before cursor |
| `Alt + F` | Move forward one word |
| `Alt + B` | Move backward one word |
| `Alt + D` | Delete word after cursor |
| `Ctrl + Y` | Paste previously cut text |
| `Ctrl + _` | Undo last edit |
| `Ctrl + L` | Clear screen |
| `Ctrl + R` | Search command history |
| `Ctrl + G` | Escape from history search |

## Zsh Command History
| Command | Description |
|---------|-------------|
| `!!` | Repeat last command |
| `!$` | Last argument of previous command |
| `!*` | All arguments of previous command |
| `!abc` | Run most recent command starting with 'abc' |
| `!abc:p` | Print most recent command starting with 'abc' (without running) |
| `fc` | Open command history in editor |
| `history` | Show command history |
| `^old^new` | Replace first occurrence of 'old' with 'new' in previous command |
| `!!:gs/old/new` | Replace all occurrences of 'old' with 'new' in previous command |

## Zsh File Operations
| Command | Description |
|---------|-------------|
| `ls -l` | List files in long format |
| `ll` | List in long format (alias for `ls -la`) |
| `la` | List all including hidden files (alias for `ls -a`) |
| `mkdir -p dir1/dir2/dir3` | Create nested directories |
| `cp -r source destination` | Copy directories recursively |
| `rm -rf directory` | Remove directory and contents |
| `find . -name "*.rb"` | Find all Ruby files in current directory |
| `grep -r "text" .` | Recursively search for text |

## Zsh File Globbing & Pattern Matching
| Command | Description |
|---------|-------------|
| `ls *(.)` | List only regular files |
| `ls *(/)` | List only directories |
| `ls -l *(.m-7)` | List files modified in the last week |
| `ls *.txt~file.txt` | List all txt files except file.txt |
| `ls **/*.rb` | Recursively list all Ruby files |
| `ls -l ^*.rb` | List everything except Ruby files |
| `ls -l **/*(.)` | List all regular files in all subdirectories |
| `rm -rf *(/)` | Remove all subdirectories |
| `ls -l *(.L0)` | List empty files |

## Zsh Advanced Features
| Feature | Description |
|---------|-------------|
| **Zsh Options** | |
| `setopt AUTO_PUSHD` | Automatically pushd directories onto stack |
| `setopt PUSHD_IGNORE_DUPS` | Don't push duplicates onto directory stack |
| `setopt PUSHD_SILENT` | Don't print directory stack after pushd/popd |
| `setopt EXTENDED_GLOB` | Enable advanced pattern matching |
| `setopt AUTO_CD` | Type directory name to cd |
| **Process Management** | |
| `Ctrl+Z` | Suspend current process |
| `fg` | Resume suspended process in foreground |
| `bg` | Resume suspended process in background |
| `jobs` | List all jobs |
| `kill %1` | Kill job number 1 |
| **Redirection & Pipes** | |
| `command > file` | Redirect stdout to file (overwrite) |
| `command >> file` | Redirect stdout to file (append) |
| `command 2> file` | Redirect stderr to file |
| `command &> file` | Redirect both stdout and stderr to file |

## tmux
> Note: The prefix key is set to `Ctrl + a`

| Shortcut | Description |
|----------|-------------|
| `prefix + c` | Create new window |
| `prefix + ,` | Rename current window |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + [number]` | Go to window [number] |
| `prefix + \|` | Split vertically |
| `prefix + -` | Split horizontally |
| `prefix + ←/→/↑/↓` | Navigate between panes |
| `prefix + z` | Toggle pane zoom |
| `prefix + [` | Enter copy mode |
| `prefix + ]` | Paste from buffer |
| `prefix + d` | Detach from session |
| `prefix + s` | List sessions |
| `prefix + w` | List windows |
| `prefix + r` | Reload configuration |
| `prefix + I` | Install plugins |
| `prefix + Ctrl+←/→/↑/↓` | Resize pane |
| `prefix + x` | Kill pane |
| `prefix + &` | Kill window |

## tmux Commands
| Command | Description |
|---------|-------------|
| `ta [name]` | Attach to session [name] (alias) |
| `tls` | List sessions (alias) |
| `tn [name]` | Create new session [name] (alias) |
| `tk [name]` | Kill session [name] (alias) |
| `dev` | Start or resume dev session (alias) |
| `notes` | Start or resume notes session (alias) |
| `wk dev` | Start unified development session (function) |
| `wk notes` | Start unified notes session (function) |
| `tmux new -s [name]` | Create a new session named [name] |
| `tmux list-sessions` | List all tmux sessions |
| `tmux kill-session -t [name]` | Kill session named [name] |
| `tmux kill-server` | Kill all tmux sessions |

## Neovim Basics
> Note: The leader key is set to Space

| Shortcut | Description |
|----------|-------------|
| `v` | Open Neovim (alias) |
| `vi` | Open Neovim (alias) |
| `vim` | Open Neovim (alias) |
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>h` | Clear search highlighting |
| `<leader>?` | Show common key mappings |
| `:w` | Save file |
| `:q` | Quit |
| `:wq` | Save and quit |
| `:x` | Save and quit |
| `:qa` | Quit all |
| `:wqa` | Save all and quit |
| `i` | Enter insert mode |
| `Esc` or `Ctrl + [` | Return to normal mode |
| `v` | Enter visual mode |
| `V` | Enter visual line mode |
| `Ctrl + v` | Enter visual block mode |

## Neovim File Navigation
| Shortcut | Description |
|----------|-------------|
| `<leader>e` | Toggle file explorer (NvimTree) |
| `<leader>ff` | Find files with Telescope |
| `<leader>fg` | Live grep with Telescope |
| `<leader>fb` | Browse buffers with Telescope |
| `<leader>fh` | Search help with Telescope |
| `Ctrl + h/j/k/l` | Navigate between splits |
| `:e [file]` | Edit file |
| `:bnext` or `:bn` | Next buffer |
| `:bprev` or `:bp` | Previous buffer |
| `:bd` | Delete buffer |
| `gd` | Go to definition (LSP) |
| `Ctrl + o` | Jump to previous location |
| `Ctrl + i` | Jump to next location |

## Neovim Editing
| Shortcut | Description |
|----------|-------------|
| `dd` | Delete line |
| `yy` | Yank (copy) line |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `u` | Undo |
| `Ctrl + r` | Redo |
| `>` | Indent |
| `<` | Unindent |
| `.` | Repeat last command |
| `cc` | Change entire line |
| `cw` | Change word |
| `ci"` | Change inside quotes |
| `di(` | Delete inside parentheses |
| `/%pattern` | Search for pattern |
| `n` | Next search result |
| `N` | Previous search result |

## Neovim LSP Integration
| Shortcut | Description |
|----------|-------------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` | Go to previous diagnostic |
| `]d` | Go to next diagnostic |
| `<leader>f` | Format code |
| `:LspInfo` | Show LSP information |
| `:Mason` | Open Mason package manager |
| `:MasonUpdate` | Update Mason packages |

## Git Operations
| Command/Shortcut | Description |
|------------------|-------------|
| `gs` | Git status (alias) |
| `ga` | Git add (alias) |
| `gc "message"` | Git commit with message (alias) |
| `gp` | Git push (alias) |
| `gl` | Git pull (alias) |
| `<leader>gs` | Open Git status (Fugitive) |
| `<leader>gc` | Git commit (Fugitive) |
| `<leader>gp` | Git push (Fugitive) |
| `git checkout -b feature/name` | Create and switch to new branch |
| `git merge branch_name` | Merge branch into current branch |
| `git branch -d branch_name` | Delete branch |
| `git log` | Show commit history |
| `git diff` | Show changes |
| `git reset --hard HEAD` | Discard all changes since last commit |
| `git stash` | Stash changes |
| `git stash pop` | Apply stashed changes |

## Development Workflows
| Command | Description |
|---------|-------------|
| `wk dev` | Start or resume development workflow |
| `wk notes` | Start or resume notes workflow |
| `dev` | Start or resume dev session (alias) |
| `notes` | Start or resume notes session (alias) |
| `nvimf [pattern]` | Find and edit file with pattern using Neovim and FZF |

## Notes System
| Command | Description |
|---------|-------------|
| `:Daily` | Create or open today's daily note |
| `:Project` | Create or open a project note |
| `:Learning` | Create or open a learning note |
| `:Notes` | Change to notes directory |
| `:NotesEdit` | Open notes directory in editor |
| `:NotesFind` | Find notes with FZF |
| `:NotesGrep` | Search for text within notes |
| `:RecentNotes` | Show recently modified notes |
| `<leader>fn` | Find notes files |
| `<leader>fg` | Search within notes |
| `<leader>fr` | Show recently modified notes |
| `<leader>fd` | Create/edit today's daily note |
| `<leader>fp` | Create/edit a project note |
| `<leader>fl` | Create/edit a learning note |

## Custom Functions
| Function | Description |
|----------|-------------|
| `mcd [dir]` | Create directory and change to it |
| `nvimf [pattern]` | Find and open file with Neovim |
| `check-functions` | Verify that key functions are loaded |
| `wk [dev\|notes]` | Start a structured tmux session |

## Productivity Tips

1. **Use tmux sessions for context switching**:
   - `wk dev` for development work
   - `wk notes` for note-taking
   - `tmux detach` to leave a session running

2. **Master Zsh directory navigation**:
   - Use AUTO_PUSHD to build up directory stack
   - Navigate with `cd -<TAB>` to see recent directories
   - Use `..`, `...`, etc. for quick parent navigation

3. **Set up Zsh functions for common operations**:
   ```zsh
   # Create a function for complex workflows
   function deploy() {
     git add .
     git commit -m "$1"
     git push
     ssh user@server 'cd /path/to/repo && git pull'
   }
   ```

4. **Use Neovim marks for quick navigation**:
   ```
   ma   # Set mark 'a' at current position
   'a   # Jump to line of mark 'a'
   `a   # Jump to exact position of mark 'a'
   ```

5. **Create project-specific tmux layouts**:
   ```zsh
   # Add to your .zshrc
   function rails-dev() {
     tmux new-session -s rails -n editor -d
     tmux send-keys -t rails:editor 'cd ~/projects/rails-app' C-m
     tmux send-keys -t rails:editor 'nvim' C-m
     
     tmux new-window -t rails:1 -n server
     tmux send-keys -t rails:server 'cd ~/projects/rails-app' C-m
     tmux send-keys -t rails:server 'rails s' C-m
     
     tmux new-window -t rails:2 -n console
     tmux send-keys -t rails:console 'cd ~/projects/rails-app' C-m
     tmux send-keys -t rails:console 'rails c' C-m
     
     tmux select-window -t rails:editor
     tmux attach -t rails
   }
   ```

6. **Set up Zsh suffix aliases for file types**:
   ```zsh
   # Add to your .zshrc
   alias -s rb=nvim
   alias -s py=nvim
   alias -s js=nvim
   alias -s md=nvim
   
   # Now you can just type the filename to open it
   # example.rb will open in Neovim
   ```

7. **Use Zsh global aliases for command pipelines**:
   ```zsh
   # Add to your .zshrc
   alias -g G='| grep'
   alias -g L='| less'
   alias -g H='| head'
   alias -g T='| tail'
   
   # Usage:
   ps aux G ruby    # Lists ruby processes
   cat file.log L   # Views file with less
   ```

8. **Leverage FZF for fuzzy finding everywhere**:
   - `Ctrl+R` for history search
   - `Ctrl+T` for file search
   - `nvimf` function to find and edit files

Remember, mastery comes with practice. Focus on learning a few new shortcuts each week rather than trying to memorize everything at once.
