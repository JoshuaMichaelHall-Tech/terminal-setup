#!/bin/zsh

# Terminal Environment Troubleshooting Script
# This script copies all relevant configuration files to ~/.files_for_troubleshooting
# for easier debugging of the terminal-centric notes system and development environment.

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Destination directory
TROUBLESHOOT_DIR="$HOME/.files_for_troubleshooting"

# Create the troubleshooting directory
mkdir -p "$TROUBLESHOOT_DIR"
echo -e "${BLUE}Created troubleshooting directory: $TROUBLESHOOT_DIR${NC}"

# Function to copy a file if it exists
copy_if_exists() {
    local src="$1"
    local dest="$2"
    local destdir="$(dirname "$dest")"
    
    if [[ -f "$src" ]]; then
        mkdir -p "$destdir"
        cp "$src" "$dest"
        echo -e "${GREEN}✓ Copied $src to $dest${NC}"
    else
        echo -e "${YELLOW}! File not found: $src${NC}"
    fi
}

# Function to copy a directory if it exists
copy_dir_if_exists() {
    local src="$1"
    local dest="$2"
    
    if [[ -d "$src" ]]; then
        mkdir -p "$dest"
        cp -r "$src"/* "$dest"
        echo -e "${GREEN}✓ Copied directory $src to $dest${NC}"
    else
        echo -e "${YELLOW}! Directory not found: $src${NC}"
    fi
}

echo -e "\n${BLUE}=== Copying Shell Configuration Files ===${NC}"
# Shell configuration files
copy_if_exists "$HOME/.zshrc" "$TROUBLESHOOT_DIR/shell/.zshrc"
copy_if_exists "$HOME/.zprofile" "$TROUBLESHOOT_DIR/shell/.zprofile"
copy_if_exists "$HOME/.zshenv" "$TROUBLESHOOT_DIR/shell/.zshenv"
copy_if_exists "$HOME/.bash_profile" "$TROUBLESHOOT_DIR/shell/.bash_profile"
copy_if_exists "$HOME/.bashrc" "$TROUBLESHOOT_DIR/shell/.bashrc"
copy_if_exists "$HOME/.profile" "$TROUBLESHOOT_DIR/shell/.profile"
copy_if_exists "$HOME/.p10k.zsh" "$TROUBLESHOOT_DIR/shell/.p10k.zsh"

echo -e "\n${BLUE}=== Copying Neovim Configuration Files ===${NC}"
# Neovim configuration files
copy_if_exists "$HOME/.config/nvim/init.lua" "$TROUBLESHOOT_DIR/nvim/init.lua"
copy_if_exists "$HOME/.config/nvim/init.vim" "$TROUBLESHOOT_DIR/nvim/init.vim"
copy_dir_if_exists "$HOME/.config/nvim/lua" "$TROUBLESHOOT_DIR/nvim/lua"
copy_dir_if_exists "$HOME/.config/nvim/plugin" "$TROUBLESHOOT_DIR/nvim/plugin"
copy_dir_if_exists "$HOME/.config/nvim/after" "$TROUBLESHOOT_DIR/nvim/after"

echo -e "\n${BLUE}=== Copying tmux Configuration Files ===${NC}"
# tmux configuration files
copy_if_exists "$HOME/.tmux.conf" "$TROUBLESHOOT_DIR/tmux/.tmux.conf"
copy_dir_if_exists "$HOME/.tmux" "$TROUBLESHOOT_DIR/tmux/plugins"

echo -e "\n${BLUE}=== Copying Notes System Files ===${NC}"
# Notes system files
copy_dir_if_exists "$HOME/notes/templates" "$TROUBLESHOOT_DIR/notes/templates"
copy_if_exists "$HOME/notes/README.md" "$TROUBLESHOOT_DIR/notes/README.md"

echo -e "\n${BLUE}=== Copying Challenge Scripts ===${NC}"
# 6/7 Coding Challenge scripts
for script in cc-setup.sh cc-start-day.sh cc-log-progress.sh cc-push-updates.sh cc-status.sh; do
    copy_if_exists "$HOME/bin/$script" "$TROUBLESHOOT_DIR/bin/$script"
done

# Check for day counter file
copy_if_exists "$HOME/.cc-current-day" "$TROUBLESHOOT_DIR/.cc-current-day"

echo -e "\n${BLUE}=== Gathering Environment Information ===${NC}"
# Create environment info file
ENV_INFO="$TROUBLESHOOT_DIR/environment-info.txt"
{
    echo "# Environment Information"
    echo "Date: $(date)"
    echo "Username: $(whoami)"
    echo "Hostname: $(hostname)"
    echo ""
    
    echo "## Shell Information"
    echo "Current shell: $SHELL"
    echo "ZSH version: $(zsh --version 2>/dev/null || echo 'Not installed')"
    echo "Bash version: $(bash --version 2>/dev/null | head -n 1 || echo 'Not installed')"
    echo ""
    
    echo "## Terminal Application"
    if [[ -d "/Applications/iTerm.app" ]]; then
        echo "iTerm2 is installed"
    else
        echo "iTerm2 is not installed"
    fi
    echo ""
    
    echo "## Core Tool Versions"
    echo "Neovim: $(nvim --version 2>/dev/null | head -n 1 || echo 'Not installed')"
    echo "Vim: $(vim --version 2>/dev/null | head -n 1 || echo 'Not installed')"
    echo "tmux: $(tmux -V 2>/dev/null || echo 'Not installed')"
    echo "Git: $(git --version 2>/dev/null || echo 'Not installed')"
    echo "Ruby: $(ruby --version 2>/dev/null || echo 'Not installed')"
    echo "Python: $(python3 --version 2>/dev/null || echo 'Not installed')"
    echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
    echo ""
    
    echo "## Search Tools"
    echo "ripgrep: $(rg --version 2>/dev/null | head -n 1 || echo 'Not installed')"
    echo "fzf: $(fzf --version 2>/dev/null || echo 'Not installed')"
    echo ""
    
    echo "## Package Managers"
    echo "Homebrew: $(brew --version 2>/dev/null | head -n 1 || echo 'Not installed')"
    echo ""
    
    echo "## Notes System"
    if [[ -d "$HOME/notes" ]]; then
        echo "Notes directory exists: Yes"
        echo "Notes templates exist: $(ls -l $HOME/notes/templates 2>/dev/null | wc -l) files"
    else
        echo "Notes directory exists: No"
    fi
    
    if [[ -f "$HOME/.cc-current-day" ]]; then
        echo "Challenge day counter: $(cat $HOME/.cc-current-day 2>/dev/null)"
    else
        echo "Challenge day counter: Not found"
    fi
    echo ""
    
    echo "## tmux Sessions"
    echo "Current tmux sessions:"
    tmux list-sessions 2>/dev/null || echo "No active tmux sessions or tmux not running"
    
} > "$ENV_INFO"

echo -e "${GREEN}✓ Environment information written to $ENV_INFO${NC}"

echo -e "\n${BLUE}=== Checking for Path Issues ===${NC}"
# Create a PATH analysis file
PATH_INFO="$TROUBLESHOOT_DIR/path-analysis.txt"
{
    echo "# PATH Analysis"
    echo "Date: $(date)"
    echo ""
    
    echo "## Current PATH"
    echo "$PATH" | tr ':' '\n'
    echo ""
    
    echo "## Directory Existence Check"
    for dir in $(echo "$PATH" | tr ':' '\n'); do
        if [[ -d "$dir" ]]; then
            echo "✓ $dir (exists)"
        else
            echo "✗ $dir (does not exist)"
        fi
    done
    echo ""
    
    echo "## Binary Availability Check"
    for cmd in nvim vim tmux git ruby python3 node rg fzf watchman; do
        which_path=$(which $cmd 2>/dev/null)
        if [[ -n "$which_path" ]]; then
            echo "✓ $cmd: $which_path"
        else
            echo "✗ $cmd: Not found in PATH"
        fi
    done
    
} > "$PATH_INFO"

echo -e "${GREEN}✓ PATH analysis written to $PATH_INFO${NC}"

echo -e "\n${BLUE}=== Checking for Script Permissions ===${NC}"
# Check script permissions
PERM_INFO="$TROUBLESHOOT_DIR/permissions-check.txt"
{
    echo "# Script Permissions Check"
    echo "Date: $(date)"
    echo ""
    
    echo "## Challenge Scripts"
    for script in cc-setup.sh cc-start-day.sh cc-log-progress.sh cc-push-updates.sh cc-status.sh; do
        if [[ -f "$HOME/bin/$script" ]]; then
            echo "$script: $(ls -la $HOME/bin/$script)"
        else
            echo "$script: Not found"
        fi
    done
    echo ""
    
    echo "## Main Directories"
    echo "$HOME/bin: $(ls -ld $HOME/bin 2>/dev/null || echo 'Not found')"
    echo "$HOME/notes: $(ls -ld $HOME/notes 2>/dev/null || echo 'Not found')"
    echo "$HOME/projects: $(ls -ld $HOME/projects 2>/dev/null || echo 'Not found')"
    echo "$HOME/projects/6-7-coding-challenge: $(ls -ld $HOME/projects/6-7-coding-challenge 2>/dev/null || echo 'Not found')"
    
} > "$PERM_INFO"

echo -e "${GREEN}✓ Permission check written to $PERM_INFO${NC}"

echo -e "\n${BLUE}=== Creating Troubleshooting README ===${NC}"
# Create README with troubleshooting instructions
README="$TROUBLESHOOT_DIR/README.md"
{
    echo "# Terminal Environment Troubleshooting"
    echo ""
    echo "This directory contains copies of configuration files and system information to help troubleshoot issues with your terminal-centric notes system and development environment."
    echo ""
    echo "## Directory Structure"
    echo ""
    echo "- **shell/**: Shell configuration files (.zshrc, .bashrc, etc.)"
    echo "- **nvim/**: Neovim configuration files (init.lua, plugins, etc.)"
    echo "- **tmux/**: tmux configuration files (.tmux.conf, plugins)"
    echo "- **notes/**: Sample files from the notes system"
    echo "- **bin/**: Challenge script files (cc-start-day.sh, etc.)"
    echo "- **environment-info.txt**: System and tool version information"
    echo "- **path-analysis.txt**: PATH environment variable analysis"
    echo "- **permissions-check.txt**: File permission checks"
    echo ""
    echo "## Common Issues and Solutions"
    echo ""
    echo "### Script Permission Issues"
    echo ""
    echo "If scripts aren't executable, fix with:"
    echo "```bash"
    echo "chmod +x ~/bin/cc-*.sh"
    echo "```"
    echo ""
    echo "### Missing ~/bin in PATH"
    echo ""
    echo "If binaries in ~/bin aren't found, add to PATH in .zshrc:"
    echo "```bash"
    echo "export PATH=\$HOME/bin:\$PATH"
    echo "```"
    echo ""
    echo "### tmux Configuration Issues"
    echo ""
    echo "If tmux shows errors or unexpected behavior:"
    echo "1. Check for syntax errors in .tmux.conf"
    echo "2. Try resetting with: `tmux kill-server`"
    echo "3. Start fresh session: `tmux new-session -s test`"
    echo ""
    echo "### Missing Day Counter"
    echo ""
    echo "If ~/.cc-current-day is missing:"
    echo "```bash"
    echo "echo \"1\" > ~/.cc-current-day"
    echo "```"
    echo ""
    echo "### Missing Required Software"
    echo ""
    echo "Install required tools with Homebrew:"
    echo "```bash"
    echo "brew install neovim tmux git watchman ripgrep fzf"
    echo "```"
    echo ""
    echo "### Common Zsh Issues"
    echo ""
    echo "If aliases aren't working:"
    echo "1. Check if they're defined in .zshrc"
    echo "2. Make sure .zshrc is being sourced"
    echo "3. Try: `source ~/.zshrc`"
    echo ""
    echo "### Repository Structure Issues"
    echo ""
    echo "Expected structure for 6/7 Coding Challenge:"
    echo "```"
    echo "~/projects/6-7-coding-challenge/"
    echo "├── logs/               # Challenge logs"
    echo "│   └── phase1/         # Phase 1 logs"
    echo "├── phase1_ruby/        # Phase 1 project code"
    echo "│   └── week01/         # Week 1 directories"
    echo "└── scripts/            # Challenge scripts"
    echo "```"
    echo ""
    echo "### Notes System Directory Issues"
    echo ""
    echo "Expected structure for Notes system:"
    echo "```"
    echo "~/notes/"
    echo "├── daily/              # Daily notes"
    echo "├── projects/           # Project notes"
    echo "├── learning/           # Learning notes"
    echo "└── templates/          # Note templates"
    echo "```"
} > "$README"

echo -e "${GREEN}✓ Troubleshooting README written to $README${NC}"

echo -e "\n${GREEN}=== Troubleshooting Files Collection Complete ===${NC}"
echo -e "All relevant files have been collected in ${BLUE}$TROUBLESHOOT_DIR${NC}"
echo -e "Review the README.md file in that directory for troubleshooting guidance."
