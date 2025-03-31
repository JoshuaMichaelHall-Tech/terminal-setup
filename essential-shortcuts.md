# Terminal Development Environment: Essential Shortcuts

> A concise reference for your Zsh, Neovim, and tmux workflow

## System Navigation
- `Cmd + Space`: Spotlight search
- `Ctrl + Opt + ←/→/↑/↓`: Position windows with Rectangle
- `Cmd + Tab`: Switch applications

## Terminal (iTerm2)
- `Cmd + T`: New tab
- `Cmd + D`: Split vertically
- `Cmd + Shift + D`: Split horizontally
- `Cmd + Opt + ←/→/↑/↓`: Navigate between panes

## Zsh Navigation
- `cd -`: Navigate to previous directory
- `cd -<TAB>`: Show directory history with numbers
- `..`, `...`, `....`: Go up 1, 2, or 3 directories
- `/path/to/dir`: Navigate without typing 'cd'

## Zsh Command Editing
- `Ctrl+A/E`: Move to beginning/end of line
- `Ctrl+U/K`: Clear line before/after cursor
- `Ctrl+W`: Delete word before cursor
- `Ctrl+R`: Search command history

## tmux
> Prefix key is `Ctrl + a`
- `prefix + c`: Create new window
- `prefix + n/p`: Next/previous window
- `prefix + |`: Split vertically
- `prefix + -`: Split horizontally
- `prefix + ←/→/↑/↓`: Navigate panes
- `prefix + d`: Detach session

## Neovim Basics
> Leader key is `Space`
- `<leader>e`: Toggle file explorer
- `<leader>ff`: Find files with Telescope
- `<leader>fg`: Live grep with Telescope
- `<leader>w`: Save file
- `<leader>q`: Quit

## Neovim Navigation
- `Ctrl + h/j/k/l`: Navigate between splits
- `gd`: Go to definition (LSP)
- `K`: Hover documentation (LSP)
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action

## Git Aliases
- `gs`: git status
- `ga`: git add
- `gc "message"`: git commit
- `gp`: git push
- `gl`: git pull

## Development Workflows
- `dev`: Start/resume dev session
- `notes`: Start/resume notes session
- `ta SESSION`: Attach to tmux session
- `tls`: List tmux sessions
- `tn NAME`: Create new tmux session

## Zsh File Operations
- `ll`: List in long format (alias for `ls -la`)
- `la`: List all including hidden (alias for `ls -a`)
- `ls *(.)`: List only regular files
- `ls *(/)`: List only directories
- `ls **/*.rb`: Recursively list all Ruby files
