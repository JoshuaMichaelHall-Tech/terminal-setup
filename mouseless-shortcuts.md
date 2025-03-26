# MacOS Mouseless Development Environment - Keyboard Shortcut Cheat Sheet

## System Navigation

### MacOS
- `Cmd + Space`: Spotlight search
- `Cmd + Tab`: Switch between applications
- `Cmd + ~`: Switch between windows of the same application
- `Cmd + Q`: Quit application
- `Cmd + H`: Hide application
- `Cmd + M`: Minimize window
- `Cmd + W`: Close window/tab
- `Cmd + Opt + Esc`: Force quit applications

### Rectangle (Window Management)
- `Ctrl + Opt + ←`: Left half of screen
- `Ctrl + Opt + →`: Right half of screen
- `Ctrl + Opt + ↑`: Top half of screen
- `Ctrl + Opt + ↓`: Bottom half of screen
- `Ctrl + Opt + Return`: Maximize window
- `Ctrl + Opt + C`: Center window
- `Ctrl + Opt + U`: Upper left quarter
- `Ctrl + Opt + I`: Upper right quarter
- `Ctrl + Opt + J`: Lower left quarter
- `Ctrl + Opt + K`: Lower right quarter

### Alfred
- `Opt + Space`: Open Alfred
- `Cmd + Opt + \`: Open Alfred clipboard history
- `Cmd + Opt + C`: Open Alfred calculator

## Terminal (iTerm2)

### Tab Management
- `Cmd + T`: New tab
- `Cmd + W`: Close tab
- `Cmd + ←/→`: Navigate tabs
- `Cmd + Shift + I`: Broadcast input to all panes
- `Cmd + Shift + [/]`: Navigate tabs (alternative)
- `Cmd + Number`: Go to specific tab

### Pane Management
- `Cmd + D`: Split vertically
- `Cmd + Shift + D`: Split horizontally
- `Cmd + Opt + ←/→/↑/↓`: Navigate panes
- `Cmd + Shift + Enter`: Maximize/restore pane
- `Cmd + W`: Close pane

### Text Navigation
- `Ctrl + A`: Beginning of line
- `Ctrl + E`: End of line
- `Opt + ←/→`: Move by word
- `Ctrl + U`: Clear line before cursor
- `Ctrl + K`: Clear line after cursor
- `Ctrl + W`: Delete word before cursor
- `Cmd + K`: Clear screen
- `Ctrl + R`: Search command history
- `Ctrl + L`: Clear screen (alternative)

## Tmux

> Prefix key is set to `Ctrl + A`

### Session Management
- `Prefix + $`: Rename session
- `Prefix + D`: Detach from session
- `Prefix + S`: List sessions
- `tmux ls`: List sessions (from shell)
- `tmux new -s name`: Create new named session
- `tmux attach -t name`: Attach to session

### Window Management
- `Prefix + C`: Create window
- `Prefix + ,`: Rename window
- `Prefix + N`: Next window
- `Prefix + P`: Previous window
- `Prefix + &`: Kill window
- `Prefix + Number`: Go to window number
- `Prefix + F`: Find window
- `Prefix + W`: List windows

### Pane Management
- `Prefix + |`: Split vertically
- `Prefix + -`: Split horizontally
- `Prefix + ←/→/↑/↓`: Navigate panes
- `Prefix + Q`: Show pane numbers
- `Prefix + Z`: Toggle pane zoom
- `Prefix + {`: Move pane left
- `Prefix + }`: Move pane right
- `Prefix + X`: Kill pane

### Copy Mode
- `Prefix + [`: Enter copy mode
- `Space`: Start selection (in copy mode)
- `Enter`: Copy selection (in copy mode)
- `Prefix + ]`: Paste copied text
- `/`: Search forward
- `?`: Search backward
- `N`: Next instance
- `Shift + N`: Previous instance

## Neovim

### Basic Navigation
- `h/j/k/l`: Move left/down/up/right
- `w/b`: Move forward/backward by word
- `0/$`: Start/end of line
- `gg/G`: First/last line of file
- `Ctrl + D/U`: Scroll half-page down/up
- `Ctrl + F/B`: Scroll full-page forward/backward
- `zz`: Center current line
- `Ctrl + O/I`: Jump backward/forward

### Editing
- `i/a`: Insert before/after cursor
- `I/A`: Insert at beginning/end of line
- `o/O`: Insert new line below/above
- `r`: Replace character
- `c + motion`: Change text
- `d + motion`: Delete text
- `y + motion`: Yank (copy) text
- `p/P`: Paste after/before cursor
- `u/Ctrl + R`: Undo/redo
- `>>/<<`: Indent/unindent line
- `=G`: Auto-indent file

### Visual Mode
- `v`: Visual mode (character selection)
- `V`: Visual line mode
- `Ctrl + v`: Visual block mode
- `gv`: Reselect last selection

### File Operations
- `:w`: Write (save) file
- `:q`: Quit
- `:wq`: Write and quit
- `:e file`: Edit file
- `:split/:vsplit`: Split horizontally/vertically
- `Ctrl + W + h/j/k/l`: Navigate splits

### Search and Replace
- `/pattern`: Search forward
- `?pattern`: Search backward
- `n/N`: Next/previous match
- `:%s/old/new/g`: Replace all occurrences
- `:%s/old/new/gc`: Replace with confirmation

### Plugin Shortcuts (Configured)
- Space: Leader key
- `<leader>ff`: Telescope find files
- `<leader>fg`: Telescope live grep
- `<leader>fb`: Telescope buffers
- `<leader>fh`: Telescope help tags
- `<leader>e`: Toggle NvimTree file explorer
- `<leader>gs`: Git status (Fugitive)
- `<leader>gb`: Git blame (Fugitive)
- `<leader>gc`: Git commit (Fugitive)
- `gd`: Go to definition (LSP)
- `K`: Show hover documentation (LSP)
- `<leader>rn`: Rename symbol (LSP)
- `<leader>ca`: Code actions (LSP)

## Git and GitHub CLI

### Git (command line)
- `git status`: Show status
- `git add .`: Stage all changes
- `git commit -m "message"`: Commit changes
- `git push`: Push changes
- `git pull`: Pull changes
- `git checkout -b name`: Create and switch to new branch
- `git branch`: List branches
- `git log`: Show commit history
- `git stash`: Stash changes
- `git stash pop`: Apply stashed changes

### GitHub CLI
- `gh repo create`: Create repository
- `gh repo clone repo`: Clone repository
- `gh pr create`: Create pull request
- `gh pr list`: List pull requests
- `gh pr checkout number`: Checkout pull request
- `gh issue create`: Create issue
- `gh issue list`: List issues
- `gh issue view number`: View issue

## Ranger File Manager
- `j/k`: Navigate down/up
- `h/l`: Navigate out/into directory
- `gg/G`: Go to top/bottom
- `Space`: Select file
- `dd`: Cut selection
- `yy`: Copy selection
- `pp`: Paste selection
- `/`: Search
- `n/N`: Next/previous match
- `zh`: Toggle hidden files
- `S`: Open shell

## Obsidian (with Vim keybindings)
- `Cmd + O`: Open file
- `Cmd + P`: Command palette
- `Cmd + N`: New note
- `Cmd + E`: Toggle edit/preview
- `Cmd + G`: Graph view
- `Cmd + B`: Bold
- `Cmd + I`: Italic
- `Cmd + K`: Insert link
- `[[`: Start internal link
- `![[`: Start embed

## fzf (Fuzzy Finder)
- `Ctrl + T`: Paste selected files/dirs into command line
- `Ctrl + R`: Paste selected command from history
- `Alt + C`: CD into selected directory
- `**<Tab>`: Trigger file completion
- `Tab/Shift+Tab`: Select multiple items
- `Ctrl + P/N`: Previous/next item
- `Enter`: Confirm selection

## Taskwarrior
- `task add desc`: Add new task
- `task list`: List tasks
- `task next`: Show highest priority tasks
- `task done ID`: Complete task
- `task delete ID`: Delete task
- `task modify ID desc`: Edit task
- `task ID start`: Start working on task
- `task ID stop`: Stop working on task
- `task burndown`: Show burndown chart
