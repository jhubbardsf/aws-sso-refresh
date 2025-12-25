#!/usr/bin/env bash
#
# aws-sso-refresh installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jhubbardsf/aws-sso-refresh/main/install.sh | bash
#

set -eo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

REPO="jhubbardsf/aws-sso-refresh"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="aws-sso-refresh"

echo -e "${BOLD}aws-sso-refresh installer${NC}"
echo ""

# Check for bash 4+
check_bash() {
    local bash_path=""

    if [[ -x "/opt/homebrew/bin/bash" ]]; then
        bash_path="/opt/homebrew/bin/bash"
    elif [[ -x "/usr/local/bin/bash" ]]; then
        bash_path="/usr/local/bin/bash"
    fi

    if [[ -z "$bash_path" ]]; then
        echo -e "${RED}Error: Modern bash (4.0+) not found.${NC}"
        echo ""
        echo "This tool requires bash 4.0+ for associative arrays."
        echo "macOS ships with bash 3.2 due to licensing."
        echo ""
        echo "Install modern bash with:"
        echo -e "  ${BLUE}brew install bash${NC}"
        echo ""
        exit 1
    fi

    echo -e "  ${GREEN}✓${NC} Found bash 4+ at $bash_path"
}

# Check for required tools
check_dependencies() {
    local missing=()

    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi

    if ! command -v aws &>/dev/null; then
        missing+=("aws-cli")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing required dependencies: ${missing[*]}${NC}"
        echo ""
        echo "Install with:"
        echo -e "  ${BLUE}brew install ${missing[*]}${NC}"
        echo ""
        exit 1
    fi

    echo -e "  ${GREEN}✓${NC} Found jq and aws-cli"
}

# Download and install
install_script() {
    mkdir -p "$INSTALL_DIR"

    local url="https://raw.githubusercontent.com/${REPO}/main/bin/aws-sso-refresh"

    echo -e "  Downloading from GitHub..."

    if command -v curl &>/dev/null; then
        curl -fsSL "$url" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
    elif command -v wget &>/dev/null; then
        wget -q "$url" -O "${INSTALL_DIR}/${SCRIPT_NAME}"
    else
        echo -e "${RED}Error: Neither curl nor wget found.${NC}"
        exit 1
    fi

    chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
    echo -e "  ${GREEN}✓${NC} Installed to ${INSTALL_DIR}/${SCRIPT_NAME}"
}

# Check PATH
check_path() {
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo ""
        echo -e "${YELLOW}Note:${NC} $INSTALL_DIR is not in your PATH."
        echo ""
        echo "Add it to your shell config:"
        echo -e "  ${BLUE}echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc${NC}"
        echo ""
        echo "Then restart your terminal or run:"
        echo -e "  ${BLUE}source ~/.zshrc${NC}"
    fi
}

main() {
    echo "Checking requirements..."
    check_bash
    check_dependencies
    echo ""

    echo "Installing..."
    install_script
    echo ""

    echo -e "${GREEN}${BOLD}Installation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo -e "  1. ${BLUE}aws-sso-refresh status${NC}   - Check your SSO sessions"
    echo -e "  2. ${BLUE}aws-sso-refresh install${NC}  - Enable the background daemon"
    echo ""

    check_path
}

main "$@"
