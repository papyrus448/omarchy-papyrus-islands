#!/usr/bin/env bash
# Papyrus Islands — désinstallation
#
#   curl -fsSL https://raw.githubusercontent.com/papyrus448/omarchy-papyrus-islands/main/uninstall.sh | bash

set -euo pipefail

REPO_SLUG="omarchy-papyrus-islands"
THEME_SLUG="papyrus-islands"
ISLANDS_PLUGIN_ID="lobo.islands"

say() { printf '\033[1;35m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

[[ -n ${HOME:-} ]] || { echo "HOME n'est pas défini." >&2; exit 1; }

CONFIG_DIR="$HOME/.config"
THEMES_DIR="$CONFIG_DIR/omarchy/themes"
SHELL_JSON="$CONFIG_DIR/omarchy/shell.json"
LOOKNFEEL="$CONFIG_DIR/hypr/looknfeel.lua"
FASTFETCH_DIR="$CONFIG_DIR/fastfetch"
DATA_DIR="$HOME/.local/share/$REPO_SLUG"

restore_latest() {
  local path="$1" latest
  latest=$(ls -1dt "$path".bak.* 2>/dev/null | head -n1 || true)
  [[ -n $latest ]] || return 1
  cp -a "$latest" "$path"
  say "Restauré : $path"
}

# --------------------------------------------------------------- barre / shell

say "Restauration de la barre…"
if ! restore_latest "$SHELL_JSON"; then
  if [[ -f $SHELL_JSON ]] && command -v jq >/dev/null 2>&1; then
    tmp=$(mktemp)
    jq 'del(.bar.islands) | if .bar.id == "lobo.islands" then del(.bar.id) else . end' \
      "$SHELL_JSON" >"$tmp" && mv "$tmp" "$SHELL_JSON"
    say "Configuration des îlots retirée de shell.json."
  fi
fi

# ------------------------------------------------------------------ fastfetch

say "Restauration de fastfetch…"
if restore_latest "$FASTFETCH_DIR/config.jsonc"; then
  restore_latest "$FASTFETCH_DIR/cli.png" >/dev/null 2>&1 || true
else
  rm -f "$FASTFETCH_DIR/config.jsonc" "$FASTFETCH_DIR/cli.png"
fi

# --------------------------------------------------------------------- thème

say "Suppression du thème…"
rm -rf "$THEMES_DIR/$THEME_SLUG"

# ------------------------------------------------------------------- arrondis

if [[ -f $LOOKNFEEL ]]; then
  say "Retrait du bloc d'arrondis…"
  sed -i '/^-- >>> papyrus-islands/,/^-- <<< papyrus-islands/d' "$LOOKNFEEL"
fi

# ------------------------------------------------------------------ application

if command -v omarchy >/dev/null 2>&1; then
  omarchy restart shell >/dev/null 2>&1 || warn "Redémarrage du shell ignoré."
  if command -v hyprctl >/dev/null 2>&1 && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
fi

rm -rf "$DATA_DIR"

cat <<EOF

$(printf '\033[1;32m✓\033[0m') Papyrus Islands a été retiré.

  Le plugin de barre « $ISLANDS_PLUGIN_ID » reste installé mais n'est plus utilisé.
  Pour le supprimer : omarchy plugin remove $ISLANDS_PLUGIN_ID --yes
  Pour choisir un autre thème : omarchy theme list && omarchy theme set <nom>
EOF
