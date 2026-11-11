#!/usr/bin/env bash
# Papyrus Islands — thème Omarchy (couleurs, arrondis, fastfetch, barre en îlots)
#
# Installation :
#   curl -fsSL https://raw.githubusercontent.com/papyrus448/omarchy-papyrus-islands/main/install.sh | bash
#
# ou depuis un clone :
#   ./install.sh

set -euo pipefail

REPO_URL="https://github.com/papyrus448/omarchy-papyrus-islands.git"
REPO_SLUG="omarchy-papyrus-islands"
THEME_SLUG="papyrus-islands"
THEME_NAME="Papyrus Islands"
ISLANDS_PLUGIN_URL="https://github.com/DanielLob-o/Islands.git"
ISLANDS_PLUGIN_ID="lobo.islands"

say() { printf '\033[1;35m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

[[ -n ${HOME:-} ]] || die "HOME n'est pas défini."
command -v omarchy >/dev/null 2>&1 || die "Omarchy est requis : la commande 'omarchy' est introuvable."
command -v jq >/dev/null 2>&1 || die "jq est requis (sudo pacman -S jq)."
command -v git >/dev/null 2>&1 || die "git est requis (sudo pacman -S git)."

# ---------------------------------------------------------------- source files

SOURCE_DIR=""
CLEANUP_DIR=""

if [[ -n ${BASH_SOURCE[0]:-} && -f ${BASH_SOURCE[0]:-} ]]; then
  candidate=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  [[ -d $candidate/theme ]] && SOURCE_DIR="$candidate"
fi

if [[ -z $SOURCE_DIR ]]; then
  say "Téléchargement de $REPO_SLUG…"
  CLEANUP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/papyrus-islands.XXXXXX")
  git clone --depth=1 "$REPO_URL" "$CLEANUP_DIR/repo" >/dev/null 2>&1 ||
    die "Impossible de cloner $REPO_URL"
  SOURCE_DIR="$CLEANUP_DIR/repo"
fi

cleanup() {
  [[ -n $CLEANUP_DIR ]] && rm -rf "$CLEANUP_DIR"
  return 0
}
trap cleanup EXIT

CONFIG_DIR="$HOME/.config"
DATA_DIR="$HOME/.local/share/$REPO_SLUG"
THEMES_DIR="$CONFIG_DIR/omarchy/themes"
PLUGINS_DIR="$CONFIG_DIR/omarchy/plugins"
SHELL_JSON="$CONFIG_DIR/omarchy/shell.json"
LOOKNFEEL="$CONFIG_DIR/hypr/looknfeel.lua"
FASTFETCH_DIR="$CONFIG_DIR/fastfetch"
STAMP=$(date +%Y%m%d-%H%M%S)

backup() {
  local path="$1"
  [[ -e $path ]] || return 0
  local dest="$path.bak.$STAMP"
  cp -a "$path" "$dest"
  say "Sauvegarde : $dest"
}

# --------------------------------------------------------------------- theme

say "Installation du thème « $THEME_NAME »…"
mkdir -p "$THEMES_DIR"
if [[ -e $THEMES_DIR/$THEME_SLUG ]]; then
  theme_backup_dir="$CONFIG_DIR/omarchy/themes-backup"
  mkdir -p "$theme_backup_dir"
  cp -a "$THEMES_DIR/$THEME_SLUG" "$theme_backup_dir/$THEME_SLUG.bak.$STAMP"
  say "Sauvegarde du thème existant : $theme_backup_dir/$THEME_SLUG.bak.$STAMP"
fi
rm -rf "$THEMES_DIR/$THEME_SLUG"
mkdir -p "$THEMES_DIR/$THEME_SLUG"
cp -a "$SOURCE_DIR/theme/." "$THEMES_DIR/$THEME_SLUG/"

# ------------------------------------------------------------------ fastfetch

say "Installation de la configuration fastfetch…"
mkdir -p "$FASTFETCH_DIR"
backup "$FASTFETCH_DIR/config.jsonc"
backup "$FASTFETCH_DIR/cli.png"
cp "$SOURCE_DIR/fastfetch/config.jsonc" "$FASTFETCH_DIR/config.jsonc"
cp "$SOURCE_DIR/fastfetch/cli.png" "$FASTFETCH_DIR/cli.png"

# Conserve le désinstalleur sur la machine.
mkdir -p "$DATA_DIR"
cp "$SOURCE_DIR/uninstall.sh" "$DATA_DIR/uninstall.sh"
chmod +x "$DATA_DIR/uninstall.sh"

# --------------------------------------------------------------- barre / îlots

say "Installation du plugin de barre Islands…"
mkdir -p "$PLUGINS_DIR"
if [[ -d $PLUGINS_DIR/$ISLANDS_PLUGIN_ID ]]; then
  omarchy plugin update "$ISLANDS_PLUGIN_ID" --yes >/dev/null 2>&1 ||
    warn "Mise à jour du plugin $ISLANDS_PLUGIN_ID ignorée."
else
  omarchy plugin add "$ISLANDS_PLUGIN_URL" --yes ||
    die "Impossible d'installer le plugin $ISLANDS_PLUGIN_ID."
fi

say "Application de la disposition de la barre…"
[[ -f $SHELL_JSON ]] || printf '{}\n' >"$SHELL_JSON"
backup "$SHELL_JSON"

shell_tmp=$(mktemp)
if ! jq --slurpfile layout "$SOURCE_DIR/bar/layout.json" '
  .bar = (((.bar // {}) | del(.layout, .islands, .background)) + {
    "id": "lobo.islands",
    "position": "top",
    "transparent": true,
    "centerAnchor": "omarchy.clock",
    "islands": {
      "color": "#000000",
      "opacity": 1,
      "transparentOpacity": 0.6,
      "radius": -1,
      "borderOpacity": 0.14,
      "borderWidth": 1,
      "padding": 10
    }
  })
  | .bar.layout = $layout[0].layout
' "$SHELL_JSON" >"$shell_tmp"; then
  rm -f "$shell_tmp"
  die "Impossible de lire $SHELL_JSON (JSON invalide ?). La sauvegarde est intacte."
fi
mv "$shell_tmp" "$SHELL_JSON"

# --------------------------------------------------------- arrondis / fenêtres

say "Application des arrondis et du look des fenêtres…"
mkdir -p "$(dirname "$LOOKNFEEL")"
if [[ ! -f $LOOKNFEEL ]]; then
  cp /usr/share/omarchy/config/hypr/looknfeel.lua "$LOOKNFEEL" 2>/dev/null || : >"$LOOKNFEEL"
fi
backup "$LOOKNFEEL"
sed -i '/^-- >>> papyrus-islands/,/^-- <<< papyrus-islands/d' "$LOOKNFEEL"
if [[ -s $LOOKNFEEL ]] && [[ $(tail -c 1 "$LOOKNFEEL" | od -An -t u1 | tr -d ' ') -ne 10 ]]; then
  printf '\n' >>"$LOOKNFEEL"
fi
cat >>"$LOOKNFEEL" <<'LUA'
-- >>> papyrus-islands (géré par install.sh) >>>
hl.config({
  decoration = {
    rounding = 8,
    dim_inactive = true,
    dim_strength = 0.15,
  },
})
-- <<< papyrus-islands <<<
LUA

# --------------------------------------------------------------- application

say "Activation du thème…"
omarchy theme set "$THEME_SLUG" || warn "Le thème a été copié mais 'omarchy theme set' a échoué."

say "Redémarrage du shell…"
omarchy restart shell >/dev/null 2>&1 || warn "Redémarrage du shell ignoré."

if command -v hyprctl >/dev/null 2>&1 && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  if hyprctl reload >/dev/null 2>&1; then
    errors=$(hyprctl configerrors 2>/dev/null || true)
    if [[ -n $errors ]]; then
      warn "Hyprland signale des erreurs de configuration :"
      printf '%s\n' "$errors" >&2
    fi
  else
    warn "hyprctl reload a échoué ; les arrondis s'appliqueront à la prochaine connexion."
  fi
fi

cat <<EOF

$(printf '\033[1;32m✓\033[0m') Papyrus Islands est installé.

  Thème      : $THEME_NAME (couleurs + fond d'écran)
  Fenêtres   : arrondi 8 px, inactives atténuées
  Console    : fastfetch (config + logo)
  Barre      : îlots noirs translucides, horloge centrée

  Tester fastfetch : fastfetch
  Changer de fond  : omarchy theme bg next
  Désinstaller     : ~/.local/share/$REPO_SLUG/uninstall.sh
EOF
