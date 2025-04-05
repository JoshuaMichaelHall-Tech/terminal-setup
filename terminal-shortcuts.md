# Terminal Environment Shortcuts Reference

> A complete reference guide for your terminal-centric workflow

## Table of Contents
- [System Navigation](#system-navigation)
- [Terminal (iTerm2)](#terminal-iterm2)
- [Zsh Navigation](#zsh-navigation)
- [Zsh Command Editing](#zsh-command-editing)
- [Zsh Command History](#zsh-command-history)
- [Zsh File Operations](#zsh-file-operations)
- [tmux Basics](#tmux-basics)
- [tmux Commands](#tmux-commands)
- [Neovim Basics](#neovim-basics)
- [Neovim Navigation](#neovim-navigation)
- [Neovim LSP Integration](#neovim-lsp-integration)
- [Git Aliases](#git-aliases)
- [Notes System](#notes-system)
- [Custom Functions](#custom-functions)

## System Navigation
- `Cmd + Space`: Spotlight search
- `Ctrl + Opt + Left/Right/Up/Down`: Position windows with Rectangle
- `Cmd + Tab`: Switch applications

## Terminal (iTerm2)
- `Cmd + T`: New tab
- `Cmd + D`: Split vertically
- `Cmd + Shift + D`: Split horizontally
- `Cmd + Opt + Left/Right/Up/Down`: Navigate between panes

## Zsh Navigation
- `cd -`: Navigate to previous directory
- `cd -<TAB>`: Show directory history with numbers
- `..`, `...`, `....`: Go up 1, 2, or 3 directories
- `/path/to/dir`: Navigate without typing 'cd' (AUTO_CD enabled)
- `dirs -v`: List directory stack with numbers (AUTO_PUSHD enabled)

## Zsh Command Editing
- `Ctrl+A/E`: Move to beginning/end of line
- `Ctrl+U/K`: Clear line before/after cursor
- `Ctrl+W`: Delete word before cursor
- `Alt+F/B`: Move forward/backward one word
- `Ctrl+R`: Search command history

## Zsh Command History
- `!!`: Repeat last command
- `!$`: Last argument of previous command
- `!*`: All arguments of previous command
- `!abc`: Run most recent command starting with 'abc'
- `^old^new`: Replace first occurrence of 'old' with 'new' in previous command

## Zsh File Operations
- `ls -l`: List files in long format
- `ll`: List in long format (alias for `ls -la`)
- `la`: List all including hidden (alias for `ls -a`)
- `ls *(.)`: List only regular files (EXTENDED_GLOB enabled)
- `ls *(/)`: List only directories
- `ls **/*.rb`: Recursively list all Ruby files

## tmux Basics
> Prefix key is `Ctrl + a`
- `Prefix + c`: Create new window
- `Prefix + n/p`: Next/previous window
- `Prefix + [number]`: Go to window [number]
- `Prefix + |`: Split vertically
- `Prefix + -`: Split horizontally
- `Prefix + Left/Right/Up/Down`: Navigate panes
- `Prefix + d`: Detach session
- `Prefix + [`: Enter copy mode (use vim keys to navigate)
- `Prefix + ]`: Paste from buffer

## tmux Commands
- `ta [name]`: Attach to session [name] (alias)
- `tls`: List sessions (alias)
- `tn [name]`: Create new session [name] (alias)
- `tk [name]`: Kill session [name] (alias)
- `dev`: Start or resume dev session (alias)
- `notes`: Start or resume notes session (alias)
- `wk dev`: Start unified dev session (function)
- `wk notes`: Start unified notes session (function)

## Neovim Basics
> Leader key is `Space`
- `<leader>e`: Toggle file explorer (NvimTree)
- `<leader>ff`: Find files with Telescope
- `<leader>fg`: Live grep with Telescope
- `<leader>fb`: Buffers with Telescope
- `<leader>w`: Save file
- `<leader>q`: Quit
- `<leader>h`: Clear search highlighting
- `<leader>?`: Show common key mappings

## Neovim Navigation
- `Ctrl + h/j/k/l`: Navigate between splits
- `gd`: Go to definition (LSP)
- `K`: Hover documentation (LSP)
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action
- `[d/]d`: Go to previous/next diagnostic

## Neovim LSP Integration
- `gd`: Go to definition
- `gr`: Go to references
- `K`: Show documentation
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action
- `<leader>f`: Format code

## Git Aliases
- `gs`: git status
- `ga`: git add
- `gc "message"`: git commit
- `gp`: git push
- `gl`: git pull
- `<leader>gs`: Open Git status (Fugitive)
- `<leader>gc`: Git commit (Fugitive)
- `<leader>gp`: Git push (Fugitive)

## Notes System
- `:Daily`: Create/edit today's daily note
- `:Project`: Create/edit a project note
- `:Learning`: Create/edit a learning note
- `<leader>fn`: Find notes files
- `<leader>fg`: Search within notes
- `<leader>fr`: Show recently modified notes

## Custom Functions
- `mcd [dir]`: Create directory and change to it
- `nvimf [pattern]`: Find and open file with Neovim
- `check-functions`: Verify that key functions are loaded
- `wk [dev|notes]`: Start a structured tmux session for development or notes
