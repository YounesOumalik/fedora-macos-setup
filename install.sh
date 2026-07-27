#!/usr/bin/env bash

set -Eeuo pipefail

readonly PREVIEW_UUID='dock-window-preview@quivio'
readonly PREVIEW_SCHEMA='org.gnome.shell.extensions.dock-window-preview'
readonly WALLPAPER_DIR="${HOME}/.local/share/backgrounds/WhiteSur"
readonly WALLPAPER_PATH="${WALLPAPER_DIR}/background.png"

if [[ ! -r /etc/os-release ]]; then
  echo "Impossible d'identifier la distribution."
  exit 1
fi

source /etc/os-release
if [[ "${ID:-}" != "fedora" ]]; then
  echo "Ce script est prévu pour Fedora Workstation."
  exit 1
fi

for command in sudo dnf git curl gsettings python3; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Commande requise absente : ${command}"
    exit 1
  fi
done

echo "Installation des paquets Fedora…"
sudo dnf install -y \
  git curl sassc glib2-devel libxml2 gtk-murrine-engine lm_sensors \
  rsms-inter-fonts gnome-tweaks gnome-extensions-app \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-user-theme \
  gnome-shell-extension-blur-my-shell \
  gnome-shell-extension-system-monitor-applet

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/fedora-macos-setup.XXXXXXXX")"
trap 'rm -rf "${work_dir}"' EXIT

echo "Installation du thème WhiteSur…"
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "${work_dir}/gtk"
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git "${work_dir}/icons"
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-cursors.git "${work_dir}/cursors"

TERM=linux "${work_dir}/gtk/install.sh" \
  -c dark -o normal -l --shell \
  -i apple -b default -p 30 -h default --round
TERM=linux "${work_dir}/gtk/install.sh" \
  -c dark -o normal --shell \
  -i apple -b default -p 30 -h default --round
"${work_dir}/icons/install.sh" -t default -a
"${work_dir}/cursors/install.sh"

install -Dm644 "${work_dir}/gtk/other/gdm/theme/background.png" "${WALLPAPER_PATH}"

echo "Installation des aperçus de fenêtres au survol…"
preview_info="$(
  curl -fsSL 'https://extensions.gnome.org/extension-info/?pk=9492&shell_version=50'
)"
preview_url="$(
  python3 -c 'import json, sys; print(json.load(sys.stdin)["download_url"])' <<<"${preview_info}"
)"
preview_zip="${work_dir}/dock-window-preview.shell-extension.zip"
curl -fL "https://extensions.gnome.org${preview_url}" -o "${preview_zip}"
gnome-extensions install --force "${preview_zip}"

preview_dir="${HOME}/.local/share/gnome-shell/extensions/${PREVIEW_UUID}"
preview_schemas="${preview_dir}/schemas"

echo "Application de l'apparence macOS…"
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.interface enable-animations true
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Semi-Bold 11'
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
gsettings set org.gnome.mutter dynamic-workspaces true

wallpaper_uri="file://${WALLPAPER_PATH}"
gsettings set org.gnome.desktop.background picture-uri "${wallpaper_uri}"
gsettings set org.gnome.desktop.background picture-uri-dark "${wallpaper_uri}"
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver picture-uri "${wallpaper_uri}"

echo "Configuration du dock…"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.08
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0.18
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.28
gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 25.0
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock always-center-icons true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#202124'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.35
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
gsettings set org.gnome.shell.extensions.dash-to-dock show-windows-preview true
gsettings set org.gnome.shell.extensions.dash-to-dock preview-size-scale 0.25

echo "Configuration du flou et des aperçus…"
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel brightness 0.75
gsettings set org.gnome.shell.extensions.blur-my-shell.panel sigma 30
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.72
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 30
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'

GSETTINGS_SCHEMA_DIR="${preview_schemas}" \
  gsettings set "${PREVIEW_SCHEMA}" hover-delay-ms 120
GSETTINGS_SCHEMA_DIR="${preview_schemas}" \
  gsettings set "${PREVIEW_SCHEMA}" preview-width 320
GSETTINGS_SCHEMA_DIR="${preview_schemas}" \
  gsettings set "${PREVIEW_SCHEMA}" preview-height 190
GSETTINGS_SCHEMA_DIR="${preview_schemas}" \
  gsettings set "${PREVIEW_SCHEMA}" preview-layout 'horizontal'
GSETTINGS_SCHEMA_DIR="${preview_schemas}" \
  gsettings set "${PREVIEW_SCHEMA}" show-close-button true
GSETTINGS_SCHEMA_DIR="${preview_schemas}" \
  gsettings set "${PREVIEW_SCHEMA}" close-button-position 'left'

gsettings set org.gnome.shell enabled-extensions "[
  'system-monitor-next@paradoxxx.zero.gmail.com',
  'dash-to-dock@micxgx.gmail.com',
  'user-theme@gnome-shell-extensions.gcampax.github.com',
  'blur-my-shell@aunetx',
  '${PREVIEW_UUID}'
]"

echo
echo "Installation terminée."
echo "Déconnectez-vous puis reconnectez-vous pour charger toutes les extensions."
