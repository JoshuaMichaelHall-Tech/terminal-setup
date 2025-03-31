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
| **Suffix Aliases** | |
| `example.rb` | Open with Neovim (with alias in .zshrc) |
| `example.py` | Open with Neovim (with alias in .zshrc) |
| `example.js` | Open with Neovim (with alias in .zshrc) |
| **Global Aliases** | |
| `command G pattern` | Pipe output to grep (with alias in .zshrc) |
| `command L` | Pipe output to less (with alias in .zshrc) |
| `command H` | Pipe output to head (with alias in .zshrc) |
| `command T` | Pipe output to tail (with alias in .zshrc) |
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

## tmux Commands
| Command | Description |
|---------|-------------|
| `ta [name]` | Attach to session [name] (alias) |
| `tls` | List sessions (alias) |
| `tn [name]` | Create new session [name] (alias) |
| `tk [name]` | Kill session [name] (alias) |
| `dev` | Start or resume dev session (alias) |
| `notes` | Start or resume notes session (alias) |
| `tmux new -s fullstack` | Create a new full-stack development session |

## Neovim Basics
> Note: The leader key is set to Space

| Shortcut | Description |
|----------|-------------|
| `v` | Open Neovim (alias) |
| `vi` | Open Neovim (alias) |
| `vim` | Open Neovim (alias) |
| `<leader>w` | Save file |
| `<leader>q` | Quit |
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

## Development Workflows
| Command | Description |
|---------|-------------|
| `dev` | Start or resume main development session |
| `notes` | Start or resume notes session |
| `tmux new -s fullstack` | Create a new full-stack development session |
| `<leader>wn` | Create new Vimwiki page |
| `<leader>w<leader>i` | Create daily journal in Vimwiki |

## Productivity Tips

1. **Create Zsh aliases for common operations**:
   ```zsh
   # Add to your .zshrc
   alias dev='tmux attach -t dev || tmux new -s dev'
   alias gc='git commit -m'
   alias gst='git status'
   ```

2. **Use Zsh functions for complex workflows**:
   ```zsh
   # Add to your .zshrc
   function webdev() {
     tmux new-session -s webdev -n editor -d
     tmux split-window -h -t webdev:editor
     tmux split-window -v -t webdev:editor.2
     tmux new-window -n server -t webdev
     tmux send-keys -t webdev:server 'cd ~/projects/current && npm start' C-m
     tmux select-window -t webdev:editor
     tmux attach -t webdev
   }
   ```

3. **Zsh Configuration**:
   ```zsh
   # Add to your .zshrc
   setopt AUTO_PUSHD          # Push directories onto directory stack
   setopt PUSHD_IGNORE_DUPS   # Don't push duplicates
   setopt PUSHD_SILENT        # Don't print directory stack
   setopt EXTENDED_GLOB       # Use extended globbing
   setopt AUTO_CD             # Type directory name to cd
   ```

4. **Useful Functions**:
   ```zsh
   # Create and change to directory in one command
   mcd() {
     mkdir -p $1 && cd $1
   }
   
   # Find and open file with Neovim
   nvimf() {
     nvim $(find . -name "*$1*" | fzf)
   }
   ```

Remember, mastery takes time—focus on learning a few new shortcuts each week rather than trying to memorize everything at once.
