# hpm package: `cosmic`

Pakiet HPM dla **COSMIC** — natywnego dla Wayland środowiska graficznego
tworzonego przez System76 (projekt "Epoch"), budowanego ze źródeł upstream
[`github.com/pop-os/cosmic-epoch`](https://github.com/pop-os/cosmic-epoch).

To repozytorium (folder `cosmic/`) jest samodzielnym pakietem HPM w formacie
opisanym w głównym README projektu HackerOS-Package-Manager — to znaczy: żeby
działało z `hpm install cosmic`, ten folder musi być swoim własnym
repozytorium git (np. `https://github.com/<ty>/hpm-cosmic`), zarejestrowanym
w `repo-list.json` / `repo.json`:

```json
{ "packages": { "cosmic": "https://github.com/<ty>/hpm-cosmic" } }
```

Do czasu wypchnięcia jako osobne repo możesz testować lokalnie bez rejestracji
w indeksie:

```sh
hpm dev ./cosmic
hpm dev ./cosmic run cosmic-session
```

## Co to instaluje

`build.toml` klonuje `cosmic-epoch` na tagu `epoch-1.4.0` (aktualne stabilne
wydanie w chwili tworzenia tego pakietu — podbij tag gdy System76 wyda
kolejną wersję) i buduje je komendami `just build` / `just install`
udokumentowanymi w justfile tego projektu. Wynik trafia w całości do
`~/.hackeros/hpm/store/cosmic/<wersja>/`:

- `bin/cosmic-session`, `bin/cosmic-comp`, `bin/cosmic-panel`,
  `bin/cosmic-launcher`, `bin/cosmic-files`, `bin/cosmic-settings`,
  `bin/cosmic-app-library`, `bin/cosmic-bg`, `bin/cosmic-notifications`,
  `bin/cosmic-osd`, `bin/cosmic-workspaces` (deklarowane w `info.hk` jako
  osobne `bins.*`, więc każdy jest widoczny dla `hpm run cosmic <bin>`)
- `share/...` — pliki `.desktop`, schematy GSettings, ikony poszczególnych
  komponentów, tak jak instaluje je oficjalny `just install`.

Budowa to ~27 crate'ów Rust — licz się z 30-90+ minutami i kilkoma GB miejsca
przy pierwszym `hpm install cosmic`, zależnie od sprzętu.

## Dlaczego sandbox jest wyłączony (`sandbox.disabled => true`)

Wszystkie inne przykładowe pakiety w tym repo (sysforge, glyph-editor...) są
uruchamiane w standardowym sandboxie hpm (namespaces + seccomp + Landlock).
COSMIC **jest kompozytorem Wayland** — musi mieć bezpośredni dostęp do
`/dev/dri`, przejąć sesję przez `logind`/`seatd`, otwierać gniazda
Wayland/DBus systemowe itd. Odizolowanie tego w namespace'ach w praktyce
uniemożliwiłoby mu narysowanie czegokolwiek na ekranie, więc pakiet jawnie
wyłącza sandbox — to świadomy wyjątek, nie przeoczenie, i jest udokumentowany
tutaj oraz w `info.hk`.

`sandbox.network => true` jest potrzebne niezależnie od tego, bo sam krok
budowania (`git clone` submodułów + pobieranie crate'ów przez cargo)
wymaga sieci.

## Integracja z ekranem logowania

`hpm` z założenia nigdy nie dotyka ścieżek systemowych bez `sudo` (patrz
główne README: jedyny wyjątek to `hpm upgrade` samego hpm). Rejestracja
sesji Wayland dla menedżerów logowania (GDM/SDDM/LightDM) normalnie wymaga
pliku w `/usr/share/wayland-sessions/`, do którego hpm jako user nie ma
dostępu — więc:

1. Hook `post-install` zapisuje `cosmic.desktop` lokalnie w
   `~/.local/share/wayland-sessions/` i wypisuje gotową komendę.
2. Ty jednorazowo odpalasz:
   ```sh
   sudo cp ~/.local/share/wayland-sessions/cosmic.desktop /usr/share/wayland-sessions/
   ```
3. Od tego momentu COSMIC pojawia się jako opcja sesji na ekranie logowania.

Hook `pre-remove` sprząta lokalny plik automatycznie i przypomina o ręcznym
usunięciu systemowej kopii, jeśli ją zrobiłeś/aś.

## Znane ograniczenia tego pakietu

- Tagi wydań `cosmic-epoch` (`epoch-X.Y.Z`) trzeba ręcznie podbijać w
  `build.toml` przy nowych wersjach upstream — nie ma tu automatycznego
  śledzenia najnowszego tagu.
- Nazwy recept `just build` / `just install` pochodzą z justfile projektu w
  chwili pisania tego pakietu; jeśli upstream je zmieni, zaktualizuj
  `build.toml`.
- To pierwsza, ręcznie utworzona wersja pakietu — nie testowana na realnym
  sprzęcie w tym środowisku (brak dostępu do sieci/GPU tutaj), więc przed
  użyciem produkcyjnym warto przejść przez `hpm dev ./cosmic` na docelowej
  maszynie i dopasować listy `deb_deps` do swojej dystrybucji.
