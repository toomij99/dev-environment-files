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

### Ubuntu/Debian (Alternative with apt)

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

## Directory Structure

```
~/.dotfiles/
├── .config/
│   └── nvim/       # Neovim configuration (symlinks to ~/.config/nvim)
├── tmux.conf       # Tmux configuration (symlinks to ~/.tmux.conf)  
├── zshrc           # Zsh configuration (symlinks to ~/.zshrc)
├── gitconfig       # Git configuration (symlinks to ~/.gitconfig)
├── README.md       # This file
└── .stow-local-ignore
```

## Installation

1. Clone this repository:
   ```bash
   git clone git@github.com:toomij99/dev-environment-files.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Stow the configurations:
   ```bash
   # Stow all configurations
   stow .
   
   # Or stow individual configurations selectively
   stow .config      # nvim only (creates ~/.config/nvim)
   stow tmux.conf    # tmux only (creates ~/.tmux.conf)
   stow zshrc        # zsh only (creates ~/.zshrc)
   stow gitconfig    # git config only (creates ~/.gitconfig)
   ```

3. Restart your terminal or source the configurations.

4. For Tmux plugins, press `prefix + I` (default prefix is Ctrl-a) to install plugins.

## Features

- **Zsh**: Oh My Zsh with Powerlevel10k theme, plugins for git, docker, python, etc.
- **Tmux**: Custom keybindings, plugins for navigation, session persistence, and Tokyo Night theme.
- **Neovim**: Lua-based configuration with various plugins.
- **Git**: Basic user configuration.

## Quick Commands

### General
| Command | Description |
|---------|-------------|
| `y` | Open yazi file manager |
| `vim` | Open neovim |
| `fk` | Fix last command (thefuck) |

### Neovim - File Explorer
| Command | Description |
|---------|-------------|
| `<leader>ee` | Toggle file explorer |
| `<leader>ef` | Toggle explorer on current file |
| `<leader>ec` | Collapse explorer |
| `<leader>er` | Refresh explorer |

### Neovim - Telescope
| Command | Description |
|---------|-------------|
| `<leader>ff` | Find files |
| `<leader>fr` | Find recent files |
| `<leader>fs` | Find string in cwd |
| `<leader>fc` | Find string under cursor |
| `<leader>ft` | Find todos |
| `<leader>fk` | Find keymaps |

### Neovim - LSP
| Command | Description |
|---------|-------------|
| `gd` | Go to definition |
| `gR` | Show references |
| `gD` | Go to declaration |
| `gi` | Show implementations |
| `gt` | Show type definitions |
| `K` | Show documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Smart rename |
| `<leader>rs` | Restart LSP |

### Neovim - Git
| Command | Description |
|---------|-------------|
| `]h` / `[h` | Next/Prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hd` | Diff this |

### Neovim - Misc
| Command | Description |
|---------|-------------|
| `<leader>r` | Substitute motion |
| `<leader>rr` | Substitute line |
| `<leader>wr` | Restore session |
| `<leader>ws` | Save session |
| `<leader>l` | Show linting |

### Tmux
| Command | Description |
|---------|-------------|
| `Ctrl-a I` | Install plugins |
| `Ctrl-a |` | Split horizontal |
| `Ctrl-a -` | Split vertical |
| `Ctrl-a h/j/k/l` | Navigate panes |
| `Ctrl-a r` | Reload config |

### Navigation
| Command | Description |
|---------|-------------|
| `z` + directory | zoxide (cd alternative) |
| `cdf` | cd to git repo root |

### Update & Fix
```bash
# Pull latest dotfiles
cd ~/.dotfiles && git pull && git submodule update --init --recursive

# Re-stow configurations
cd ~/.dotfiles && stow .
```

## Requirements

- Zsh
- Oh My Zsh
- Tmux
- Neovim
- GNU Stow
- Various tools like fzf, bat, zoxide, etc. (see .zshrc for details)