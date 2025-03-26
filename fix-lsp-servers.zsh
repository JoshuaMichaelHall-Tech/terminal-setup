#!/bin/zsh

# Fix LSP Server Configuration Script
# This script resolves common issues with Mason and LSP configuration in Neovim

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

# Welcome message
echo "==============================================================="
echo "      Fix LSP Server Configuration Script                     "
echo "==============================================================="
echo ""
echo "This script will fix common issues with Mason LSP configuration."
echo "It will NOT delete your existing setup, but will correct errors."
echo ""
read "REPLY?Continue with fixing your configuration? (y/n) "
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Script cancelled."
    exit 1
fi

# Check if running in Zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    log_warning "You are not currently using Zsh. This environment requires Zsh shell."
    log_warning "To switch to Zsh permanently, run: chsh -s $(which zsh)"
    log_warning "To use Zsh just for this script, exit and run: zsh ./fix-lsp-servers.zsh"
    echo ""
    read "REPLY?Continue anyway? (y/n) "
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Script cancelled."
        exit 1
    fi
fi

# Check for Neovim configuration directory
if [ ! -d "$HOME/.config/nvim" ]; then
    log_error "Neovim configuration directory not found at ~/.config/nvim"
    exit 1
fi

# Create a timestamp for backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/nvim_lsp_fix_backup_$TIMESTAMP"

log_info "Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup existing configurations
log_info "Backing up existing configurations..."

if [ -d "$HOME/.config/nvim" ]; then
    log_info "Backing up Neovim configuration..."
    cp -r "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
fi

# Check for .local/share/nvim/mason directory
MASON_DIR="$HOME/.local/share/nvim/mason"
if [ ! -d "$MASON_DIR" ]; then
    log_warning "Mason directory not found at $MASON_DIR"
    log_info "This script assumes Mason is installed. If it isn't, please install it first."
else
    log_info "Backing up Mason directory structure..."
    find "$MASON_DIR" -type d -name "*" -exec mkdir -p "$BACKUP_DIR/{}" \;
fi

# Fix local Mason config if present
MASON_CONFIG_FILE=$(find "$HOME/.config/nvim" -type f -name "*.lua" -exec grep -l "mason-lspconfig.*setup" {} \; | head -n 1)

if [ -n "$MASON_CONFIG_FILE" ]; then
    log_info "Found Mason config in $MASON_CONFIG_FILE"
    
    # Backup the file before modifying
    cp "$MASON_CONFIG_FILE" "$BACKUP_DIR/$(basename "$MASON_CONFIG_FILE")"
    
    # Fix Ruby server name if needed
    if grep -q "ruby_lsp" "$MASON_CONFIG_FILE"; then
        log_info "Fixing Ruby LSP server name..."
        sed -i '' 's/ruby_lsp/rubylsp/g' "$MASON_CONFIG_FILE" 2>/dev/null || sed -i 's/ruby_lsp/rubylsp/g' "$MASON_CONFIG_FILE"
        log_success "Ruby LSP server name fixed in $MASON_CONFIG_FILE"
    fi
    
    # Fix TypeScript server name if needed
    if grep -q "typescript-language-server" "$MASON_CONFIG_FILE"; then
        log_info "Fixing TypeScript server name..."
        sed -i '' 's/typescript-language-server/tsserver/g' "$MASON_CONFIG_FILE" 2>/dev/null || sed -i 's/typescript-language-server/tsserver/g' "$MASON_CONFIG_FILE"
        log_success "TypeScript server name fixed in $MASON_CONFIG_FILE"
    fi
else
    log_warning "Could not find Mason configuration file. You might need to manually fix the server names."
fi

# Find and fix LSPConfig setup files
for file in $(find "$HOME/.config/nvim" -type f -name "*.lua" -exec grep -l "lspconfig.*setup" {} \;); do
    log_info "Checking LSP setup in $file"
    
    # Backup the file before modifying
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    
    # Make sure tsserver setup is correct
    if grep -q "lspconfig.*ruby_lsp.*setup" "$file"; then
        log_info "Fixing Ruby LSP setup in $file"
        sed -i '' 's/ruby_lsp/rubylsp/g' "$file" 2>/dev/null || sed -i 's/ruby_lsp/rubylsp/g' "$file"
        log_success "Ruby LSP setup fixed in $file"
    fi
done

# Add helpful information to Neovim config
INIT_LUA="$HOME/.config/nvim/init.lua"
if [ -f "$INIT_LUA" ]; then
    log_info "Adding LSP server naming guide to init.lua..."
    
    # Backup init.lua
    cp "$INIT_LUA" "$BACKUP_DIR/init.lua"
    
    # Add helpful comment at the end of init.lua
    cat << 'EOL' >> "$INIT_LUA"

-- LSP Server Naming Guide
-- When configuring Mason LSP, use these server names:
-- Ruby: rubylsp (not ruby_lsp)
-- TypeScript: tsserver (not typescript-language-server)
-- Check server names with :Mason and https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
EOL
    log_success "LSP server naming guide added to init.lua"
fi

# Install Nerd Fonts if needed
read "REPLY?Would you like to install Nerd Fonts for proper icon display? (y/n) "
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Installing Nerd Fonts..."
    if command -v brew &> /dev/null; then
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
        brew install --cask font-hack-nerd-font
        log_success "JetBrains Mono and Hack Nerd Fonts installed"
    else
        log_warning "Homebrew not found. Please install Nerd Fonts manually:"
        echo "1. Download from https://www.nerdfonts.com/font-downloads"
        echo "2. Install the font files on your system"
    fi
fi

# Create Neovim undodir if it doesn't exist
if [ ! -d "$HOME/.vim/undodir" ]; then
    log_info "Creating Neovim undo directory..."
    mkdir -p "$HOME/.vim/undodir"
    log_success "Neovim undo directory created"
fi

# Final summary and instructions
log_success "Configuration fixed successfully!"
echo ""
echo "==================================================================="
echo "                       NEXT STEPS                                  "
echo "==================================================================="
echo ""
echo "1. Restart Neovim completely"
echo ""
echo "2. Run the following commands in Neovim:"
echo "   :MasonUpdate"
echo "   :Mason"
echo ""
echo "3. In the Mason UI, install or reinstall these language servers:"
echo "   - lua-language-server (for lua_ls)"
echo "   - ruby-lsp (for rubylsp)"
echo "   - pyright"
echo "   - typescript-language-server (for tsserver)"
echo ""
echo "4. Configure your terminal to use JetBrainsMono Nerd Font:"
echo "   - iTerm2: Preferences → Profiles → Text → Font → Select 'JetBrainsMono Nerd Font'"
echo "   - VS Code: Settings → Terminal › Integrated: Font Family → 'JetBrainsMono Nerd Font'"
echo ""
echo "Your original configuration has been backed up to: $BACKUP_DIR"
echo ""
echo "If you encounter any issues, you can restore your backup or check:"
echo "https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md"
echo ""