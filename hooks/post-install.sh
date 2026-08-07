#!/bin/sh
# post-install hook — cosmic
# Uruchamiane sandboxed przez hpm zaraz po skopiowaniu contents/ do store.
# Dostępne zmienne: HPM_PKG_NAME, HPM_PKG_VERSION, HPM_STORE_PATH,
# HPM_HOOK_TYPE, HPM_HOOK_LANG, (HPM_OLD_VERSION przy aktualizacji).
set -e

STORE="$HPM_STORE_PATH"
SESSION_DIR="$HOME/.local/share/wayland-sessions"
mkdir -p "$SESSION_DIR"

cat > "$SESSION_DIR/cosmic.desktop" <<EOF
[Desktop Entry]
Name=COSMIC
Comment=COSMIC Desktop Environment (Epoch $HPM_PKG_VERSION) — installed via hpm
Exec=$STORE/bin/cosmic-session
Type=Application
DesktopNames=COSMIC
EOF

echo ""
echo "=================================================================="
echo " COSMIC $HPM_PKG_VERSION zainstalowany w: $STORE"
echo "=================================================================="
echo ""
echo " Plik sesji zapisany lokalnie (bez roota, zgodnie z filozofia hpm 0.9):"
echo "   $SESSION_DIR/cosmic.desktop"
echo ""
echo " Menedzery logowania (GDM/SDDM/LightDM) standardowo szukaja sesji"
echo " tylko w /usr/share/wayland-sessions, wiec zeby COSMIC pojawil sie"
echo " na ekranie logowania, jednorazowo skopiuj plik sam:"
echo ""
echo "   sudo cp \"$SESSION_DIR/cosmic.desktop\" /usr/share/wayland-sessions/"
echo ""
echo " Do tego czasu mozesz odpalic COSMIC recznie, np. z TTY:"
echo "   $STORE/bin/cosmic-session"
echo "=================================================================="
