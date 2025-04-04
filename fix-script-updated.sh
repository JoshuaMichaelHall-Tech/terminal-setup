#!/bin/bash
# Terminal Environment Fix Script (Updated)
# This script fixes common issues with your terminal setup

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Terminal Environment Fix Script ===${NC}"
echo "This script will fix various issues with your terminal setup."

# Fix 1: The function wrapper problem in the plugins.lua config
echo -e "\n${BLUE}Checking if we need to fix function wrapper issue in LSP configuration...${NC}"
if [ -f "$HOME/.config/nvim/lua/plugins.lua" ]; then
  # Check if there's an issue with unnecessary function wrappers
  if grep -q "function() vim.lsp.buf.definition() end" "$HOME/.config/nvim/lua/plugins.lua"; then
    # Create backup of current plugins.lua
    cp "$HOME/.config/nvim/lua/plugins.lua" "$HOME/.config/nvim/lua/plugins.lua.bak"
    echo -e "${GREEN}✓ Created backup of plugins.lua${NC}"
    
    # Fix the function wrapping
    # Simplify function wrappers if they exist (only if needed)
    sed -i '' 's/function() vim.lsp.buf.definition() end/vim.lsp.buf.definition/g' "$HOME/.config/nvim/lua/plugins.lua"
    sed -i '' 's/function() vim.lsp.buf.hover() end/vim.lsp.buf.hover/g' "$HOME/.config/nvim/lua/plugins.lua"
    sed -i '' 's/function() vim.lsp.buf.rename() end/vim.lsp.buf.rename/g' "$HOME/.config/nvim/lua/plugins.lua"
    sed -i '' 's/function() vim.lsp.buf.code_action() end/vim.lsp.buf.code_action/g' "$HOME/.config/nvim/lua/plugins.lua"
    sed -i '' 's/function() vim.lsp.buf.references() end/vim.lsp.buf.references/g' "$HOME/.config/nvim/lua/plugins.lua"
    sed -i '' 's/function() vim.diagnostic.goto_prev() end/vim.diagnostic.goto_prev/g' "$HOME/.config/nvim/lua/plugins.lua"
    sed -i '' 's/function() vim.diagnostic.goto_next() end/vim.diagnostic.goto_next/g' "$HOME/.config/nvim/lua/plugins.lua"
    
    echo -e "${GREEN}✓ Simplified function wrappers in Neovim LSP configuration${NC}"
  else
    echo -e "${GREEN}✓ LSP function wrappers already in simple form${NC}"
  fi
  
  # Also checking for condition that checks formatting function
  if grep -q "if vim.lsp.buf.format then" "$HOME/.config/nvim/lua/plugins.lua"; then
    echo -e "${GREEN}✓ Format function check already exists${NC}"
  else
    echo -e "${YELLOW}! Adding check for formatting function (vim.lsp.buf.format vs vim.lsp.buf.formatting)${NC}"
    # This is a more complex edit, might need manual fixing if this fails
    sed -i '' '/vim.keymap.set(.n., .\[d/, i\
    -- Check if formatting function exists and use the right one\
    if vim.lsp.buf.format then\
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format() end)\
    else\
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.formatting() end)\
    end\
    ' "$HOME/.config/nvim/lua/plugins.lua"
  fi
else
  echo -e "${RED}× Could not find plugins.lua${NC}"
fi

# Fix 2: Fix Script Permissions
echo -e "\n${BLUE}Fixing script permissions...${NC}"
if [ -f "$HOME/bin/cc-start-day.sh" ]; then
  chmod +x "$HOME/bin/cc-start-day.sh"
  echo -e "${GREEN}✓ Fixed permissions for cc-start-day.sh${NC}"
else
  echo -e "${YELLOW}! cc-start-day.sh not found${NC}"
fi

# Check for other scripts and fix their permissions
for script in "$HOME/bin/cc-"*.sh; do
  if [ -f "$script" ]; then
    chmod +x "$script"
    echo -e "${GREEN}✓ Fixed permissions for $(basename $script)${NC}"
  fi
done

# Fix 3: Create Missing Directories
echo -e "\n${BLUE}Creating missing directories...${NC}"
mkdir -p "$HOME/projects/6-7-coding-challenge"
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Created ~/projects/6-7-coding-challenge${NC}"
else
  echo -e "${RED}× Failed to create project directories${NC}"
fi

# Create phase directories
for phase in phase1_ruby phase2_python phase3_javascript phase4_fullstack phase5_ml_finance; do
  mkdir -p "$HOME/projects/6-7-coding-challenge/$phase"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Created ~/projects/6-7-coding-challenge/$phase${NC}"
  fi
done

# Create logs directory
mkdir -p "$HOME/projects/6-7-coding-challenge/logs/phase1"
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Created ~/projects/6-7-coding-challenge/logs/phase1${NC}"
fi

# Fix 4: Ensure ~/bin is in PATH
echo -e "\n${BLUE}Checking if ~/bin is in PATH...${NC}"
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  echo -e "${YELLOW}! ~/bin not found in PATH${NC}"
  echo -e "export PATH=\$HOME/bin:\$PATH" >> "$HOME/.zshrc"
  echo -e "${GREEN}✓ Added ~/bin to PATH in .zshrc${NC}"
else
  echo -e "${GREEN}✓ ~/bin is already in PATH${NC}"
fi

# Fix 5: Initialize challenge day counter if missing
echo -e "\n${BLUE}Checking challenge day counter...${NC}"
if [ ! -f "$HOME/.cc-current-day" ]; then
  echo "1" > "$HOME/.cc-current-day"
  echo -e "${GREEN}✓ Initialized challenge day counter${NC}"
else
  echo -e "${GREEN}✓ Challenge day counter already exists${NC}"
fi

echo -e "\n${GREEN}=== Fixes Complete ===${NC}"
echo -e "Please run 'source ~/.zshrc' to apply the changes to your current terminal session."
echo -e "Then try running your commands again."
