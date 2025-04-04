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
