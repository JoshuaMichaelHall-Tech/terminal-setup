# Zsh Essential Shortcuts

## Zsh Navigation
- `cd -` - Navigate to previous directory
- `cd -<TAB>` - Show directory history with numbers
- `cd -2` - Go to the second most recent directory
- `..` - Go up one directory (with alias from .zshrc)
- `...` - Go up two directories (with alias from .zshrc)
- `/path/to/directory` - Navigate to directory without typing 'cd'

## Zsh Command Editing
- `Ctrl+A` - Move cursor to beginning of line
- `Ctrl+E` - Move cursor to end of line
- `Ctrl+U` - Clear line before cursor
- `Ctrl+K` - Clear line after cursor
- `Ctrl+W` - Delete word before cursor
- `Alt+F` - Move forward one word
- `Alt+B` - Move backward one word
- `Ctrl+R` - Search command history

## Zsh Command History
- `!!` - Repeat last command
- `!$` - Last argument of previous command
- `!*` - All arguments of previous command
- `!abc` - Run most recent command starting with 'abc'
- `!abc:p` - Print most recent command starting with 'abc' (without running)
- `fc` - Open command history in editor

## Zsh File Globbing
- `ls *(.)` - List only regular files
- `ls *(/)` - List only directories
- `ls -l *(.m-7)` - List files modified in the last week
- `ls *.txt~file.txt` - List all txt files except file.txt
- `ls **/*.rb` - Recursively list all Ruby files

## Zsh Suffix Aliases (defined in .zshrc)
- `example.rb` - Open with Neovim (instead of typing 'nvim example.rb')
- `example.py` - Open with Neovim
- `example.js` - Open with Neovim

## Zsh Global Aliases (defined in .zshrc)
- `command G pattern` - Pipe output to grep
- `command L` - Pipe output to less
- `command H` - Pipe output to head
- `command T` - Pipe output to tail

## Zsh Vim Mode (if enabled)
- `ESC` or `Ctrl+[` - Enter normal mode
- `i` - Enter insert mode
- `v` - Enter visual mode
- `/pattern` - Search forward
- `?pattern` - Search backward

## tmux Integration
- `prefix + c` - Create new window
- `prefix + ,` - Rename current window
- `prefix + n` - Next window
- `prefix + p` - Previous window
- `prefix + w` - List windows

## Neovim Integration
- `v` - Open Neovim (with alias)
- `vi` - Open Neovim (with alias)
- `vim` - Open Neovim (with alias)

## Git Aliases
- `gs` - git status
- `ga` - git add
- `gc "message"` - git commit with message
- `gp` - git push
- `gl` - git pull

## Development Workflows
- `dev` - Start or resume main development session
- `notes` - Start or resume notes session