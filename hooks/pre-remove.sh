#!/bin/sh
# pre-remove hook — cosmic
# Blokuje usuniecie (kod != 0) jesli cos pojdzie nie tak przy sprzataniu —
# tutaj tylko ostrzegamy, wiec zawsze konczymy sukcesem.
set -e

SESSION_FILE="$HOME/.local/share/wayland-sessions/cosmic.desktop"
[ -f "$SESSION_FILE" ] && rm -f "$SESSION_FILE"

if [ "$XDG_SESSION_DESKTOP" = "COSMIC" ] || [ "$DESKTOP_SESSION" = "cosmic" ]; then
    echo "Uwaga: wyglada na to, ze usuwasz cosmic z wnetrza aktywnej sesji COSMIC."
    echo "Lepiej wyloguj sie najpierw, zanim dokonczysz usuwanie pakietu."
fi

if [ -f /usr/share/wayland-sessions/cosmic.desktop ]; then
    echo "Uwaga: /usr/share/wayland-sessions/cosmic.desktop nadal istnieje"
    echo "(zostal tam skopiowany recznie przy instalacji przez sudo)."
    echo "hpm nie dotyka sciezek systemowych, wiec usun go sam, jesli chcesz:"
    echo "  sudo rm -f /usr/share/wayland-sessions/cosmic.desktop"
fi
