#!/usr/bin/env bash
# Installer for evren: creates a venv, installs httpx, copies the script to ~/bin.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$HOME/.venvs/evren"
BIN_DIR="$HOME/bin"
PATH_LINE='export PATH="$HOME/bin:$PATH"'
ZSHRC="$HOME/.zshrc"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 not found. Install Python 3.9+ first." >&2
  exit 1
fi
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)' || {
  echo "Error: Python 3.9 or newer is required." >&2
  exit 1
}

echo "-> Creating virtualenv at $VENV_DIR"
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install -q --disable-pip-version-check --upgrade httpx

echo "-> Installing script to $BIN_DIR/evren"
mkdir -p "$BIN_DIR"
cp "$SRC_DIR/evren" "$BIN_DIR/evren"
chmod +x "$BIN_DIR/evren"

if ! grep -qF "$PATH_LINE" "$ZSHRC" 2>/dev/null; then
  echo "-> Adding ~/bin to PATH in $ZSHRC"
  printf '\n%s\n' "$PATH_LINE" >> "$ZSHRC"
fi

echo
echo "Done. Open a new terminal (or run: source ~/.zshrc), then:"
echo "  evren doctor"
echo
echo "Set your API key first if you have not:"
echo '  export EVRENAPI="evren_llm_..."          # in ~/.zshrc'
echo '  security add-generic-password -a "$USER" -s evren -w   # or use the Keychain'
