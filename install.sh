#!/bin/bash

set -e

RETRY_COUNT=0

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
    echo "    -h, --help     Show this help message"
    echo ""
    echo "  Examples:"
    echo "    $(basename \"$0\")              # Install"
    echo "    $(basename \"$0\") --update      # Update"
    echo "    $(basename \"$0\") --fix       # Fix symlinks"
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

install_brew() {
    print_info "Installing Homebrew..."
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_info "Homebrew already installed"
    fi
}

install_packages_brew() {
    print_info "Installing packages via Homebrew..."

    BREW_PACKAGES=(
        "zsh"
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
    )

    sudo apt-get update
    sudo apt-get install -y "${APT_PACKAGES[@]}"

    print_success "apt packages installed"

    print_info "Installing additional tools via cargo..."
    if command -v cargo &> /dev/null; then
        cargo install thefuck yazi zoxide 2>/dev/null || true
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

do_install() {
    print_header "Installing System Packages"

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
                print_warning "Homebrew not available, using apt..."
                install_packages_apt
            fi
            ;;
        linux-dnf|linux-arch)
            if command -v brew &> /dev/null 2>&1; then
                install_packages_brew
            else
                print_warning "Using native package manager..."
            fi
            ;;
        *)
            print_warning "Unknown OS, trying to install packages anyway..."
            install_brew || true
            install_packages || true
            ;;
    esac

    print_header "Installing Oh My Zsh & Themes"

    install_oh_my_zsh
    install_powerlevel10k
    install_tpm

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
    stow .
    print_success "Dotfiles stowed"

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
}
    print_info "Setting zsh as default shell..."
    if [ "$(which zsh)" != "$SHELL" ]; then
        if command -v chsh &> /dev/null; then
            if sudo -n chsh -s "$(which zsh)" 2>/dev/null; then
                sudo chsh -s "$(which zsh)"
            elif chsh -s "$(which zsh)"; then
                :
            else
                print_warning "Could not change shell. Run: chsh -s \$(which zsh)"
            fi
        else
            print_warning "chsh not available. Run: chsh -s \$(which zsh)"
        fi
    else
        print_info "zsh already default shell"
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
    print_info "Pulling latest changes..."
    git pull
    print_info "Updating submodules..."
    git submodule update --init --recursive
    print_info "Re-stowing configurations..."
    stow .

    print_success "Dotfiles updated and stowed"
}

do_fix() {
    print_header "Fixing Dotfiles"

    if [ ! -d "$DOTFILES_DIR" ]; then
        print_warning "Dotfiles not found at $DOTFILES_DIR"
        print_info "Run with no arguments to install fresh"
        exit 1
    fi

    cd "$DOTFILES_DIR"
    print_info "Re-stowing configurations..."
    stow .

    print_success "Dotfiles re-stowed"
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
            echo "    2. Install Tmux plugins: Press \`prefix + I\` (Ctrl-a + I)"
            echo "    3. Configure git: git config --global user.name 'Your Name'"
            echo "    4. Configure git: git config --global user.email 'your@email.com'"
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
    esac
}

main "$@"