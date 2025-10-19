echo "Checking for existing Trezor Suite…"
APP_DIR="$HOME/.local/bin"
APP_PATH="$APP_DIR/Trez.AppImage"
APP_URL="https://data.trezor.io/suite/releases/desktop/latest/Trezor-Suite-25.7.4-linux-x86_64.AppImage"

mkdir -p "$APP_DIR"

if [ -f "$APP_PATH" ]; then
  echo "✓ $APP_PATH already exists – nothing to do."
else
  echo "Downloading Trezor Suite to $APP_PATH…"
  curl -L "$APP_URL" -o "$APP_PATH"
  chmod +x "$APP_PATH"
  echo "✓ Download complete and made executable."
fi
