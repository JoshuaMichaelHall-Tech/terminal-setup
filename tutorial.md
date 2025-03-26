# Terminal-Based Development Workflow Tutorial (Zsh Edition)

This tutorial will guide you through practical workflows using the Zsh-based terminal development environment, focusing on software engineering tasks without relying on a mouse.

## Essential Keyboard Shortcuts

First, let's review the most essential shortcuts you'll use constantly:

### System Navigation
- `Cmd + Space`: Spotlight search
- `Ctrl + Opt + ←/→/↑/↓`: Position windows with Rectangle
- `Cmd + Tab`: Switch applications

### Terminal (iTerm2)
- `Cmd + T`: New tab
- `Cmd + D`: Split vertically
- `Cmd + Shift + D`: Split horizontally
- `Cmd + Opt + ←/→/↑/↓`: Navigate between panes

### tmux
- `Ctrl + a` is your prefix key
- `prefix + c`: Create new window
- `prefix + n/p`: Next/previous window
- `prefix + |`: Split vertically
- `prefix + -`: Split horizontally
- `prefix + ←/→/↑/↓`: Navigate panes
- `prefix + d`: Detach session

### Neovim
- `Space` is your leader key
- `<leader>e`: Toggle file explorer
- `<leader>ff`: Find files with Telescope
- `<leader>fg`: Live grep with Telescope
- `<leader>w`: Save file
- `<leader>q`: Quit
- `gd`: Go to definition (LSP)
- `K`: Hover documentation (LSP)

NOTE: There is a printable version in Mouseless Essential Shortcuts.pdf and an editable version in mouseless_essential_shortcuts.md. I have also included zsh_essential_shortcuts.md and zsh_essential_shortcuts.pdf.

## Workflow 1: Daily Development Setup

Let's create a development workflow that you can use each day with Zsh.

### 1. Starting Your Environment

```zsh
# Start or resume a session
tmux attach -t dev || tmux new -s dev
```

### 2. Organizing Your Windows

Create a structured workspace:

```
# Terminal shortcuts (no need to type these)
prefix + c  # Create a window for your main project
prefix + ,  # Rename it to "project"
prefix + c  # Create a window for running tests/servers
prefix + ,  # Rename it to "server"
prefix + c  # Create a window for git operations
prefix + ,  # Rename it to "git"
```

### 3. Project Navigation

In your "project" window:

```zsh
# Navigate to your project
cd ~/projects/your-project

# Open with Neovim
nvim
```

Inside Neovim:
- Press `<leader>e` to open the file explorer
- Use `<leader>ff` to fuzzy-find files
- Use `<leader>fg` to search for text within files

### 4. Coding With Neovim

Here's a typical coding workflow with Neovim:

1. Open a file using the file explorer or Telescope
2. Make edits using Vim motions
3. Use the LSP features:
   - `gd` to go to definition
   - `K` to see documentation
   - `<leader>ca` for code actions
   - `<leader>rn` to rename symbols
4. Save with `<leader>w`

### 5. Running Tests

Switch to your "server" window:
```
# Terminal shortcuts
prefix + n  # Go to next window until you reach "server"
```

Run your tests:
```zsh
# For Ruby/Rails
bundle exec rspec

# For Python
pytest

# For JavaScript
npm test
```

### 6. Git Workflow

Switch to your "git" window:
```
# Terminal shortcuts
prefix + n  # Go to next window until you reach "git"
```

Perform Git operations:
```zsh
# Check status
git status

# Stage changes
git add .

# Commit
git commit -m "Implement feature X"

# Push
git push
```

Alternatively, use Fugitive in Neovim:
- `<leader>gs` to view Git status
- Position cursor on file and press `-` to stage/unstage
- Press `cc` to commit

## Workflow 2: Full-Stack Development

Let's set up a full-stack development environment with separate windows for frontend and backend.

### 1. Create Your Session

```zsh
tmux new -s fullstack
```

### 2. Set Up Backend Window

```zsh
# Create and configure backend window
mkdir -p ~/window-layouts
cd ~/window-layouts

# Split the window for backend development
# Terminal shortcuts:
prefix + |  # Vertical split
prefix + -  # Horizontal split in the right pane
```

Left pane: Editor
```zsh
cd ~/projects/backend
nvim
```

Top-right pane: Server
```zsh
# Terminal shortcuts:
prefix + ←/→/↑/↓  # Navigate to the top-right pane
cd ~/projects/backend
rails server  # or your backend server command
```

Bottom-right pane: Tests/Console
```zsh
# Terminal shortcuts:
prefix + ←/→/↑/↓  # Navigate to the bottom-right pane
cd ~/projects/backend
rails console  # or equivalent for your stack
```

### 3. Set Up Frontend Window

```zsh
# Create a new window
# Terminal shortcuts:
prefix + c
prefix + ,  # Rename to "frontend"

# Split the window for frontend development
# Terminal shortcuts:
prefix + |  # Vertical split
prefix + -  # Horizontal split in the right pane
```

Left pane: Editor
```zsh
cd ~/projects/frontend
nvim
```

Top-right pane: Development Server
```zsh
# Terminal shortcuts:
prefix + ←/→/↑/↓  # Navigate to the top-right pane
cd ~/projects/frontend
npm start  # or your frontend server command
```

Bottom-right pane: Tests/Terminal
```zsh
# Terminal shortcuts:
prefix + ←/→/↑/↓  # Navigate to the bottom-right pane
cd ~/projects/frontend
npm test  # or other commands as needed
```

### 4. Create a Database Window

```zsh
# Create a new window for database operations
# Terminal shortcuts:
prefix + c
prefix + ,  # Rename to "db"

cd ~/projects/backend
rails dbconsole  # or your database CLI command
```

### 5. Navigate Between Windows

Use `prefix + n` and `prefix + p` to cycle through windows.
Use `prefix + window-number` to jump directly to a specific window.

## Workflow 3: Project Management with Git

Let's establish a Git-focused workflow for managing project tasks.

### 1. Create a New Feature Branch

In your project directory:

```zsh
# Check out the main branch
git checkout main
git pull

# Create a new feature branch
git checkout -b feature/new-feature

# Open the code
nvim
```

### 2. Use Fugitive for Git Operations

Inside Neovim:

```
# Neovim commands
:Git  # Open Git status
```

From the Git status window:
- Navigate with `j` and `k`
- Press `-` to stage/unstage files
- Press `=` to see diff
- Press `cc` to commit

### 3. Push Your Changes

```
# Neovim commands
:Git push -u origin feature/new-feature
```

### 4. Create a Pull Request with GitHub CLI

Back in the terminal:

```zsh
# Create a pull request
gh pr create --title "Implement new feature" --body "This PR adds..."

# List open pull requests
gh pr list

# Check the status of CI
gh pr checks
```

## Workflow 4: Note-Taking and Documentation

Let's set up a workflow for taking notes and documenting your projects.

### 1. Create a Notes Session

```zsh
tmux new -s notes
```

### 2. Open Vimwiki

```zsh
nvim -c VimwikiIndex
```

### 3. Organize Your Notes

Inside Vimwiki:
- Press `<Enter>` on a wiki link to follow it
- Create new pages with `<leader>wn`
- Create a daily journal with `<leader>w<leader>i`

Structure example:
```
= My Developer Notes =

== Projects ==
- [[project1]]
- [[project2]]

== Learning ==
- [[ruby]]
- [[javascript]]
- [[algorithms]]

== Ideas ==
- [[app_ideas]]
- [[blog_posts]]
```

### 4. Link Code and Notes

In your code, add comments that reference your notes:

```ruby
# See my notes on this pattern at: ~/vimwiki/design_patterns.md
def factory_method
  # Implementation
end
```

## Workflow 5: Remote Development

Let's create a workflow for working on remote servers.

### 1. Connect to Remote Server

```zsh
# SSH into the server
ssh user@server.example.com
```

### 2. Start a tmux Session on the Remote Server

```zsh
# Start a new session or attach to existing
tmux new -s remote || tmux attach -t remote
```

### 3. Set Up Your Environment on the Remote Server

```zsh
# Clone your dotfiles if you have them
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Set up symbolic links
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.vimrc ~/.vimrc
# etc.
```

### 4. Split Windows for Different Tasks

Use the same tmux commands from earlier workflows to create a productive environment.

### 5. Detach Safely When Done

```
# Terminal shortcuts
prefix + d  # Detach from the tmux session
```

Your session will continue running, and you can reattach later.

## Workflow 6: Data Analysis with Python

Let's set up a workflow for data analysis using Python in the terminal.

### 1. Create a Data Analysis Session

```zsh
tmux new -s data-analysis
```

### 2. Set Up Your Environment

Split your window:
```
# Terminal shortcuts
prefix + |  # Vertical split
```

Left pane: Editor for Python scripts
```zsh
cd ~/projects/data-analysis
nvim analysis.py
```

Right pane: Python REPL or IPython
```zsh
# Terminal shortcuts
prefix + →  # Navigate to right pane
cd ~/projects/data-analysis
python -i analysis.py  # or ipython
```

### 3. Run Analysis and View Results

In Neovim:
- Edit your Python script
- Save with `<leader>w`

In the REPL pane:
- Reload your script: `%run analysis.py`
- Explore data interactively

## Workflow 7: Daily Time Management

Use your terminal environment to manage your time effectively:

### 1. Start Your Day

```zsh
# Create a focused workspace
tmux new -s workday

# Open your daily journal in the first window
nvim -c VimwikiMakeDiaryNote

# In Vimwiki, plan your day:
# - List today's tasks
# - Schedule focus blocks
# - Note important meetings
```

### 2. Set Up Task Tracking

Create a new window for task management:
```
# Terminal shortcuts
prefix + c  # Create a new window
prefix + ,  # Rename to "tasks"
```

Use Taskwarrior to manage tasks:
```zsh
# Add tasks for today
task add "Complete PR review" due:today priority:H
task add "Refactor authentication module" due:today priority:M

# View today's tasks
task due:today
```

### 3. Use Pomodoro Technique

In a new window or pane:
```
# Terminal shortcuts
prefix + c  # Create a new window
prefix + ,  # Rename to "pomodoro"
```

Run a simple Pomodoro timer:
```zsh
# 25-minute work session
timer 25m "Time to take a break!"
```

## Tips for Maximum Efficiency

1. **Learn key motions incrementally**. Don't try to memorize everything at once.

2. **Create Zsh aliases for common operations**:
   ```zsh
   # Add to your .zshrc
   alias dev='tmux attach -t dev || tmux new -s dev'
   alias gc='git commit -m'
   alias gst='git status'
   ```

3. **Use Zsh functions for complex workflows**:
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

4. **Use mnemonics to remember commands**:
   - `<leader>ff` = "find files"
   - `<leader>gs` = "git status"

5. **Leverage Zsh's powerful completions**:
   ```zsh
   # Add to your .zshrc
   # Enable enhanced completions
   autoload -U compinit && compinit
   
   # Case-insensitive completion
   zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
   ```

6. **Learn to touch type** if you haven't already. Your efficiency will skyrocket.

7. **Document your workflows** in your wiki for future reference.

8. **Use clipboard integration** with tmux and Neovim:
   ```
   # In .tmux.conf
   set -g @plugin 'tmux-plugins/tmux-yank'
   
   # In Neovim
   set clipboard+=unnamedplus
   ```

## Zsh-Specific Power Features

Here are some Zsh-specific features that will boost your productivity:

### 1. Directory Navigation

Zsh allows you to navigate directories without using `cd`:

```zsh
# Instead of
cd /path/to/directory

# Just type the path
/path/to/directory
```

### 2. Global Aliases

Create aliases that work anywhere in a command:

```zsh
# Add to your .zshrc
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'

# Usage examples:
ps aux G ruby    # grep for ruby processes
cat file.log L   # pipe to less
```

### 3. Suffix Aliases

Open files with specific extensions using their associated programs:

```zsh
# Add to your .zshrc
alias -s rb=nvim
alias -s py=nvim
alias -s js=nvim
alias -s json=nvim
alias -s md=nvim
alias -s txt=nvim

# Usage: just type the filename to open it
example.rb    # Opens example.rb in Neovim
```

### 4. Directory History

Navigate quickly through your recently visited directories:

```zsh
# Add to your .zshrc
setopt AUTO_PUSHD      # Push directories onto directory stack
setopt PUSHD_IGNORE_DUPS  # Don't push duplicates
setopt PUSHD_SILENT    # Don't print directory stack

# Navigate directory history
cd -<TAB>   # Shows directory history with numbers
cd -2       # Go to the second most recent directory
```

### 5. Extended Globbing

Use powerful pattern matching in Zsh:

```zsh
# Add to your .zshrc
setopt EXTENDED_GLOB

# Examples:
ls -l *(.)     # List only regular files
rm -rf ^*.rb   # Remove everything except Ruby files
ls -l **/*(.) # List all regular files in all subdirectories
```

## Conclusion

These workflows should help you become more efficient with your Zsh-based terminal development environment. Remember that mastery takes time—focus on learning a few new shortcuts each week rather than trying to memorize everything at once.

As you become more comfortable with these tools, you'll develop your own workflows tailored to your specific needs and preferences. The most powerful aspect of a Zsh-based terminal environment is how customizable it is - you can continue to refine your setup over time.

## Additional Resources

### Zsh Documentation and Learning
- Oh My Zsh documentation: https://github.com/ohmyzsh/ohmyzsh/wiki
- Zsh Guide: http://zsh.sourceforge.net/Guide/
- The Zsh Manual: http://zsh.sourceforge.net/Doc/

### Neovim Resources
- Neovim documentation: https://neovim.io/doc/
- Learn Vim progressively: https://github.com/iggredible/Learn-Vim
- Practical Vim (book by Drew Neil)

### tmux Resources
- tmux cheatsheet: https://tmuxcheatsheet.com/
- tmux guide: https://pragprog.com/titles/bhtmux2/tmux-2/

Remember, the goal isn't to learn everything at once, but to incrementally build your skills and workflows. Start with the basics, add new techniques as you get comfortable, and soon you'll be navigating your development environment with ease and speed.