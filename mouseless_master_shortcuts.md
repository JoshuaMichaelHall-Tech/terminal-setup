# Terminal Development Environment Shortcut Master Sheet

> A comprehensive reference for keyboard shortcuts and commands for the full-stack terminal development environment using Zsh, Neovim, tmux, and Git.

## Table of Contents
- [System Navigation](#system-navigation)
- [Terminal (iTerm2)](#terminal-iterm2)
- [Zsh Navigation](#zsh-navigation)
- [Zsh Command Editing](#zsh-command-editing)
- [Zsh Command History](#zsh-command-history)
- [Zsh File Operations](#zsh-file-operations)
- [tmux](#tmux)
- [Neovim Basics](#neovim-basics)
- [Neovim File Navigation](#neovim-file-navigation)
- [Neovim Editing](#neovim-editing)
- [Neovim LSP Integration](#neovim-lsp-integration)
- [Git Operations](#git-operations)
- [Development Workflows](#development-workflows)

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
| `F11` | Show desktop |

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
| `Ctrl + Opt + Shift + /` | Previous display |
| `Ctrl + Opt + Shift + ←` | Move to left display |
| `Ctrl + Opt + Shift + →` | Move to right display |
| `Ctrl + Opt + Backspace` | Restore to original size/position |

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
| `Ctrl + R` | Search command history |
| `Ctrl + G` | Escape from history search |
| `Ctrl + L` | Clear screen |

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

## Zsh File Operations
| Command | Description |
|---------|-------------|
| `ls *(.)` | List only regular files |
| `ls *(/)` | List only directories |
| `ls -l *(.m-7)` | List files modified in the last week |
| `ls *.txt~file.txt` | List all txt files except file.txt |
| `ls **/*.rb` | Recursively list all Ruby files |
| `ll` | List in long format (alias for `ls -la`) |
| `la` | List all including hidden files (alias for `ls -a`) |
| `mkdir -p dir1/dir2/dir3` | Create nested directories |

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

### tmux Commands
| Command | Description |
|---------|-------------|
| `ta [name]` | Attach to session [name] (alias) |
| `tls` | List sessions (alias) |
| `tn [name]` | Create new session [name] (alias) |
| `tk [name]` | Kill session [name] (alias) |
| `dev` | Start or resume dev session (alias) |
| `notes` | Start or resume notes session (alias) |

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

## Zsh Advanced Features
| Feature | Description |
|---------|-------------|
| `setopt AUTO_PUSHD` | Push directories onto directory stack |
| `setopt PUSHD_IGNORE_DUPS` | Don't push duplicates |
| `setopt PUSHD_SILENT` | Don't print the directory stack |
| `setopt EXTENDED_GLOB` | Use extended globbing |
| `alias -g G='| grep'` | Global alias for piping to grep |
| `alias -s rb=nvim` | Suffix alias to open .rb files with nvim |

---

This shortcut sheet covers the essential keyboard shortcuts and commands for the terminal development environment. For more detailed information, refer to the documentation and tutorial files in the repository.

For custom keybindings and configurations, check your personal:
- `~/.zshrc` for Zsh configuration
- `~/.tmux.conf` for tmux configuration
- `~/.config/nvim/init.lua` for Neovim configuration