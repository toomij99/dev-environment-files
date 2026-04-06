#!/bin/bash

set -e

RETRY_COUNT=0
ACTION_CHOICE=""

REPO_URL="https://github.com/toomij99/dev-environment-files.git"
DOTFILES_DIR="$HOME/.dotfiles"
ACTION="install"

usage() {
    echo ""
    echo "  📦 Dotfiles Installer"
    echo ""
    echo "  Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "    -i, --install    Install dotfiles (default)"
    echo "    -u, --update    Update dotfiles from remote"
    echo "    -f, --fix       Fix/re-stow dotfiles"
    echo "    -p, --python    Fix Python environment & thefuck"
    echo "    -h, --help     Show this help message"
    echo ""
    echo "  Examples:"
    echo "    $(basename "$0")              # Install"
    echo "    $(basename "$0") --update      # Update"
    echo "    $(basename "$0") --fix       # Fix symlinks"
    echo "    $(basename "$0") --python    # Fix Python & thefuck"
    echo ""
    echo "  Install via curl:"
    echo "    curl -sS https://raw.githubusercontent.com/toomij99/dev-environment-files/main/install.sh | bash"
    echo ""
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "linux-apt"
        elif command -v dnf &> /dev/null; then
            echo "linux-dnf"
        elif command -v pacman &> /dev/null; then
            echo "linux-arch"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_success() {
    echo "  ✅ $1"
}

print_info() {
    echo "  ℹ️  $1"
}

print_warning() {
    echo "  ⚠️  $1"
}

configure_git() {
    print_header "Configuring Git"
    
    local current_name current_email
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    echo ""
    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        print_info "Current Git configuration:"
        echo "      Name:  $current_name"
        echo "      Email: $current_email"
        echo ""
        print_info "Press Enter to keep current, or enter new values to update"
    else
        print_warning "Git not configured"
    fi
    
    if [ -t 0 ]; then
        local git_name git_email
        
        echo ""
        if [ -n "$current_name" ]; then
            printf "  Name [%s]: " "$current_name"
        else
            printf "  Name: "
        fi
        read -r git_name
        
        if [ -n "$git_name" ]; then
            git config --global user.name "$git_name"
        elif [ -n "$current_name" ]; then
            print_info "Keeping: $current_name"
        elif [ -z "$current_name" ]; then
            print_warning "Git user.name not set. Run: git config --global user.name 'Your Name'"
        fi
        
        if [ -n "$current_email" ]; then
            printf "  Email [%s]: " "$current_email"
        else
            printf "  Email: "
        fi
        read -r git_email
        
        if [ -n "$git_email" ]; then
            git config --global user.email "$git_email"
        elif [ -n "$current_email" ]; then
            print_info "Keeping: $current_email"
        elif [ -z "$current_email" ]; then
            print_warning "Git user.email not set. Run: git config --global user.email 'your@email.com'"
        fi
        
        if [ -n "$git_name" ] || [ -n "$git_email" ]; then
            print_success "Git configuration updated"
        else
            print_success "Git configuration unchanged"
        fi
    else
        print_info "Run 'git config --global user.name \"Your Name\"' to configure git"
        print_info "Run 'git config --global user.email \"your@email.com\"' to configure git"
    fi
}

install_brew() {
    print_info "Installing Homebrew..."
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_info "Homebrew already installed"
    fi
}

install_python() {
    print_header "Setting Up Python"

    if [[ "$OS" == "macos" ]]; then
        if command -v pyenv &> /dev/null; then
            print_info "pyenv detected"
        else
            print_info "Installing pyenv via brew..."
            brew install pyenv
            brew install pyenv-virtualenv
        fi

        local current_python
        current_python=$(pyenv version 2>/dev/null | head -1)
        print_info "Current Python: $current_python"

        print_info "Checking Python versions available..."
        pyenv install --list 2>/dev/null | grep -E "^\s+3\.(10|11|12)" | tail -5

        print_info "Enter Python version to install [3.12.0]: "
        read -r PYTHON_VERSION || PYTHON_VERSION="3.12.0"

        if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
            print_info "Installing Python $PYTHON_VERSION..."
            pyenv install "$PYTHON_VERSION"
        fi

        print_info "Setting global Python to $PYTHON_VERSION..."
        pyenv global "$PYTHON_VERSION"

        print_info "Rehash to update shims..."
        pyenv rehash

    elif [[ "$OS" == "linux-apt" ]] || [[ "$OS" == "linux-dnf" ]]; then
        if command -v pyenv &> /dev/null; then
            print_info "pyenv detected"
        else
            print_info "Installing pyenv..."
            curl https://pyenv.run | bash
        fi

        export PATH="$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH"
        local current_python
        current_python=$(pyenv version 2>/dev/null | head -1 || echo "system")
        print_info "Current Python: $current_python"

        print_info "Enter Python version to install [3.12.0]: "
        read -r PYTHON_VERSION || PYTHON_VERSION="3.12.0"

        if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
            print_info "Installing Python $PYTHON_VERSION (this may take a while)..."
            pyenv install "$PYTHON_VERSION"
        fi

        print_info "Setting global Python to $PYTHON_VERSION..."
        pyenv global "$PYTHON_VERSION"
        pyenv rehash
    fi

    print_success "Python setup complete"
    print_info "Python version: $(python --version)"
}

fix_thefuck() {
    print_header "Fixing thefuck"

    if command -v thefuck &> /dev/null; then
        print_info "thefuck already installed"

        local tf_version
        tf_version=$(thefuck --version 2>/dev/null | head -1 || echo "unknown")
        print_info "Version: $tf_version"

        print_info "Testing thefuck..."
        if eval "$(thefuck --alias)" 2>/dev/null; then
            print_success "thefuck works correctly"
        else
            print_warning "thefuck has issues, attempting to fix..."

            if [[ "$OS" == "macos" ]]; then
                brew reinstall thefuck
            else
                pip install thefuck --upgrade
            fi

            print_info "Re-enabling thefuck in zshrc..."
            if grep -q "# thefuck alias" ~/.zshrc; then
                sed -i.bak 's/# thefuck alias/thefuck alias/' ~/.zshrc
                sed -i 's/# eval \$(thefuck/eval $(thefuck/' ~/.zshrc
                sed -i "s/# eval \$(thefuck/eval \$(thefuck/" ~/.zshrc
                print_success "Updated zshrc"
            fi
        fi
    else
        print_warning "thefuck not found, installing..."

        if [[ "$OS" == "macos" ]]; then
            brew install thefuck
        elif command -v pip &> /dev/null; then
            pip install thefuck
        elif command -v cargo &> /dev/null; then
            cargo install thefuck
        fi
    fi
}

cleanup_temp_files() {
    print_header "Cleaning Up Temp Files"

    local cleaned=0

    if [ -f "$HOME/nvim-linux64.tar.gz" ]; then
        rm -f "$HOME/nvim-linux64.tar.gz"
        print_info "Removed nvim-linux64.tar.gz"
        cleaned=1
    fi

    if [ -d "$HOME/.config/nvim/nvim" ]; then
        rm -rf "$HOME/.config/nvim/nvim"
        print_info "Removed .config/nvim/nvim"
        cleaned=1
    fi

    if [ -d "$HOME/.config/nvim/nvim-linux64" ]; then
        rm -rf "$HOME/.config/nvim/nvim-linux64"
        print_info "Removed .config/nvim/nvim-linux64"
        cleaned=1
    fi

    if [ -d "$HOME/.config/nvim/data" ]; then
        rm -rf "$HOME/.config/nvim/data"
        print_info "Removed .config/nvim/data"
        cleaned=1
    fi

    if [ -f "$HOME/.config/nvim/lazy-lock.json" ]; then
        rm -f "$HOME/.config/nvim/lazy-lock.json"
        print_info "Removed lazy-lock.json"
        cleaned=1
    fi

    cd "$DOTFILES_DIR"
    git checkout -- .config/nvim/lazy-lock.json 2>/dev/null || true
    git checkout -- zshrc 2>/dev/null || true

    if [ "$cleaned" -eq 0 ]; then
        print_info "No temp files to clean"
    else
        print_success "Cleanup complete"
    fi
}

install_packages_brew() {
    print_info "Installing packages via Homebrew..."

    BREW_PACKAGES=(
        "zsh"
        "bash"
        "git"
        "tmux"
        "neovim"
        "stow"
        "fzf"
        "bat"
        "thefuck"
        "yazi"
        "zoxide"
        "fd"
        "coreutils"
    )

    brew install "${BREW_PACKAGES[@]}"
    print_success "Packages installed"
}

install_packages_apt() {
    print_info "Installing packages via apt..."

    APT_PACKAGES=(
        "zsh"
        "git"
        "tmux"
        "neovim"
        "stow"
        "fzf"
        "bat"
        "fd-find"
        "coreutils"
        "jq"
        "zoxide"
        "zsh-autosuggestions"
    )

    sudo apt-get update
    sudo apt-get install -y "${APT_PACKAGES[@]}"

    print_success "apt packages installed"

    print_info "Installing additional tools via cargo..."
    if command -v cargo &> /dev/null; then
        cargo install thefuck yazi zoxide 2>/dev/null || true
    fi

    if ! command -v yazi &> /dev/null; then
        print_info "Installing yazi via binary..."
        local arch
        arch=$(uname -m)
        local arch_pkg="x86_64"
        if [[ "$arch" == "aarch64" ]]; then
            arch_pkg="aarch64"
        fi

        curl -Ls "https://github.com/sxyazi/yazi/releases/latest/download/yazi-linux-${arch_pkg}.tar.gz" | tar xz -C /tmp 2>/dev/null || true
        if [ -f "/tmp/yazi" ]; then
            chmod +x /tmp/yazi && sudo mv /tmp/yazi /usr/local/bin/
            print_success "yazi installed"
        fi
    fi

    print_info "Installing fd (alternative)..."
    if ! command -v fd &> /dev/null; then
        curl -Ls https://github.com/sharkdp/fd/releases/download/v8.7.0/fd-v8.7.0-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
        sudo mv /tmp/fd-v8.7.0-x86_64-unknown-linux-gnu/fd /usr/local/bin/
    fi
}

install_oh_my_zsh() {
    print_info "Installing Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_info "Oh My Zsh already installed"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

install_powerlevel10k() {
    print_info "Installing Powerlevel10k theme..."
    if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        print_info "Powerlevel10k already installed"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    fi
}

install_tpm() {
    print_info "Installing Tmux Plugin Manager (TPM)..."
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        print_info "TPM already installed"
    else
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
}

check_existing_install() {
    if [ -L "$HOME/.zshrc" ] || [ -L "$HOME/.tmux.conf" ]; then
        print_warning "Dotfiles already stowed!"
        print_info "[1] Update dotfiles (pull & re-stow)"
        print_info "[2] Re-stow only (fix symlinks)"
        print_info "[3] Fresh install"
        print_info "Choose [1-3]: "
        read -r ACTION_CHOICE || ACTION_CHOICE="1"
        
        case "$ACTION_CHOICE" in
            1)
                do_update
                exit 0
                ;;
            2)
                do_fix
                exit 0
                ;;
            3)
                print_info "Running fresh install..."
                ;;
            *)
                print_info "Skipping..."
                ;;
        esac
    fi
}

do_install() {
    print_header "Installing System Packages"

    check_existing_install

    OS=$(detect_os)
    print_info "Detected OS: $OS"

    case "$OS" in
        macos)
            install_brew
            install_packages_brew
            ;;
        linux-apt)
            if command -v brew &> /dev/null 2>&1; then
                print_info "Homebrew detected"
                install_packages_brew
            else
                print_warning "Homebrew not available, installing..."
                install_brew
                install_packages_brew
            fi
            ;;
        linux-dnf|linux-arch)
            if command -v brew &> /dev/null 2>&1; then
                install_packages_brew
            else
                print_warning "Homebrew not available, installing..."
                install_brew
                install_packages_brew
            fi
            ;;
        *)
            print_warning "Unknown OS, trying to install packages anyway..."
            install_brew || true
            install_packages || true
            ;;
    esac

    cleanup_temp_files

    print_header "Setting Up Python Environment"
    install_python
    cleanup_temp_files
    fix_thefuck

    print_header "Installing Oh My Zsh & Themes"

    install_oh_my_zsh
    install_powerlevel10k
    install_tpm
    
    print_info "Installing zsh plugins..."
    ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
    if [ ! -d "$ZSH_CUSTOM/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/zsh-autosuggestions"
    fi
    if [ ! -d "$ZSH_CUSTOM/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/zsh-syntax-highlighting"
    fi

    print_header "Setting Up Dotfiles"

    if [ -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles directory already exists, pulling latest..."
        cd "$DOTFILES_DIR" && git pull && git submodule update --init --recursive
    else
        print_info "Cloning dotfiles..."
        git clone --recurse-submodules "$REPO_URL" "$DOTFILES_DIR"
    fi

    if ! command -v stow &> /dev/null; then
        print_info "Installing stow..."
        sudo apt-get install -y stow
    fi

    cd "$DOTFILES_DIR"
    
    print_info "Backing up existing dotfiles..."
    for f in zshrc tmux.conf gitconfig; do
        if [ -f "$HOME/.$f" ] && [ ! -L "$HOME/.$f" ]; then
            mv "$HOME/.$f" "$HOME/.$f.bak.$(date +%s)"
            print_info "Backed up .$f"
        fi
    done
    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
        print_info "Backed up .config/nvim"
    fi
    
rm -f ~/.tmux.conf ~/.zshrc ~/.gitconfig
    rm -rf ~/.config/nvim ~/.fzf-git.sh ~/.tmux 2>/dev/null
    
    cd "$DOTFILES_DIR"
    
    for f in zshrc tmux.conf gitconfig; do
        ln -sf "$DOTFILES_DIR/$f" "$HOME/.$f"
    done
    ln -sf "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
    print_success "Dotfiles stowed"
    
    print_header "Installing Tmux Plugins"
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        print_info "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    
    # Create simple status bar if theme fails
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        print_info "Running TPM install in tmux..."
        # Just load the config, let user press prefix+I manually
    fi
    
    print_info "For tmux plugins, press: Ctrl-a + I"

    print_header "Configuring Powerlevel10k"
    print_info "Run 'p10k configure' to customize your prompt"
    print_info "Or press any key to skip..."

    if [ -t 0 ]; then
        read -t 10 -r "p10k_configure" || true
        if [ -n "$p10k_configure" ]; then
            p10k configure
        fi
    fi

    configure_git

    print_info "Setting zsh as default shell..."
    ZSH_PATH="$(command -v zsh 2>/dev/null || echo "/usr/bin/zsh")"
    if [ -x "$ZSH_PATH" ]; then
        if command -v chsh &> /dev/null; then
            if sudo -n chsh -s "$ZSH_PATH" 2>/dev/null; then
                sudo chsh -s "$ZSH_PATH"
                print_success "Shell changed to zsh"
            elif chsh -s "$ZSH_PATH" 2>/dev/null; then
                print_success "Shell changed to zsh"
            else
                print_warning "Could not change shell. Run: chsh -s $ZSH_PATH"
            fi
        else
            print_warning "chsh not available. Run: chsh -s $ZSH_PATH"
        fi
    else
        print_warning "zsh not found"
    fi
    
    # Fallback: add exec zsh to bashrc/profile
    if [ -f "$HOME/.bashrc" ] && ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
        echo "exec zsh -l" >> "$HOME/.bashrc"
        print_info "Added 'exec zsh' to .bashrc"
    fi
    if [ -f "$HOME/.profile" ] && ! grep -q "exec zsh" "$HOME/.profile" 2>/dev/null; then
        echo "exec zsh -l" >> "$HOME/.profile"
        print_info "Added 'exec zsh' to .profile"
    fi
}

do_update() {
    print_header "Updating Dotfiles"

    if [ ! -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles not found at $DOTFILES_DIR"
        print_info "Run with no arguments to install fresh"
        exit 1
    fi

    cd "$DOTFILES_DIR"

    local has_changes=$(git status --porcelain | grep -v "^??" | wc -l)
    if [ "$has_changes" -gt 0 ]; then
        print_info "Discarding local changes..."
        git checkout -- . 2>/dev/null || true
    fi

    print_info "Pulling latest changes..."
    git pull --rebase

    print_info "Updating submodules..."
    git submodule update --init --recursive
    
    print_info "Re-linking configurations..."
    for f in zshrc tmux.conf gitconfig; do
        ln -sf "$DOTFILES_DIR/$f" "$HOME/.$f"
    done
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

    print_success "Dotfiles updated"

    cleanup_temp_files

    print_header "Fixing Python & thefuck"
    install_python
    fix_thefuck
}

do_fix() {
    print_header "Fixing Dotfiles"

    if [ ! -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles not found at $DOTFILES_DIR"
        print_info "Run with no arguments to install fresh"
        exit 1
    fi

    cd "$DOTFILES_DIR"
    print_info "Re-linking configurations..."
    for f in zshrc tmux.conf gitconfig; do
        ln -sf "$DOTFILES_DIR/$f" "$HOME/.$f"
    done
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

    print_success "Dotfiles re-linked"

    cleanup_temp_files

    print_header "Fixing Python & thefuck"
    install_python
    fix_thefuck
}

show_banner() {
    echo ""
    echo "  ████████╗ █████╗  ██████╗ ████████╗"
    echo "  ╚══██╔══╝██╔══██╗██╔═══██╗╚══██╔══╝"
    echo "     ██║   ██████╔╝██║   ██║   ██║   "
    echo "     ██║   ██╔══██╗██║   ██║   ██║   "
    echo "     ██║   ██║  ██║╚██████╔╝   ██║   "
    echo "     ╚═╝   ╚═╝  ╚═╝ ╚═════╝    ╚═╝   "
    echo ""
    echo "              📦 Dotfiles Installer"
    echo ""
}

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--install)
                ACTION="install"
                shift
                ;;
            -u|--update)
                ACTION="update"
                shift
                ;;
            -f|--fix)
                ACTION="fix"
                shift
                ;;
            -p|--python)
                ACTION="fix-python"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    show_banner

    case "$ACTION" in
        install)
            do_install
            print_header "Installation Complete"
            echo ""
            echo "  📝 Next steps:"
            echo ""
            echo "    1. Restart your terminal or run: exec zsh"
            echo "    2. Install Tmux plugins: Press Ctrl-a + I"
            echo ""
            echo "  ⌨️  Popular Commands:"
            echo ""
            echo "    y          Open yazi file manager"
            echo "    vim        Open neovim"
            echo "    fk         Fix last command"
            echo "    z <dir>    Jump to directory (zoxide)"
            echo ""
            echo "    Tmux:"
            echo "    Ctrl-a |   Split horizontal"
            echo "    Ctrl-a -   Split vertical"
            echo "    Ctrl-a h/j/k/l  Navigate panes"
            echo ""
            echo "    Neovim:"
            echo "    <leader>ff Find files"
            echo "    <leader>fs Find string"
            echo "    gd         Go to definition"
            echo "    K          Show documentation"
            echo ""
            echo "  🎉 Enjoy your new environment!"
            echo ""
            ;;
        update)
            do_update
            print_header "Update Complete"
            echo ""
            echo "  ℹ️  Restart your terminal to apply changes"
            echo ""
            ;;
        fix)
            do_fix
            print_header "Fix Complete"
            echo ""
            echo "  ℹ️  Restart your terminal to apply changes"
            echo ""
            ;;
        fix-python)
            OS=$(detect_os)
            install_python
            cleanup_temp_files
            fix_thefuck
            print_header "Python Fix Complete"
            echo ""
            echo "  ℹ️  Restart your terminal to apply changes"
            echo ""
            ;;
    esac
}

main "$@"