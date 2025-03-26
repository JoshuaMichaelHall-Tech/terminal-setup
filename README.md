# Terminal Development Environment

> **⚠️ DISCLAIMER: This is a work in progress. I am still working out bugs and refining the configuration. Use at your own risk and please report any issues you encounter.**

A highly customized terminal-based development environment using Neovim, tmux, and command-line tools optimized for software engineering workflows.

![Version](https://img.shields.io/badge/version-0.1.0--alpha-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

This repository contains my terminal-based development environment configuration, designed to maximize productivity through a keyboard-driven workflow. By leveraging terminal-based tools, this setup minimizes distractions and resource usage while providing a consistent environment across all my machines.

## Key Features

- **Mouse-Free Workflow**: Complete development environment navigable entirely from the keyboard
- **Modular Configuration**: Easily adaptable to different projects and languages
- **Resource Efficiency**: Minimal CPU and memory usage compared to GUI editors
- **Consistent Experience**: Same environment locally and on remote servers
- **Version-Controlled**: Track all configuration changes with Git

## Components

### Core Tools
- **Neovim**: Text editor with full LSP support and custom keybindings
- **tmux**: Terminal multiplexer for session management
- **Zsh**: Shell with custom configuration and aliases

### Plugins & Extensions
- **Lua-based Neovim config**: Modern plugin system with Lazy.nvim
- **LSP Integration**: Code intelligence for multiple languages
- **Telescope**: Fuzzy finder for files and text
- **Treesitter**: Advanced syntax highlighting
- **Git Integration**: Fugitive and other Git tools

## Getting Started

Please see the [Setup Guide](./SETUP.md) for detailed installation instructions and the [Tutorial](./TUTORIAL.md) for workflow examples.

### Quick Start

```bash
# Clone the repository
git clone https://github.com/JoshuaMichaelHall-Tech/terminal-setup.git
cd terminal-setup

# Run the installation script (coming soon)
./install.sh
```

## Current Status

This project is actively being developed and refined. Current focus areas:

- [ ] Streamlining Neovim LSP configuration
- [ ] Improving tmux session management
- [ ] Optimizing keybindings across tools
- [ ] Creating language-specific configurations
- [ ] Documenting common workflows

## Screenshots

[Coming soon]

## Inspiration

This configuration draws inspiration from:
- ThePrimeagen's development environment
- Vim and Neovim communities
- Ruby/Rails developers using terminal-based workflows

## Contributing

While this is primarily my personal configuration, suggestions and improvements are welcome! Feel free to open an issue or pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.