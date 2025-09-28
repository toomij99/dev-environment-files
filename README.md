# Dotfiles

Personal dotfiles configuration for Zsh, Tmux, Neovim, and Git.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/toomij99/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Install GNU Stow if not already installed:
   ```bash
   # macOS with Homebrew
   brew install stow
   ```

3. Stow the configurations:
   ```bash
   stow .
   ```

## Features

- **Zsh**: Oh My Zsh with Powerlevel10k theme, plugins for git, docker, python, etc.
- **Tmux**: Custom keybindings, plugins for navigation, session persistence, and Tokyo Night theme.
- **Neovim**: Lua-based configuration with various plugins.
- **Git**: Basic user configuration.

## Requirements

- Zsh
- Oh My Zsh
- Tmux
- Neovim
- GNU Stow
- Various tools like fzf, bat, zoxide, etc. (see .zshrc for details)