#!/usr/bin/env bash
set -e

RUNNERS_DIR="$HOME/.local/share/lutris/runners/wine"
LUTRIS_GAME_CONFIG=$(find "$HOME/.config/lutris/games" -name "battlenet-standard-*.yml" 2>/dev/null | head -n 1)
BACKUP_FILE="$RUNNERS_DIR/.last_battlenet_runner"

get_wine_version() {
  python3 -c "
import yaml
try:
    with open('$1') as f:
        data = yaml.safe_load(f)
    print(data.get('wine', {}).get('version', ''))
except Exception:
    pass
"
}

set_wine_version() {
  python3 -c "
import yaml
path = '$1'
new_ver = '$2'
with open(path, 'r') as f:
    lines = f.readlines()
# Update version under wine section specifically
under_wine = False
found = False
for i, line in enumerate(lines):
    if line.strip() == 'wine:':
        under_wine = True
    elif under_wine and line.startswith('  version:'):
        lines[i] = f'  version: {new_ver}\n'
        found = True
        break
    elif under_wine and not line.startswith(' ') and not line.startswith('\t'):
        under_wine = False
if not found:
    # Append under the last wine section
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].strip() == 'wine:':
            lines.insert(i + 1, f'  version: {new_ver}\n')
            break
with open(path, 'w') as f:
    f.writelines(lines)
"
}

if [ "$1" = "--rollback" ] || [ "$1" = "-r" ]; then
  if [ -f "$BACKUP_FILE" ]; then
    PREV_RUNNER=$(cat "$BACKUP_FILE")
    if [ -n "$PREV_RUNNER" ] && [ -n "$LUTRIS_GAME_CONFIG" ]; then
      set_wine_version "$LUTRIS_GAME_CONFIG" "$PREV_RUNNER"
      echo "==> Rolled back Lutris Battle.net runner to: $PREV_RUNNER"
      exit 0
    fi
  else
    echo "Error: No backup runner found at $BACKUP_FILE." >&2
    exit 1
  fi
fi

echo "============================================================"
echo " UPDATE HIERARCHY NOTICE (Lowest to Highest Risk):"
echo " 1. In-game API (DX11 vs DX12)       [Lowest risk - fixes 80% of stutters]"
echo " 2. VKD3D / DXVK version in Lutris   [Low risk - fixes DX12 graphics bugs]"
echo " 3. System GPU driver (Mesa/RADV)    [Medium risk - RDNA3 optimizations]"
echo " 4. Wine Runner                      [Highest risk - only if launcher breaks]"
echo "============================================================"

CURRENT_RUNNER=$(get_wine_version "$LUTRIS_GAME_CONFIG")
echo "==> Currently active runner: $CURRENT_RUNNER"

echo "==> Fetching latest Wine-TkG release information..."
RELEASE_DATA=$(curl -s https://api.github.com/repos/Kron4ek/Wine-Builds/releases/latest)
DOWNLOAD_URL=$(echo "$RELEASE_DATA" | grep "browser_download_url" | grep "staging-tkg-amd64.tar.xz" | head -n 1 | cut -d '"' -f 4)
ASSET_NAME=$(basename "$DOWNLOAD_URL")
RUNNER_NAME="${ASSET_NAME%.tar.xz}"

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Could not retrieve latest download URL from GitHub." >&2
  exit 1
fi

echo "==> Latest available Wine-TkG build: $RUNNER_NAME"

if [ -d "$RUNNERS_DIR/$RUNNER_NAME" ]; then
  echo "==> Runner $RUNNER_NAME is already installed in $RUNNERS_DIR."
else
  echo "==> Downloading $ASSET_NAME..."
  TMP_ARCHIVE=$(mktemp /tmp/wine-runner.XXXXXX.tar.xz)
  curl -L --progress-bar "$DOWNLOAD_URL" -o "$TMP_ARCHIVE"
  
  echo "==> Extracting to $RUNNERS_DIR..."
  mkdir -p "$RUNNERS_DIR"
  tar -xf "$TMP_ARCHIVE" -C "$RUNNERS_DIR"
  rm -f "$TMP_ARCHIVE"
  echo "==> Installed successfully: $RUNNERS_DIR/$RUNNER_NAME"
fi

if [ "$1" = "--apply" ] || [ "$1" = "-a" ]; then
  if [ -n "$LUTRIS_GAME_CONFIG" ] && [ -f "$LUTRIS_GAME_CONFIG" ]; then
    echo "$CURRENT_RUNNER" > "$BACKUP_FILE"
    echo "==> Saved previous runner ($CURRENT_RUNNER) for rollback."
    set_wine_version "$LUTRIS_GAME_CONFIG" "$RUNNER_NAME"
    echo "==> Battle.net in Lutris is now updated to: $RUNNER_NAME"
    echo "==> To revert if issues occur: $0 --rollback"
  else
    echo "Warning: Lutris Battle.net config file not found."
  fi
else
  echo ""
  echo "To activate in Lutris:"
  echo "  1. Restart Lutris"
  echo "  2. Right click Battle.net -> Configure -> Runner options"
  echo "  3. Select '$RUNNER_NAME' as Wine version"
  echo "  Or run: $0 --apply  (use $0 --rollback to undo)"
fi
