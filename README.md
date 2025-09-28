# Dotfiles

Personal dotfiles configuration for Zsh, Tmux, Neovim, and Git.

## Prerequisites

### macOS

1. Install Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install required packages:
   ```bash
   brew install zsh git tmux neovim stow fzf bat thefuck yazi zoxide
   ```

3. Install Oh My Zsh:
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

4. Install Powerlevel10k theme:
   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
   ```

5. Install Tmux Plugin Manager (TPM):
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

### Ubuntu/Debian

1. Update package list:
   ```bash
   sudo apt update
   ```

2. Install required packages:
   ```bash
   sudo apt install zsh git tmux neovim stow fzf bat
   ```

3. Install additional tools:
   - thefuck: `pip install thefuck` (requires Python pip)
   - yazi: Download from [GitHub releases](https://github.com/sxyazi/yazi/releases) or use snap: `sudo snap install yazi`
   - zoxide: Download from [GitHub releases](https://github.com/ajeetdsouza/zoxide/releases) or build from source

4. Install Oh My Zsh:
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

5. Install Powerlevel10k theme:
   ```bash
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
   ```

6. Install Tmux Plugin Manager (TPM):
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/toomij99/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Stow the configurations:
   ```bash
   stow .
   ```

3. Restart your terminal or source the configurations.

4. For Tmux plugins, press `prefix + I` (default prefix is Ctrl-a) to install plugins.

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