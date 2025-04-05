# Tutorial: Using Your Terminal Environment

This tutorial will guide you through common workflows and tasks using your new terminal environment. It covers development workflows, notes management, and daily productivity techniques.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Notes System](#notes-system)
4. [Common Tasks](#common-tasks)
5. [Advanced Techniques](#advanced-techniques)

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

### Coding Workflow

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
   # For Ruby/Rails
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
   # For Ruby/Rails
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

## Notes System

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

## Common Tasks

### Directory Navigation

```zsh
# Quick directory navigation
cd -              # Go to previous directory
..                # Go up one directory
...               # Go up two directories
cd -<TAB>         # Show numbered directory history
dirs -v           # Show directory stack with numbers
pushd ~/projects  # Change to directory and add to stack
popd              # Go back to previous directory on stack
```

### File Operations

```zsh
# Creating directories and files
mcd new-directory  # Create directory and cd into it

# Finding files
nvimf pattern  # Find files matching pattern and open in Neovim
find . -name "*.rb" | xargs nvim  # Find Ruby files and open in Neovim
```

### tmux Session Management

```zsh
# Listing sessions
tls  # List all tmux sessions

# Attaching to sessions
ta my-session  # Attach to existing session

# Creating new sessions
tn my-session  # Create new session

# Killing sessions
tk my-session  # Kill session
```

### Zsh Customization

Edit your Zsh configuration:

```zsh
nvim ~/.zshrc
```

Add custom aliases or functions, then reload:

```zsh
source ~/.zshrc
```

## Advanced Techniques

### Custom tmux Layouts

Create custom tmux session layouts for specific projects:

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

### Neovim Macros

Record and play back sequences of commands:

```
# Recording
qa     # Start recording to register 'a'
...    # Your commands
q      # Stop recording

# Playback
@a     # Play macro 'a' once
10@a   # Play macro 'a' 10 times
```

### Advanced Git Workflow

Set up a branch-based workflow:

```zsh
# Create feature branch
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

### Customizing Your Environment

If you want to customize your environment further, you can modify the following files:

- **Zsh**: Edit `~/.zshrc` for shell customization
- **Neovim**: Edit files in `~/.config/nvim/` for editor customization
- **tmux**: Edit `~/.tmux.conf` for tmux customization
- **Notes**: Edit Neovim plugin at `~/.config/nvim/plugin/notes.vim`

After making changes, run the appropriate troubleshooter script to ensure everything is working correctly:

```zsh
ruby bin/component_troubleshooter.rb --fix
```

## Conclusion

This terminal-centric workflow is designed to maximize productivity by keeping your hands on the keyboard and minimizing context switching. As you become more familiar with these tools and techniques, you'll develop your own preferences and workflows.

Remember that mastery comes through consistent practice. Start with the basics, gradually incorporate more advanced techniques, and periodically review the shortcuts reference to discover new capabilities.

For a complete list of all keyboard shortcuts, see the [terminal-shortcuts.md](terminal-shortcuts.md) file.
