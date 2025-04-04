#!/bin/zsh

# Terminal Development Environment Health Check
# Author: Joshua Michael Hall
# License: MIT

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Check if a command exists
check_command() {
    if command -v $1 &> /dev/null; then
        log_success "$1 is installed"
        return 0
    else
        log_error "$1 is not installed"
        return 1
    fi
}

# Check if a file exists
check_file() {
    if [ -f "$1" ]; then
        log_success "$1 exists"
        return 0
    else
        log_error "$1 does not exist"
        return 1
    fi
}

# Check if a directory exists
check_directory() {
    if [ -d "$1" ]; then
        log_success "$1 exists"
        return 0
    else
        log_error "$1 does not exist"
        return 1
    fi
}

# Check if a file is executable
check_executable() {
    if [ -f "$1" ]; then
        if [ -x "$1" ]; then
            log_success "$1 is executable"
            return 0
        else
            log_error "$1 is not executable"
            return 1
        fi
    else
        log_error "$1 does not exist"
        return 1
    fi
}

# Function to check if a function exists in .zshrc
check_zsh_function() {
    local function_name="$1"
    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "function $function_name" "$HOME/.zshrc" || grep -q "$function_name()" "$HOME/.zshrc"; then
            log_success "Function $function_name is defined in .zshrc"
            return 0
        else
            log_error "Function $function_name is not defined in .zshrc"
            return 1
        fi
    else
        log_error ".zshrc does not exist"
        return 1
    fi
}

# Function to check if an alias exists in .zshrc
check_zsh_alias() {
    local alias_name="$1"
    if [ -f "$HOME/.zshrc" ]; then
        if grep -q "alias $alias_name=" "$HOME/.zshrc"; then
            log_success "Alias $alias_name is defined in .zshrc"
            return 0
        else
            log_error "Alias $alias_name is not defined in .zshrc"
            return 1
        fi
    else
        log_error ".zshrc does not exist"
        return 1
    fi
}

# Function to create the uninstall script
create_uninstall_script() {
    # Make sure the bin directory exists
    mkdir -p "$HOME/bin"
    
    # Create the uninstall script
    cat > "$HOME/bin/uninstall-terminal-env.sh" << 'EOL'
#!/bin/zsh

# Terminal Development Environment Uninstall Script
# Author: Joshua Michael Hall
# License: MIT

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Welcome message and confirmation
echo "==============================================================="
echo "      Terminal Environment Uninstall Script                    "
echo "==============================================================="
echo ""
echo "This script will uninstall the terminal environment components."
echo "The following will be affected:"
echo "1. Neovim configuration"
echo "2. tmux configuration"
echo "3. Custom Zsh configurations"
echo "4. Watchman configuration"
echo ""
echo "Notes and other personal data will NOT be removed, but will be backed up."
echo ""
echo "Available options:"
echo "1. Soft uninstall (remove configurations but keep tools)"
echo "2. Full uninstall (remove all configurations and installed tools)"
echo "3. Cancel"
echo ""
read "REPLY?Please select an option (1-3, default: 1): "
echo ""

# Default to soft uninstall
UNINSTALL_MODE="${REPLY:-1}"

case $UNINSTALL_MODE in
    1) MODE_NAME="Soft uninstall";;
    2) MODE_NAME="Full uninstall";;
    3) echo "Uninstall cancelled."; exit 0;;
    *) log_error "Invalid option selected. Exiting."; exit 1;;
esac

echo "Running in mode: $MODE_NAME"
echo ""

read "REPLY?This action cannot be undone. Are you sure you want to proceed with $MODE_NAME? (y/n) "
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Uninstall cancelled."
    exit 0
fi

# Create timestamp for backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/terminal_env_uninstall_backup_$TIMESTAMP"

log_info "Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup existing configurations
log_info "Backing up existing configurations..."

# Neovim
if [ -d "$HOME/.config/nvim" ]; then
    log_info "Backing up Neovim configuration..."
    cp -r "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
fi

# tmux
if [ -f "$HOME/.tmux.conf" ]; then
    log_info "Backing up tmux configuration..."
    cp "$HOME/.tmux.conf" "$BACKUP_DIR/tmux.conf"
fi

# Zsh
if [ -f "$HOME/.zshrc" ]; then
    log_info "Backing up Zsh configuration..."
    cp "$HOME/.zshrc" "$BACKUP_DIR/zshrc"
fi
if [ -f "$HOME/.p10k.zsh" ]; then
    cp "$HOME/.p10k.zsh" "$BACKUP_DIR/p10k.zsh"
fi

# Notes system
if [ -d "$HOME/notes" ]; then
    log_info "Backing up notes templates and config..."
    mkdir -p "$BACKUP_DIR/notes"
    cp -r "$HOME/notes/templates" "$BACKUP_DIR/notes/templates" 2>/dev/null || true
    cp "$HOME/notes/README.md" "$BACKUP_DIR/notes/README.md" 2>/dev/null || true
    cp "$HOME/notes/.gitignore" "$BACKUP_DIR/notes/.gitignore" 2>/dev/null || true
fi

log_success "Backups completed at $BACKUP_DIR"

# Remove Neovim configuration
log_info "Removing Neovim configuration..."
rm -rf "$HOME/.config/nvim" 2>/dev/null || true

# Remove tmux configuration
log_info "Removing tmux configuration..."
rm -f "$HOME/.tmux.conf" 2>/dev/null || true
rm -rf "$HOME/.tmux/plugins/tpm" 2>/dev/null || true

# Remove Watchman config
log_info "Removing Watchman configuration..."
if command -v watchman > /dev/null; then
    watchman watch-del "$HOME/notes" 2>/dev/null || true
fi
rm -f "$HOME/Library/LaunchAgents/com.facebook.watchman.plist" 2>/dev/null || true
launchctl unload "$HOME/Library/LaunchAgents/com.facebook.watchman.plist" 2>/dev/null || true

# Clean up Zsh configuration
log_info "Cleaning up Zsh configuration..."
if [ -f "$HOME/.zshrc" ]; then
    # Create a new .zshrc with only the non-terminal-env parts
    TEMP_ZSHRC="$HOME/.zshrc.temp"
    cat "$HOME/.zshrc" | grep -v "# ============ Aliases ============" | \
                         grep -v "# ============ Functions ============" | \
                         grep -v "# ============ Zsh-specific settings ============" | \
                         grep -v "# fzf configuration" | \
                         grep -v "wk()" | \
                         grep -v "nvimf()" | \
                         grep -v "mcd()" | \
                         grep -v "check-functions()" | \
                         grep -v "alias v=" | \
                         grep -v "alias vi=" | \
                         grep -v "alias vim=" | \
                         grep -v "alias ta=" | \
                         grep -v "alias tls=" | \
                         grep -v "alias tn=" | \
                         grep -v "alias tk=" | \
                         grep -v "alias dev=" | \
                         grep -v "alias notes=" | \
                         grep -v "alias gs=" | \
                         grep -v "alias ga=" | \
                         grep -v "alias gc=" | \
                         grep -v "alias gp=" | \
                         grep -v "alias gl=" > "$TEMP_ZSHRC"
    
    # Backup the original again to be safe
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
    
    # Replace with cleaned version
    mv "$TEMP_ZSHRC" "$HOME/.zshrc"
fi

# Remove version file
rm -f "$HOME/.terminal_env_version" 2>/dev/null || true

# Full uninstall mode
if [[ "$UNINSTALL_MODE" == "2" ]]; then
    log_info "Proceeding with full uninstall (removing installed tools)..."
    
    # Uninstall tools with Homebrew
    if command -v brew > /dev/null; then
        log_info "Uninstalling tools with Homebrew..."
        
        # Ask about each tool
        read "REPLY?Uninstall Neovim? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall neovim || true
        fi
        
        read "REPLY?Uninstall tmux? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall tmux || true
        fi
        
        read "REPLY?Uninstall Watchman? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall watchman || true
        fi
        
        read "REPLY?Uninstall fzf? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall fzf || true
        fi
        
        read "REPLY?Uninstall Rectangle window manager? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall --cask rectangle || true
        fi
        
        read "REPLY?Uninstall JetBrains Mono Nerd Font? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall --cask font-jetbrains-mono-nerd-font || true
        fi
        
        read "REPLY?Uninstall Hack Nerd Font? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall --cask font-hack-nerd-font || true
        fi
        
        read "REPLY?Uninstall iTerm2? (y/n): "
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew uninstall --cask iterm2 || true
        fi
    else
        log_warning "Homebrew not found, skipping tool uninstallation."
    fi
    
    # Ask about uninstalling Oh My Zsh
    read "REPLY?Uninstall Oh My Zsh? (y/n): "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$HOME/.oh-my-zsh/tools/uninstall.sh" ]; then
            log_info "Uninstalling Oh My Zsh..."
            sh "$HOME/.oh-my-zsh/tools/uninstall.sh" -y || true
        else
            log_warning "Oh My Zsh uninstaller not found, skipping."
            rm -rf "$HOME/.oh-my-zsh" 2>/dev/null || true
        fi
    fi
fi

log_success "Uninstallation completed!"
echo ""
echo "Your original configurations have been backed up to: $BACKUP_DIR"
echo "If you need to restore any settings, you can find them there."
echo ""
echo "Note: Your notes in the ~/notes directory have NOT been removed."
echo "You may want to back them up or move them elsewhere."
echo ""
echo "Please restart your terminal for all changes to take effect."
EOL

    # Make the script executable
    chmod +x "$HOME/bin/uninstall-terminal-env.sh"
    
    log_success "Created and made executable: $HOME/bin/uninstall-terminal-env.sh"
}

# Function to fix common issues
fix_issue() {
    local issue_type="$1"
    local issue_target="$2"
    
    case "$issue_type" in
        "executable")
            if [ -f "$issue_target" ]; then
                chmod +x "$issue_target"
                log_success "Fixed permissions for $issue_target"
            else
                log_error "Cannot fix permissions for non-existent file: $issue_target"
            fi
            ;;
        "directory")
            mkdir -p "$issue_target"
            log_success "Created directory: $issue_target"
            ;;
        "nvim_plugin")
            # Create a minimal plugin configuration
            mkdir -p "$(dirname "$issue_target")"
            touch "$issue_target"
            log_success "Created minimal Neovim plugin file: $issue_target"
            ;;
        "zsh_function")
            if [ -f "$HOME/.zshrc" ]; then
                case "$issue_target" in
                    "mcd")
                        echo -e "\n# Create and change to directory in one command\nmcd() {\n  mkdir -p \"\$1\" && cd \"\$1\"\n}" >> "$HOME/.zshrc"
                        log_success "Added mcd function to .zshrc"
                        ;;
                    "nvimf")
                        echo -e "\n# Find and open file with Neovim\nnvimf() {\n  local file\n  file=\$(find . -name \"*\$1*\" | fzf)\n  if [[ -n \"\$file\" ]]; then\n    nvim \"\$file\"\n  fi\n}" >> "$HOME/.zshrc"
                        log_success "Added nvimf function to .zshrc"
                        ;;
                    "wk")
                        echo -e "\n# Unified session manager for both dev and notes\nwk() {\n  local session=\$1\n  \n  case \"\$session\" in\n    dev)\n      if ! tmux has-session -t dev 2>/dev/null; then\n        # Create development session with windows for code, server, and git\n        tmux new-session -d -s dev -n code\n        tmux new-window -t dev:1 -n server\n        tmux new-window -t dev:2 -n git\n        tmux select-window -t dev:0\n      fi\n      tmux attach -t dev\n      ;;\n    notes)\n      if ! tmux has-session -t notes 2>/dev/null; then\n        # Create notes session with windows for main, daily, projects, and learning\n        tmux new-session -d -s notes -n main -c ~/notes\n        tmux new-window -t notes:1 -n daily -c ~/notes/daily\n        tmux new-window -t notes:2 -n projects -c ~/notes/projects\n        tmux new-window -t notes:3 -n learning -c ~/notes/learning\n        tmux select-window -t notes:0\n      fi\n      tmux attach -t notes\n      ;;\n    *)\n      echo \"Usage: wk [dev|notes]\"\n      echo \"  dev   - Start or resume development session\"\n      echo \"  notes - Start or resume notes session\"\n      ;;\n  esac\n}" >> "$HOME/.zshrc"
                        log_success "Added wk function to .zshrc"
                        ;;
                    "check-functions")
                        echo -e "\n# Check if functions are properly loaded\ncheck-functions() {\n  echo \"Testing key functions...\"\n  declare -f mcd > /dev/null && echo \"✓ mcd (make directory and cd) function is available\" || echo \"✗ mcd function is not available\"\n  declare -f nvimf > /dev/null && echo \"✓ nvimf (find and edit with neovim) function is available\" || echo \"✗ nvimf function is not available\"\n  declare -f wk > /dev/null && echo \"✓ wk (session manager) function is available\" || echo \"✗ wk function is not available\"\n}" >> "$HOME/.zshrc"
                        log_success "Added check-functions function to .zshrc"
                        ;;
                    *)
                        log_error "Unknown function to fix: $issue_target"
                        ;;
                esac
            else
                log_error "Cannot add function to non-existent .zshrc file"
            fi
            ;;
        "zsh_alias")
            if [ -f "$HOME/.zshrc" ]; then
                case "$issue_target" in
                    "vim")
                        echo -e "\nalias vim='nvim'" >> "$HOME/.zshrc"
                        log_success "Added vim alias to .zshrc"
                        ;;
                    "vi")
                        echo -e "\nalias vi='nvim'" >> "$HOME/.zshrc"
                        log_success "Added vi alias to .zshrc"
                        ;;
                    "v")
                        echo -e "\nalias v='nvim'" >> "$HOME/.zshrc"
                        log_success "Added v alias to .zshrc"
                        ;;
                    "gs")
                        echo -e "\nalias gs='git status'" >> "$HOME/.zshrc"
                        log_success "Added gs alias to .zshrc"
                        ;;
                    "ga")
                        echo -e "\nalias ga='git add'" >> "$HOME/.zshrc"
                        log_success "Added ga alias to .zshrc"
                        ;;
                    "gc")
                        echo -e "\nalias gc='git commit -m'" >> "$HOME/.zshrc"
                        log_success "Added gc alias to .zshrc"
                        ;;
                    "gp")
                        echo -e "\nalias gp='git push'" >> "$HOME/.zshrc"
                        log_success "Added gp alias to .zshrc"
                        ;;
                    "gl")
                        echo -e "\nalias gl='git pull'" >> "$HOME/.zshrc"
                        log_success "Added gl alias to .zshrc"
                        ;;
                    "ta")
                        echo -e "\nalias ta='tmux attach -t'" >> "$HOME/.zshrc"
                        log_success "Added ta alias to .zshrc"
                        ;;
                    "tls")
                        echo -e "\nalias tls='tmux list-sessions'" >> "$HOME/.zshrc"
                        log_success "Added tls alias to .zshrc"
                        ;;
                    "tn")
                        echo -e "\nalias tn='tmux new -s'" >> "$HOME/.zshrc"
                        log_success "Added tn alias to .zshrc"
                        ;;
                    "tk")
                        echo -e "\nalias tk='tmux kill-session -t'" >> "$HOME/.zshrc"
                        log_success "Added tk alias to .zshrc"
                        ;;
                    "dev")
                        echo -e "\nalias dev='tmux attach -t dev || tmux new -s dev'" >> "$HOME/.zshrc"
                        log_success "Added dev alias to .zshrc"
                        ;;
                    "notes")
                        echo -e "\nalias notes='tmux attach -t notes || tmux new -s notes'" >> "$HOME/.zshrc"
                        log_success "Added notes alias to .zshrc"
                        ;;
                    *)
                        log_error "Unknown alias to fix: $issue_target"
                        ;;
                esac
            else
                log_error "Cannot add alias to non-existent .zshrc file"
            fi
            ;;
        *)
            log_error "Unknown issue type: $issue_type"
            ;;
    esac
}

# Welcome message and mode selection
echo "==============================================================="
echo "      Terminal Environment Health Check                        "
echo "==============================================================="
echo ""
echo "This script will check the health of your terminal environment."
echo ""
echo "Available modes:"
echo "1. Check only (report issues without fixing)"
echo "2. Check and fix (will attempt to automatically fix issues)"
echo ""
read "REPLY?Please select a mode (1-2, default: 1): "
echo ""

# Default to check only
CHECK_MODE="${REPLY:-1}"

case $CHECK_MODE in
    1) MODE_NAME="Check only";;
    2) MODE_NAME="Check and fix";;
    *) log_error "Invalid mode selected. Exiting."; exit 1;;
esac

echo "Running in mode: $MODE_NAME"
echo ""

# Check shell
echo "Checking shell configuration..."
if [[ "$SHELL" == *"zsh"* ]]; then
    log_success "Using Zsh shell: $SHELL"
else
    log_error "Not using Zsh shell: $SHELL"
    echo "To switch to Zsh, run: chsh -s $(which zsh)"
fi

# Check core tools
echo ""
echo "Checking core tools..."
TOOLS_STATUS=0

check_command "zsh" || TOOLS_STATUS=1
check_command "nvim" || TOOLS_STATUS=1
check_command "tmux" || TOOLS_STATUS=1
check_command "git" || TOOLS_STATUS=1
check_command "watchman" || TOOLS_STATUS=1
check_command "fzf" || TOOLS_STATUS=1

# Check core configuration files
echo ""
echo "Checking configuration files..."
CONFIG_STATUS=0

check_file "$HOME/.zshrc" || CONFIG_STATUS=1
check_file "$HOME/.tmux.conf" || CONFIG_STATUS=1
check_directory "$HOME/.config/nvim" || CONFIG_STATUS=1
check_file "$HOME/.config/nvim/init.lua" || CONFIG_STATUS=1
check_directory "$HOME/.config/nvim/lua" || CONFIG_STATUS=1
check_file "$HOME/.config/nvim/lua/plugins.lua" || CONFIG_STATUS=1
check_file "$HOME/.config/nvim/plugin/notes.vim" || CONFIG_STATUS=1

# Check notes system
echo ""
echo "Checking notes system..."
NOTES_STATUS=0

check_directory "$HOME/notes" || NOTES_STATUS=1
check_directory "$HOME/notes/daily" || NOTES_STATUS=1
check_directory "$HOME/notes/projects" || NOTES_STATUS=1
check_directory "$HOME/notes/learning" || NOTES_STATUS=1
check_directory "$HOME/notes/templates" || NOTES_STATUS=1
check_file "$HOME/notes/templates/daily.md" || NOTES_STATUS=1
check_file "$HOME/notes/templates/project.md" || NOTES_STATUS=1
check_file "$HOME/notes/templates/learning.md" || NOTES_STATUS=1

# Check Zsh functions
echo ""
echo "Checking Zsh functions..."
FUNCTIONS_STATUS=0

check_zsh_function "mcd" || FUNCTIONS_STATUS=1
check_zsh_function "nvimf" || FUNCTIONS_STATUS=1
check_zsh_function "wk" || FUNCTIONS_STATUS=1
check_zsh_function "check-functions" || FUNCTIONS_STATUS=1

# Check Zsh aliases
echo ""
echo "Checking Zsh aliases..."
ALIASES_STATUS=0

check_zsh_alias "vim" || ALIASES_STATUS=1
check_zsh_alias "vi" || ALIASES_STATUS=1
check_zsh_alias "v" || ALIASES_STATUS=1
check_zsh_alias "gs" || ALIASES_STATUS=1
check_zsh_alias "ga" || ALIASES_STATUS=1
check_zsh_alias "gc" || ALIASES_STATUS=1
check_zsh_alias "gp" || ALIASES_STATUS=1
check_zsh_alias "gl" || ALIASES_STATUS=1
check_zsh_alias "ta" || ALIASES_STATUS=1
check_zsh_alias "tls" || ALIASES_STATUS=1
check_zsh_alias "tn" || ALIASES_STATUS=1
check_zsh_alias "tk" || ALIASES_STATUS=1
check_zsh_alias "dev" || ALIASES_STATUS=1
check_zsh_alias "notes" || ALIASES_STATUS=1

# Check scripts
echo ""
echo "Checking scripts..."
SCRIPTS_STATUS=0

# Check bin directory exists
check_directory "$HOME/bin" || SCRIPTS_STATUS=1

# Check uninstall script
check_file "$HOME/bin/uninstall-terminal-env.sh" || SCRIPTS_STATUS=1
if [ -f "$HOME/bin/uninstall-terminal-env.sh" ]; then
    check_executable "$HOME/bin/uninstall-terminal-env.sh" || SCRIPTS_STATUS=1
fi

# Summary
echo ""
echo "==============================================================="
echo "                    HEALTH CHECK SUMMARY                       "
echo "==============================================================="
echo ""

if [[ $TOOLS_STATUS -eq 0 && $CONFIG_STATUS -eq 0 && $NOTES_STATUS -eq 0 && $FUNCTIONS_STATUS -eq 0 && $ALIASES_STATUS -eq 0 && $SCRIPTS_STATUS -eq 0 ]]; then
    log_success "All checks passed! Your terminal environment is healthy."
else
    log_warning "Some checks failed. See details above."
    
    # Fix issues if in fix mode
    if [[ "$CHECK_MODE" == "2" ]]; then
        echo ""
        echo "==============================================================="
        echo "                    ATTEMPTING FIXES                          "
        echo "==============================================================="
        echo ""
        
        # Fix directory issues
        if [[ $NOTES_STATUS -ne 0 ]]; then
            echo "Fixing notes system directories..."
            [ -d "$HOME/notes" ] || fix_issue "directory" "$HOME/notes"
            [ -d "$HOME/notes/daily" ] || fix_issue "directory" "$HOME/notes/daily"
            [ -d "$HOME/notes/projects" ] || fix_issue "directory" "$HOME/notes/projects"
            [ -d "$HOME/notes/learning" ] || fix_issue "directory" "$HOME/notes/learning"
            [ -d "$HOME/notes/templates" ] || fix_issue "directory" "$HOME/notes/templates"
            
            # Create templates if missing
            if [ ! -f "$HOME/notes/templates/daily.md" ]; then
                cat > "$HOME/notes/templates/daily.md" << 'EOL'
# Daily Note: {{date}}

## Focus Areas
- 

## Notes
- 

## Tasks
- [ ] 

## Progress
- 

## Links
- 
EOL
                log_success "Created daily.md template"
            fi
            
            if [ ! -f "$HOME/notes/templates/project.md" ]; then
                cat > "$HOME/notes/templates/project.md" << 'EOL'
# Project: {{project_name}}

## Overview
- **Goal**: 
- **Timeline**: 
- **Status**: 

## Requirements
- 

## Notes
- 

## Tasks
- [ ] 

## Resources
- 
EOL
                log_success "Created project.md template"
            fi
            
            if [ ! -f "$HOME/notes/templates/learning.md" ]; then
                cat > "$HOME/notes/templates/learning.md" << 'EOL'
# Learning: {{topic}}

## Objectives
- 

## Key Concepts
- 

## Code Examples
```
# Code example here
```

## Resources
- 

## Questions
- 

## Practice
- 
EOL
                log_success "Created learning.md template"
            fi
        fi
        
        # Fix Neovim configuration
        if [[ $CONFIG_STATUS -ne 0 ]]; then
            echo "Fixing configuration files..."
            
            # Create Neovim plugin directory if missing
            if [ ! -d "$HOME/.config/nvim/plugin" ]; then
                mkdir -p "$HOME/.config/nvim/plugin"
                log_success "Created Neovim plugin directory"
            fi
            
            # Create notes.vim if missing
            if [ ! -f "$HOME/.config/nvim/plugin/notes.vim" ]; then
                fix_issue "nvim_plugin" "$HOME/.config/nvim/plugin/notes.vim"
                # Copy the basic notes.vim content (shortened for this example)
                cat > "$HOME/.config/nvim/plugin/notes.vim" << 'EOL'
" Notes System Configuration
let g:notes_dir = expand('~/notes')
command! Notes cd ${g:notes_dir}
command! NotesEdit edit ${g:notes_dir}

function! CreateDailyNote()
  let l:date = strftime('%Y-%m-%d')
  let l:daily_dir = g:notes_dir . '/daily'
  if !isdirectory(l:daily_dir)
    call system('mkdir -p ' . shellescape(l:daily_dir))
  endif
  let l:file_path = l:daily_dir . '/' . l:date . '.md'
  execute 'edit ' . l:file_path
endfunction

command! Daily call CreateDailyNote()
EOL
                log_success "Created basic notes.vim plugin"
            fi
        fi
        
        # Fix Zsh functions
        if [[ $FUNCTIONS_STATUS -ne 0 ]]; then
            echo "Fixing Zsh functions..."
            
            check_zsh_function "mcd" || fix_issue "zsh_function" "mcd"
            check_zsh_function "nvimf" || fix_issue "zsh_function" "nvimf"
            check_zsh_function "wk" || fix_issue "zsh_function" "wk"
            check_zsh_function "check-functions" || fix_issue "zsh_function" "check-functions"
        fi
        
        # Fix Zsh aliases
        if [[ $ALIASES_STATUS -ne 0 ]]; then
            echo "Fixing Zsh aliases..."
            
            check_zsh_alias "vim" || fix_issue "zsh_alias" "vim"
            check_zsh_alias "vi" || fix_issue "zsh_alias" "vi"
            check_zsh_alias "v" || fix_issue "zsh_alias" "v"
            check_zsh_alias "gs" || fix_issue "zsh_alias" "gs"
            check_zsh_alias "ga" || fix_issue "zsh_alias" "ga"
            check_zsh_alias "gc" || fix_issue "zsh_alias" "gc"
            check_zsh_alias "gp" || fix_issue "zsh_alias" "gp"
            check_zsh_alias "gl" || fix_issue "zsh_alias" "gl"
            check_zsh_alias "ta" || fix_issue "zsh_alias" "ta"
            check_zsh_alias "tls" || fix_issue "zsh_alias" "tls"
            check_zsh_alias "tn" || fix_issue "zsh_alias" "tn"
            check_zsh_alias "tk" || fix_issue "zsh_alias" "tk"
            check_zsh_alias "dev" || fix_issue "zsh_alias" "dev"
            check_zsh_alias "notes" || fix_issue "zsh_alias" "notes"
        fi
        
        # Fix script issues
        if [[ $SCRIPTS_STATUS -ne 0 ]]; then
            echo "Fixing script issues..."
            
            # Create bin directory if missing
            if [ ! -d "$HOME/bin" ]; then
                mkdir -p "$HOME/bin"
                log_success "Created bin directory"
            fi
            
            # Create/fix uninstall script
            if [ ! -f "$HOME/bin/uninstall-terminal-env.sh" ]; then
                echo "Creating uninstall script..."
                create_uninstall_script
            elif [ ! -x "$HOME/bin/uninstall-terminal-env.sh" ]; then
                chmod +x "$HOME/bin/uninstall-terminal-env.sh"
                log_success "Made existing uninstall script executable"
            fi
        fi
        
        echo ""
        log_success "Fixes applied. Please restart your terminal or run 'source ~/.zshrc' for changes to take effect."
    else
        echo ""
        echo "To automatically fix these issues, run this script again with fix mode:"
        echo "./health-check.sh and select option 2"
    fi
fi

echo ""
if [[ "$CHECK_MODE" == "1" && ($TOOLS_STATUS -ne 0 || $CONFIG_STATUS -ne 0 || $NOTES_STATUS -ne 0 || $FUNCTIONS_STATUS -ne 0 || $ALIASES_STATUS -ne 0 || $SCRIPTS_STATUS -ne 0) ]]; then
    echo "For a complete reinstallation, run the installer script with:"
    echo "curl -fsSL https://raw.githubusercontent.com/JoshuaMichaelHall-Tech/terminal-setup/main/install.sh > install.sh && chmod +x install.sh && ./install.sh"
fi