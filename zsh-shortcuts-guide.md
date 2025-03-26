# Mastering Zsh: The Ultimate Shortcut Guide

> A comprehensive reference for terminal productivity with Zsh

## Navigation Shortcuts

### Directory Movement
- `cd -` - Navigate to previous directory
- `cd -<TAB>` - Show directory history with numbers
- `cd -2` - Go to the second most recent directory
- `/path/to/directory` - Navigate directly without typing 'cd'
- `..` - Go up one directory (with alias from .zshrc)
- `...` - Go up two directories (with alias from .zshrc)
- `....` - Go up three directories (with alias from .zshrc)

### Directory Stack
- `dirs -v` - List directory stack with numbers
- `pushd directory` - Change to directory and add to stack
- `popd` - Pop top directory from stack and change to it

## Command Line Editing

### Cursor Movement
- `Ctrl+A` - Move cursor to beginning of line
- `Ctrl+E` - Move cursor to end of line
- `Alt+F` - Move forward one word
- `Alt+B` - Move backward one word

### Text Manipulation
- `Ctrl+U` - Clear line before cursor
- `Ctrl+K` - Clear line after cursor
- `Ctrl+W` - Delete word before cursor
- `Alt+D` - Delete word after cursor
- `Ctrl+Y` - Paste previously cut text
- `Ctrl+_` - Undo last edit

## Command History

### History Navigation
- `Ctrl+R` - Search command history (incremental)
- `Ctrl+S` - Search forward in history
- `Ctrl+G` - Cancel history search
- `!!` - Repeat last command
- `!$` - Last argument of previous command
- `!*` - All arguments of previous command
- `!abc` - Run most recent command starting with 'abc'
- `!abc:p` - Print most recent command starting with 'abc' (without running)
- `fc` - Open command history in editor

### History Substitution
- `^old^new` - Replace first occurrence of 'old' with 'new' in previous command
- `!!:gs/old/new` - Replace all occurrences of 'old' with 'new' in previous command

## File Globbing & Pattern Matching

### Basic Globbing
- `ls *(.)` - List only regular files
- `ls *(/)` - List only directories
- `ls -l *(.m-7)` - List files modified in the last week
- `ls *.txt~file.txt` - List all txt files except file.txt
- `ls **/*.rb` - Recursively list all Ruby files

### Advanced Globbing
- `ls -l *(.)` - List only regular files (with EXTENDED_GLOB option)
- `ls -l ^*.rb` - List everything except Ruby files
- `ls -l **/*(.)` - List all regular files in all subdirectories
- `rm -rf *(/)` - Remove all subdirectories
- `ls -l *(.L0)` - List empty files

## Zsh-Specific Features

### Suffix Aliases (defined in .zshrc)
- `example.rb` - Open with Neovim (instead of typing 'nvim example.rb')
- `example.py` - Open with Neovim
- `example.js` - Open with Neovim
- `example.md` - Open with Neovim

### Global Aliases (defined in .zshrc)
- `command G pattern` - Pipe output to grep
- `command L` - Pipe output to less
- `command H` - Pipe output to head
- `command T` - Pipe output to tail

### Vim Mode (if enabled)
- `ESC` or `Ctrl+[` - Enter normal mode
- `i` - Enter insert mode
- `v` - Enter visual mode
- `/pattern` - Search forward
- `?pattern` - Search backward

## Integration with Tools

### Git Aliases
- `gs` - git status
- `ga` - git add
- `gc "message"` - git commit with message
- `gp` - git push
- `gl` - git pull

### Neovim Aliases
- `v` - Open Neovim
- `vi` - Open Neovim
- `vim` - Open Neovim

### tmux Integration
- `ta` - tmux attach -t
- `tls` - tmux list-sessions
- `tn` - tmux new -s
- `tk` - tmux kill-session -t

### Development Workflow Aliases
- `dev` - Start or resume main development session
- `notes` - Start or resume notes session

## Productivity Boosters

### Command Substitution
- `echo $(command)` - Execute command and use its output
- `for i in $(ls); do echo $i; done` - Use command output in a loop

### Process Management
- `Ctrl+Z` - Suspend current process
- `fg` - Resume suspended process in foreground
- `bg` - Resume suspended process in background
- `jobs` - List all jobs
- `kill %1` - Kill job number 1

### Redirection & Pipes
- `command > file` - Redirect stdout to file (overwrite)
- `command >> file` - Redirect stdout to file (append)
- `command 2> file` - Redirect stderr to file
- `command &> file` - Redirect both stdout and stderr to file
- `command1 | command2` - Pipe stdout of command1 to stdin of command2

## Custom Functions & Configuration

### Recommended Functions
```zsh
# Function to create and switch to a directory
mcd() {
  mkdir -p $1 && cd $1
}

# Function to extract various archive formats
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz) tar xzf $1 ;;
      *.bz2) bunzip2 $1 ;;
      *.rar) unrar e $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar xf $1 ;;
      *.tbz2) tar xjf $1 ;;
      *.tgz) tar xzf $1 ;;
      *.zip) unzip $1 ;;
      *.Z) uncompress $1 ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Function to search for a file and open it with Neovim
nvimf() {
  nvim $(find . -name "*$1*" | fzf)
}
```

### Recommended Zsh Options
```zsh
# Add to your .zshrc
setopt AUTO_PUSHD          # Push directories onto directory stack
setopt PUSHD_IGNORE_DUPS   # Don't push duplicates
setopt PUSHD_SILENT        # Don't print directory stack
setopt EXTENDED_GLOB       # Use extended globbing
setopt AUTO_CD             # Type directory name to cd
setopt CORRECT             # Auto correct commands
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
```

## Terminal Efficiency Tips

1. **Learn incremental skills**: Start with basic navigation and add more shortcuts as you become comfortable.

2. **Create aliases for common tasks**: Add frequently used commands to your `.zshrc`.

3. **Use tab completion extensively**: Zsh's tab completion is extremely powerful.

4. **Leverage history**: Use Ctrl+R and history expansion to avoid retyping commands.

5. **Master the directory stack**: Learn to use pushd/popd for quick navigation between directories.

6. **Document your custom shortcuts**: Keep a personal cheatsheet for your customizations.

7. **Practice regular expressions**: Powerful for searching and replacing text.

8. **Learn one new shortcut per day**: Build your skills incrementally.

9. **Use keyboard-driven window management**: Rectangle app with keyboard shortcuts.

10. **Customize your prompt**: Add useful information while keeping it clean.

---

*Developed for a terminal-centric development workflow with Zsh, Neovim, and tmux.*
