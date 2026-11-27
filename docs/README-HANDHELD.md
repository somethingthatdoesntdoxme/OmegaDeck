# OmegaDeck: Omega for Steam Deck, handhelds and PC

This build of Omega has a 2D tile view, using the DawnLike pixel art, and you
can play it entirely with a gamepad. The game rules haven't changed. Only the
screen and the controls are new.

The game is the work of Laurence R. Brothers and the Omega contributors, and the
C++ port is Lyle Tafoya's. The tiles are DawnLike by DragonDePlatino and
DawnBringer (CC-BY 4.0). See `CREDITS.md` for everyone.

## Install on Steam Deck

1. In Desktop Mode, unpack `omega-handheld.tar.gz` somewhere in your home folder,
   for example `~/Games/omega-handheld`.
2. In Steam, choose *Games → Add a Non-Steam Game*, browse to `omega.sh` and add it.
3. Under the game's controller settings, pick the **Gamepad** template. Don't use
   a keyboard/mouse template. The game reads the pad directly.
4. Go back to Gaming Mode and launch it.

Saves, high scores and settings are kept in your user folder, not the game folder,
so updating or reinstalling never wipes them:

- SteamOS / Linux: `~/.local/share/OmegaDeck/`
- Windows: `%APPDATA%\OmegaDeck\`

When you close the window during a game, the game saves first.

## Install on Windows (PCs, ROG Ally, Legion Go and so on)

Unzip `OmegaDeck-windows-x64.zip` anywhere and run `omega.exe`. Xbox, PlayStation
and Switch Pro pads work out of the box, and so do the built-in controls on Windows
handhelds. To launch it from Steam Big Picture or a handheld's game launcher, add
`omega.exe` as a non-Steam game.

## Battery

The game only redraws when something changes. If you leave it alone for 30 seconds,
the idle animations stop and it uses next to no power. It also stops drawing while
it's in the background (Steam overlay, alt-tab). On the Deck you can cap the frame
rate in the performance menu too, but it isn't needed. To turn animations off
completely, use the Display page described below.

Release builds from GitHub Actions need SDL2 (SteamOS has it) and glibc 2.35 or newer. If it won't start
on an older system, build it there (see "Building" below).

## Controls

The hint bar at the bottom of the screen always shows what the buttons do right now.

### Walking about

| Input | Does |
|---|---|
| D-pad / left stick | Move (8 directions; press two d-pad directions together for diagonals) |
| RB + direction | Run |
| **A** | Context action: pick up, take stairs, enter a site, open a nearby door, otherwise search |
| **X** | Inventory (equip/unequip) |
| **Y** | Action wheel (all commands, 5 pages, LB/RB to flip) |
| LB | Cast a spell |
| LT | Fire / throw (Hunt in the countryside) |
| RT | Rest (Search in the countryside) |
| L3 | Search |
| R3 | Cycle the tile zoom (24 / 32 / 40 / 48 / 64 px) |
| Start | System wheel (save, options, messages, help, quit). Press RB for the **Display** page: zoom, hero sprite, animations, rumble, smooth camera, fullscreen. These settings are remembered. |
| Select | On-screen keyboard (send any key) |
| Touchscreen | Tap the map to step towards that spot, or tap menu lines and keys |

The pad rumbles when you get hurt (harder for bigger hits), and damaged monsters show
a health bar. The mouse pointer hides while you use the pad and comes back when you
move the mouse.

### Prompts

- **Lists and menus** (items, shops, guilds, talk options): move with up/down,
  press **A** to pick and **B** to back out. Prompts like `[abc]` or a row of
  symbols open as a strip that you move through with left/right.
- **Item prompts** (quaff, read, wield...) show your inventory straight away.
- **Yes/No**: A = yes, B = no, X = quit.
- **Directions**: markers appear around your character. Push a direction, or B to cancel.
- **Targeting**: move the cursor and press A to fire at that spot.
- **--MORE--**: A.
- **Text and numbers** (wishes, names, amounts): the on-screen keyboard opens by
  itself. A types, B deletes, X adds a space, Y is shift, Start is Enter and
  Select cancels.

A keyboard still works the same as in classic Omega.

## Options (environment variables)

| Variable | Effect |
|---|---|
| `OMEGA_FULLSCREEN=1` | Start fullscreen (set by `omega.sh`; F11 switches it too) |
| `OMEGA_WINDOW=1920x1080` | Window size when not fullscreen |
| `OMEGA_TEXT_SIZE=24` | Text height in pixels (the default fits 40 rows on screen) |
| `OMEGA_HERO=rogue` | Player sprite: `warrior`, `rogue`, `mage`, `paladin` (or pick it on the Display page) |
| `OMEGA_ANIM=0` | No sprite animation at all |
| `OMEGA_PORTABLE=1` | Keep saves next to the game instead of in your user folder |
| `OMEGA_ASSETS=/path` | Where to find `tiles.rgba` and the other assets |

## Building

Needs CMake, a C++23 compiler (GCC 13 or newer) and the SDL2 development headers.

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release   # OMEGA_SDL=ON is the default
cmake --build build -j
./build/omega
```

`-DOMEGA_SDL=OFF` builds the original curses version.

To build for Windows, cross-compile from Linux with MinGW-w64. This script downloads SDL2 and makes the zip:

```sh
sudo apt install mingw-w64 cmake zip
tools/package_windows.sh          # -> dist/OmegaDeck-windows-x64.zip
```

An MSVC build also works if you point CMake at the SDL2 VC development package
(`-DSDL2_DIR=.../SDL2-2.x/cmake`).

To regenerate the art (`assets/`) from DawnLike, clone
<https://github.com/tommyettinger/DawnLikeAtlas> and run:

```sh
python3 tools/build_atlas.py path/to/DawnLikeAtlas/renamed assets
```

All the sprite choices (which sprite each monster, item and terrain uses) are in
`tools/build_atlas.py`. Change a name there, re-run it and rebuild.

## How it works (for hacking)

- `src/sdl/curses.h` + `sdlcurses.cpp`: a small curses replacement, so the game
  code is almost untouched.
- `src/sdl/frontend.cpp`: the SDL2 renderer (tiles, text panels, hint bar),
  gamepad mapping, action wheel, on-screen keyboard and option picker.
- `src/sdl_hooks.cpp`: works out what each map cell holds (terrain, monster,
  item) and what the A button should do.
- `src/omega_ui.hpp`: lets the game say what kind of input it's waiting for
  (`ui_mode_scope`). In the curses build these calls do nothing.

## Releases

GitHub Actions (`.github/workflows/handheld-release.yml`) builds and smoke-tests every
pull request on Linux and Windows. Each push to `main` publishes a release called
`build-N`, and pushing a `v*` tag publishes a release named after the tag. Every release
has `OmegaDeck-linux-x86_64.tar.gz` (ready for the GitHub Installer Decky plugin) and
`OmegaDeck-windows-x64.zip` attached.
