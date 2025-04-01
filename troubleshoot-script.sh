#!/bin/zsh

# Terminal Development Environment Troubleshooter
# Author: Joshua Michael Hall
# License: MIT
# Date: April 1, 2025

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Essential directories and files
NOTES_DIR="$HOME/notes"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
TMUX_CONF="$HOME/.tmux.conf"
ZSHRC="$HOME/.zshrc"

# Function to print section headers
print_header() {
  echo ""
  echo "======================================================================"
  echo "  $1"
  echo "======================================================================"
  echo ""
}

# Function to check success or failure
check_result() {
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ $1${NC}"
    return 0
  else
    echo -e "${RED}✗ $1${NC}"
    return 1
  fi
}

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to verify file/directory existence
check_exists() {
  if [ -e "$1" ]; then
    echo -e "${GREEN}✓ $1exists${NC}"
    return 0
  else
    echo -e "${RED}✗ $1 does not exist${NC}"
    return 1
  fi
}

# Function to check Zsh configuration
check_zsh() {
  print_header "Checking Zsh Configuration"
  
  # Check if using Zsh
  if [[ "$SHELL" == *"zsh"* ]]; then
    echo -e "${GREEN}✓ Current shell is Zsh${NC}"
  else
    echo -e "${RED}✗ Current shell is not Zsh ($SHELL)${NC}"
    echo -e "${YELLOW}→ To set Zsh as default: chsh -s $(which zsh)${NC}"
  fi
  
  # Check .zshrc
  check_exists "$ZSHRC"
  if [ $? -eq 0 ]; then
    # Check for key configurations
    echo -e "${BLUE}Checking .zshrc for key configurations...${NC}"
    
    # Check for Oh My Zsh
    if grep -q "ZSH=" "$ZSHRC"; then
      echo -e "${GREEN}✓ Oh My Zsh configuration found${NC}"
    else
      echo -e "${YELLOW}! Oh My Zsh configuration not found${NC}"
      echo -e "${YELLOW}→ Consider installing Oh My Zsh: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"${NC}"
    fi
    
    # Check for Powerlevel10k
    if grep -q "powerlevel10k" "$ZSHRC"; then
      echo -e "${GREEN}✓ Powerlevel10k theme configuration found${NC}"
    else
      echo -e "${YELLOW}! Powerlevel10k theme not found${NC}"
      echo -e "${YELLOW}→ Consider installing Powerlevel10k for better terminal experience${NC}"
    fi
    
    # Check for essential Zsh options
    if grep -q "setopt AUTO_PUSHD" "$ZSHRC"; then
      echo -e "${GREEN}✓ Directory stack options found${NC}"
    else
      echo -e "${YELLOW}! Directory stack options not found${NC}"
      echo -e "${YELLOW}→ Consider adding directory stack options to .zshrc${NC}"
    fi
    
    # Check for common aliases
    if grep -q "alias " "$ZSHRC"; then
      echo -e "${GREEN}✓ Aliases found in .zshrc${NC}"
    else
      echo -e "${YELLOW}! No aliases found in .zshrc${NC}"
      echo -e "${YELLOW}→ Consider adding useful aliases to improve workflow${NC}"
    fi
    
    # Check for custom functions
    if grep -q "function" "$ZSHRC" || grep -q "() {" "$ZSHRC"; then
      echo -e "${GREEN}✓ Custom functions found in .zshrc${NC}"
    else
      echo -e "${YELLOW}! No custom functions found in .zshrc${NC}"
      echo -e "${YELLOW}→ Consider adding useful functions like 'mcd' and 'check-functions'${NC}"
    fi
  fi
}

# Function to check Neovim configuration
check_neovim() {
  print_header "Checking Neovim Configuration"
  
  # Check if Neovim is installed
  if command_exists nvim; then
    echo -e "${GREEN}✓ Neovim is installed${NC}"
    NVIM_VERSION=$(nvim --version | head -n 1)
    echo -e "${BLUE}→ $NVIM_VERSION${NC}"
  else
    echo -e "${RED}✗ Neovim is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install neovim${NC}"
    return 1
  fi
  
  # Check for Neovim config directory
  check_exists "$NVIM_CONFIG_DIR/"
  if [ $? -eq 0 ]; then
    # Check for init.lua or init.vim
    if [ -f "$NVIM_CONFIG_DIR/init.lua" ]; then
      echo -e "${GREEN}✓ Using init.lua configuration${NC}"
      CONFIG_TYPE="lua"
    elif [ -f "$NVIM_CONFIG_DIR/init.vim" ]; then
      echo -e "${GREEN}✓ Using init.vim configuration${NC}"
      CONFIG_TYPE="vim"
    else
      echo -e "${RED}✗ No init.lua or init.vim found${NC}"
      echo -e "${YELLOW}→ Create Neovim configuration file${NC}"
    fi
    
    # Check for plugin system
    if [ "$CONFIG_TYPE" = "lua" ]; then
      if grep -q "lazy.nvim" "$NVIM_CONFIG_DIR/init.lua"; then
        echo -e "${GREEN}✓ lazy.nvim plugin manager found${NC}"
      elif grep -q "packer" "$NVIM_CONFIG_DIR/init.lua"; then
        echo -e "${GREEN}✓ packer.nvim plugin manager found${NC}"
      else
        echo -e "${YELLOW}! No plugin manager found in init.lua${NC}"
        echo -e "${YELLOW}→ Consider setting up lazy.nvim or packer.nvim${NC}"
      fi
    elif [ "$CONFIG_TYPE" = "vim" ]; then
      if grep -q "plug#begin" "$NVIM_CONFIG_DIR/init.vim"; then
        echo -e "${GREEN}✓ vim-plug found${NC}"
      else
        echo -e "${YELLOW}! No plugin manager found in init.vim${NC}"
        echo -e "${YELLOW}→ Consider setting up vim-plug${NC}"
      fi
    fi
    
    # Check for LSP configuration
    if [ -d "$NVIM_CONFIG_DIR/lua" ]; then
      if grep -q "lspconfig" "$NVIM_CONFIG_DIR/init.lua" || find "$NVIM_CONFIG_DIR/lua" -type f -name "*.lua" | xargs grep -q "lspconfig"; then
        echo -e "${GREEN}✓ LSP configuration found${NC}"
      else
        echo -e "${YELLOW}! No LSP configuration found${NC}"
        echo -e "${YELLOW}→ Consider setting up nvim-lspconfig${NC}"
      fi
    fi
    
    # Check for notes plugin
    if [ -f "$NVIM_CONFIG_DIR/plugin/notes.vim" ]; then
      echo -e "${GREEN}✓ Notes plugin found${NC}"
    else
      echo -e "${YELLOW}! Notes plugin not found${NC}"
      echo -e "${YELLOW}→ Consider adding plugin/notes.vim for notes functionality${NC}"
    fi
    
    # Check if directory exists
    if [ -d "$HOME/.local/share/nvim/site/pack" ] || [ -d "$HOME/.local/share/nvim/lazy" ]; then
      echo -e "${GREEN}✓ Plugin directory exists${NC}"
    else
      echo -e "${YELLOW}! Plugin directory not found${NC}"
      echo -e "${YELLOW}→ Plugins may not be installed. Open Neovim and install plugins${NC}"
    fi
  fi
}

# Function to check tmux configuration
check_tmux() {
  print_header "Checking tmux Configuration"
  
  # Check if tmux is installed
  if command_exists tmux; then
    echo -e "${GREEN}✓ tmux is installed${NC}"
    TMUX_VERSION=$(tmux -V)
    echo -e "${BLUE}→ $TMUX_VERSION${NC}"
  else
    echo -e "${RED}✗ tmux is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install tmux${NC}"
    return 1
  fi
  
  # Check for tmux config
  check_exists "$TMUX_CONF"
  if [ $? -eq 0 ]; then
    # Check for key configurations
    echo -e "${BLUE}Checking tmux.conf for key configurations...${NC}"
    
    # Check for prefix key
    if grep -q "prefix" "$TMUX_CONF"; then
      if grep -q "prefix C-a" "$TMUX_CONF"; then
        echo -e "${GREEN}✓ tmux prefix set to Ctrl+a${NC}"
      else
        echo -e "${YELLOW}! Custom tmux prefix found (not Ctrl+a)${NC}"
      fi
    else
      echo -e "${YELLOW}! No prefix configuration found${NC}"
      echo -e "${YELLOW}→ Consider setting prefix to Ctrl+a for easier use${NC}"
    fi
    
    # Check for plugin manager
    if grep -q "tpm" "$TMUX_CONF"; then
      echo -e "${GREEN}✓ tmux plugin manager (tpm) found${NC}"
      
      # Check if tpm is installed
      if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        echo -e "${GREEN}✓ tpm is installed${NC}"
      else
        echo -e "${RED}✗ tpm directory not found${NC}"
        echo -e "${YELLOW}→ Install tpm: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm${NC}"
      fi
    else
      echo -e "${YELLOW}! No tmux plugin manager found${NC}"
      echo -e "${YELLOW}→ Consider installing tpm for plugin management${NC}"
    fi
    
    # Check for mouse mode
    if grep -q "mouse on" "$TMUX_CONF"; then
      echo -e "${GREEN}✓ Mouse mode is enabled${NC}"
    else
      echo -e "${YELLOW}! Mouse mode not found${NC}"
      echo -e "${YELLOW}→ Consider adding 'set -g mouse on' for easier transition${NC}"
    fi
    
    # Check for vi mode
    if grep -q "mode-keys vi" "$TMUX_CONF"; then
      echo -e "${GREEN}✓ Vi mode is enabled${NC}"
    else
      echo -e "${YELLOW}! Vi mode not found${NC}"
      echo -e "${YELLOW}→ Consider adding 'setw -g mode-keys vi' for Vim-like keybindings${NC}"
    fi
  fi
  
  # Check for active tmux sessions
  if tmux has-session 2>/dev/null; then
    echo -e "${GREEN}✓ Active tmux sessions found${NC}"
    echo -e "${BLUE}→ Current sessions:${NC}"
    tmux list-sessions | sed 's/^/   /'
  else
    echo -e "${YELLOW}! No active tmux sessions${NC}"
  fi
}

# Function to check notes system
check_notes() {
  print_header "Checking Notes System"
  
  # Check if notes directory exists
  check_exists "$NOTES_DIR/"
  if [ $? -eq 0 ]; then
    # Check if notes directory is a git repository
    if [ -d "$NOTES_DIR/.git" ]; then
      echo -e "${GREEN}✓ Notes directory is a Git repository${NC}"
      
      # Check Git remote
      REMOTE=$(cd "$NOTES_DIR" && git remote -v 2>/dev/null)
      if [ -n "$REMOTE" ]; then
        echo -e "${GREEN}✓ Git remote is configured${NC}"
        echo -e "${BLUE}→ Remote:${NC}"
        echo "$REMOTE" | sed 's/^/   /'
      else
        echo -e "${YELLOW}! No Git remote configured${NC}"
        echo -e "${YELLOW}→ Consider adding a remote for backup/sync${NC}"
      fi
      
      # Check Git status
      CHANGES=$(cd "$NOTES_DIR" && git status --porcelain 2>/dev/null)
      if [ -n "$CHANGES" ]; then
        echo -e "${YELLOW}! Uncommitted changes in notes repository${NC}"
        echo -e "${BLUE}→ Changed files:${NC}"
        echo "$CHANGES" | head -n 5 | sed 's/^/   /'
        if [ $(echo "$CHANGES" | wc -l) -gt 5 ]; then
          echo -e "   ... and $(($(echo "$CHANGES" | wc -l) - 5)) more"
        fi
      else
        echo -e "${GREEN}✓ Notes repository is clean${NC}"
      fi
    else
      echo -e "${RED}✗ Notes directory is not a Git repository${NC}"
      echo -e "${YELLOW}→ Initialize with: cd $NOTES_DIR && git init${NC}"
    fi
    
    # Check directory structure
    for DIR in daily projects learning templates; do
      if [ -d "$NOTES_DIR/$DIR" ]; then
        echo -e "${GREEN}✓ $DIR directory exists${NC}"
      else
        echo -e "${RED}✗ $DIR directory does not exist${NC}"
        echo -e "${YELLOW}→ Create with: mkdir -p $NOTES_DIR/$DIR${NC}"
      fi
    done
    
    # Check templates
    for TEMPLATE in daily.md project.md learning.md; do
      if [ -f "$NOTES_DIR/templates/$TEMPLATE" ]; then
        echo -e "${GREEN}✓ $TEMPLATE template exists${NC}"
      else
        echo -e "${RED}✗ $TEMPLATE template does not exist${NC}"
        echo -e "${YELLOW}→ Create template file: $NOTES_DIR/templates/$TEMPLATE${NC}"
      fi
    done
  fi
  
  # Check Watchman for auto-syncing
  if command_exists watchman; then
    echo -e "${GREEN}✓ Watchman is installed${NC}"
    
    # Check if notes directory is being watched
    WATCHES=$(watchman watch-list 2>/dev/null)
    if echo "$WATCHES" | grep -q "$NOTES_DIR"; then
      echo -e "${GREEN}✓ Notes directory is being watched by Watchman${NC}"
    else
      echo -e "${YELLOW}! Notes directory is not being watched by Watchman${NC}"
      echo -e "${YELLOW}→ Add with: watchman watch $NOTES_DIR${NC}"
    fi
  else
    echo -e "${YELLOW}! Watchman is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install watchman${NC}"
  fi
  
  # Check LaunchAgent for Watchman
  LAUNCH_AGENT="$HOME/Library/LaunchAgents/com.facebook.watchman.plist"
  if [ -f "$LAUNCH_AGENT" ]; then
    echo -e "${GREEN}✓ Watchman LaunchAgent exists${NC}"
    
    # Check if LaunchAgent is loaded
    if launchctl list | grep -q "com.facebook.watchman"; then
      echo -e "${GREEN}✓ Watchman LaunchAgent is loaded${NC}"
    else
      echo -e "${YELLOW}! Watchman LaunchAgent is not loaded${NC}"
      echo -e "${YELLOW}→ Load with: launchctl load $LAUNCH_AGENT${NC}"
    fi
  else
    echo -e "${YELLOW}! Watchman LaunchAgent does not exist${NC}"
    echo -e "${YELLOW}→ See setup guide for configuring Watchman auto-start${NC}"
  fi
}

# Function to check additional tools
check_tools() {
  print_header "Checking Additional Tools"
  
  # Check Git
  if command_exists git; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✓ Git installed: $GIT_VERSION${NC}"
  else
    echo -e "${RED}✗ Git is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install git${NC}"
  fi
  
  # Check ripgrep
  if command_exists rg; then
    RG_VERSION=$(rg --version | head -n 1)
    echo -e "${GREEN}✓ ripgrep installed: $RG_VERSION${NC}"
  else
    echo -e "${YELLOW}! ripgrep is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install ripgrep${NC}"
  fi
  
  # Check fzf
  if command_exists fzf; then
    FZF_VERSION=$(fzf --version)
    echo -e "${GREEN}✓ fzf installed: $FZF_VERSION${NC}"
  else
    echo -e "${YELLOW}! fzf is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install fzf${NC}"
  fi
  
  # Check fd
  if command_exists fd; then
    FD_VERSION=$(fd --version)
    echo -e "${GREEN}✓ fd installed: $FD_VERSION${NC}"
  else
    echo -e "${YELLOW}! fd is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install fd${NC}"
  fi
  
  # Check Homebrew
  if command_exists brew; then
    BREW_VERSION=$(brew --version | head -n 1)
    echo -e "${GREEN}✓ Homebrew installed: $BREW_VERSION${NC}"
  else
    echo -e "${RED}✗ Homebrew is not installed${NC}"
    echo -e "${YELLOW}→ Install from: https://brew.sh${NC}"
  fi
  
  # Check for rectangle window manager
  if [ -d "/Applications/Rectangle.app" ]; then
    echo -e "${GREEN}✓ Rectangle window manager is installed${NC}"
  else
    echo -e "${YELLOW}! Rectangle window manager is not installed${NC}"
    echo -e "${YELLOW}→ Install with: brew install --cask rectangle${NC}"
  fi
  
  # Check for custom fonts
  if find ~/Library/Fonts -name "*Nerd*Font*" | grep -q .; then
    echo -e "${GREEN}✓ Nerd Fonts are installed${NC}"
  else
    echo -e "${YELLOW}! No Nerd Fonts found${NC}"
    echo -e "${YELLOW}→ Install with: brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font${NC}"
  fi
}

# Function to check for common issues
check_common_issues() {
  print_header "Checking for Common Issues"
  
  # Check if notes-session script exists
  if [ -f "$HOME/bin/notes-session" ]; then
    echo -e "${GREEN}✓ notes-session script exists${NC}"
  else
    echo -e "${YELLOW}! notes-session script not found${NC}"
    echo -e "${YELLOW}→ Create script in ~/bin/notes-session${NC}"
  fi
  
  # Check PATH for ~/bin
  if echo $PATH | grep -q "$HOME/bin"; then
    echo -e "${GREEN}✓ ~/bin is in PATH${NC}"
  else
    echo -e "${YELLOW}! ~/bin is not in PATH${NC}"
    echo -e "${YELLOW}→ Add to .zshrc: export PATH=\$HOME/bin:\$PATH${NC}"
  fi
  
  # Check if custom functions are available
  if type check-functions >/dev/null 2>&1; then
    echo -e "${GREEN}✓ check-functions is available${NC}"
  else
    echo -e "${YELLOW}! check-functions function not found${NC}"
    echo -e "${YELLOW}→ Add function to .zshrc${NC}"
  fi
  
  if type mcd >/dev/null 2>&1; then
    echo -e "${GREEN}✓ mcd function is available${NC}"
  else
    echo -e "${YELLOW}! mcd function not found${NC}"
    echo -e "${YELLOW}→ Add function to .zshrc${NC}"
  fi
  
  if type wk >/dev/null 2>&1; then
    echo -e "${GREEN}✓ wk function is available${NC}"
  else
    echo -e "${YELLOW}! wk function not found${NC}"
    echo -e "${YELLOW}→ Add function to .zshrc${NC}"
  fi
  
  # Check if essential aliases are available
  ALIASES=$(alias)
  
  if echo "$ALIASES" | grep -q "alias gs="; then
    echo -e "${GREEN}✓ git status alias is available${NC}"
  else
    echo -e "${YELLOW}! git status alias not found${NC}"
    echo -e "${YELLOW}→ Add to .zshrc: alias gs='git status'${NC}"
  fi
  
  if echo "$ALIASES" | grep -q "alias v="; then
    echo -e "${GREEN}✓ neovim alias is available${NC}"
  else
    echo -e "${YELLOW}! neovim alias not found${NC}"
    echo -e "${YELLOW}→ Add to .zshrc: alias v='nvim'${NC}"
  fi
}

# Function to run all checks
run_all_checks() {
  print_header "Terminal Environment Troubleshooter"
  echo "Running comprehensive checks on your terminal setup..."
  
  check_zsh
  check_neovim
  check_tmux
  check_notes
  check_tools
  check_common_issues
  
  print_header "Troubleshooting Complete"
  echo "Review the results above and address any issues marked with ${YELLOW}!${NC} or ${RED}✗${NC}"
  echo "For detailed instructions, refer to the setup-guide.md in your notes repository."
}

# Function to fix common issues
fix_common_issues() {
  print_header "Attempting to Fix Common Issues"
  
  # Create missing directories
  if [ ! -d "$HOME/bin" ]; then
    echo -e "${BLUE}Creating ~/bin directory...${NC}"
    mkdir -p "$HOME/bin"
    check_result "Created ~/bin directory"
  fi
  
  # Add ~/bin to PATH if not already there
  if ! echo $PATH | grep -q "$HOME/bin"; then
    echo -e "${BLUE}Adding ~/bin to PATH in .zshrc...${NC}"
    echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.zshrc"
    check_result "Added ~/bin to PATH"
  fi
  
  # Create notes directory structure if it doesn't exist
  if [ ! -d "$NOTES_DIR" ]; then
    echo -e "${BLUE}Creating notes directory structure...${NC}"
    mkdir -p "$NOTES_DIR"/{daily,projects,learning,templates,private}
    check_result "Created notes directory structure"
  fi
  
  # Initialize git repository if it doesn't exist
  if [ ! -d "$NOTES_DIR/.git" ]; then
    echo -e "${BLUE}Initializing git repository in notes directory...${NC}"
    (cd "$NOTES_DIR" && git init)
    check_result "Initialized git repository"
  fi
  
  # Create .gitignore if it doesn't exist
  if [ ! -f "$NOTES_DIR/.gitignore" ]; then
    echo -e "${BLUE}Creating .gitignore file...${NC}"
    cat > "$NOTES_DIR/.gitignore" << 'EOL'
.DS_Store
*.swp
*.swo
node_modules/
.obsidian/
private/
EOL
    check_result "Created .gitignore file"
  fi
  
  # Create basic templates if they don't exist
  if [ ! -f "$NOTES_DIR/templates/daily.md" ]; then
    echo -e "${BLUE}Creating daily note template...${NC}"
    cat > "$NOTES_DIR/templates/daily.md" << 'EOL'
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
    check_result "Created daily note template"
  fi
  
  if [ ! -f "$NOTES_DIR/templates/project.md" ]; then
    echo -e "${BLUE}Creating project note template...${NC}"
    cat > "$NOTES_DIR/templates/project.md" << 'EOL'
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
    check_result "Created project note template"
  fi
  
  if [ ! -f "$NOTES_DIR/templates/learning.md" ]; then
    echo -e "${BLUE}Creating learning note template...${NC}"
    cat > "$NOTES_DIR/templates/learning.md" << 'EOL'
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
    check_result "Created learning note template"
  fi
  
  # Create notes-session script if it doesn't exist
  if [ ! -f "$HOME/bin/notes-session" ]; then
    echo -e "${BLUE}Creating notes-session script...${NC}"
    cat > "$HOME/bin/notes-session" << 'EOL'
#!/usr/bin/env zsh

# Create a new tmux session for notes or attach to existing one
if ! tmux has-session -t notes 2>/dev/null; then
  # Create new session with main window
  tmux new-session -d -s notes -n main -c ~/notes
  
  # Create window for daily notes
  tmux new-window -t notes:1 -n daily -c ~/notes/daily
  
  # Create window for project notes
  tmux new-window -t notes:2 -n projects -c ~/notes/projects
  
  # Create window for learning notes
  tmux new-window -t notes:3 -n learning -c ~/notes/learning
  
  # Return to main window
  tmux select-window -t notes:0
fi

# Attach to the session
tmux attach-session -t notes
EOL
    chmod +x "$HOME/bin/notes-session"
    check_result "Created notes-session script"
  fi
  
  # Make initial commit if repository is empty
  if [ -d "$NOTES_DIR/.git" ] && [ -z "$(cd "$NOTES_DIR" && git log --oneline 2>/dev/null)" ]; then
    echo -e "${BLUE}Making initial commit...${NC}"
    (cd "$NOTES_DIR" && git add . && git commit -m "Initial commit")
    check_result "Made initial commit"
  fi
  
  echo -e "\n${GREEN}Common issues fixed.${NC} Some changes may require restarting your terminal or sourcing your .zshrc file with 'source ~/.zshrc'."
}

# Parse command line options
case "$1" in
  --fix)
    run_all_checks
    fix_common_issues
    ;;
  --zsh)
    check_zsh
    ;;
  --neovim)
    check_neovim
    ;;
  --tmux)
    check_tmux
    ;;
  --notes)
    check_notes
    ;;
  --tools)
    check_tools
    ;;
  --help|-h)
    echo "Terminal Environment Troubleshooter"
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --fix      Run all checks and attempt to fix common issues"
    echo "  --zsh      Check Zsh configuration only"
    echo "  --neovim   Check Neovim configuration only"
    echo "  --tmux     Check tmux configuration only"
    echo "  --notes    Check notes system only"
    echo "  --tools    Check additional tools only"
    echo "  --help     Show this help message"
    echo ""
    echo "With no options, all checks will be run without attempting fixes."
    ;;
  *)
    run_all_checks
    ;;
esac

exit 0
