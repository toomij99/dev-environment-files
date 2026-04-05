# Dotfiles

Personal dotfiles configuration for Zsh, Tmux, Neovim, and Git.

## Required: Install Nerd Fonts

To see icons in tmux/neovim, install a Nerd Font:

**macOS:**
```bash
# Option 1: Via Homebrew
brew install font-sf-mono

# Option 2: Hack Nerd Font
brew install --cask font-hack-nerd-font
```

**Linux:**
```bash
# Option 1: Via apt
sudo apt install fonts-firacode

# Option 2: Download manually
# Go to: https://www.nerdfonts.com/font-downloads
```

**Set in iTerm2 (macOS):**
1. Open iTerm2 → `Preferences` (Cmd+,)
2. Go to `Profiles` → `Text` tab
3. Click `Change Font`
4. Select **Hack Nerd Font** or **SF Mono**

**Set in Tilix/Terminal (Linux):**
1. Open Preferences → Profile → Custom Font
2. Select **FiraCode Nerd Font** or **Hack Nerd Font**

## Quick Install

One-command install on macOS or Linux:

```bash
curl -sS https://raw.githubusercontent.com/toomij99/dev-environment-files/main/install.sh | bash
```

### Options

| Command | Description |
|---------|-------------|
| `curl ... \| bash` | Fresh install (default) |
| `curl ... \| bash -s -- --update` | Update dotfiles |
| `curl ... \| bash -s -- --fix` | Re-stow configurations |
| `curl ... \| bash -s -- --help` | Show help |

## Manual Install

1. Clone repository:
   ```bash
   git clone --recurse-submodules git@github.com:toomij99/dev-environment-files.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Stow configurations:
   ```bash
   stow .
   ```

3. Restart terminal.

4. Install Tmux plugins: `Ctrl-a I`

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