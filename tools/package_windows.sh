#!/usr/bin/env bash
# Cross-compile the Windows build with MinGW-w64 and zip it up.
#   tools/package_windows.sh [SDL2 version]
# Needs: mingw-w64 (x86_64-w64-mingw32-g++-posix, GCC 13+), cmake, curl, zip.
# Produces dist/OmegaDeck-windows-x64.zip containing:
#   omega.exe, SDL2.dll, assets/, lib/, README-HANDHELD.md, CREDITS.md, COPYING
set -euo pipefail
cd "$(dirname "$0")/.."

sdl_ver=${1:-2.30.9}
deps=build-deps
sdl_dir=$deps/SDL2-$sdl_ver
if [[ ! -d $sdl_dir ]]; then
  mkdir -p $deps
  curl -fsSL -o $deps/sdl.tgz \
    "https://github.com/libsdl-org/SDL/releases/download/release-$sdl_ver/SDL2-devel-$sdl_ver-mingw.tar.gz"
  tar -xzf $deps/sdl.tgz -C $deps
fi

cmake -S . -B build-win -DCMAKE_BUILD_TYPE=Release -DOMEGA_SDL=ON \
  -DCMAKE_TOOLCHAIN_FILE=tools/mingw-toolchain.cmake \
  -DSDL2_DIR="$PWD/$sdl_dir/cmake"
cmake --build build-win -j"$(nproc)"

out=dist/OmegaDeck-windows
rm -rf "$out"
mkdir -p "$out/assets"
cp build-win/omega.exe build-win/SDL2.dll "$out/"
cp -r lib "$out/lib"
cp assets/tiles.rgba assets/tiles.txt assets/font.rgba assets/font.txt "$out/assets/"
cp docs/README-HANDHELD.md docs/CREDITS.md COPYING "$out/"
cp "$sdl_dir/LICENSE.txt" "$out/SDL2-LICENSE.txt"
(cd dist && rm -f OmegaDeck-windows-x64.zip && zip -qr OmegaDeck-windows-x64.zip OmegaDeck-windows)
echo "wrote dist/OmegaDeck-windows-x64.zip"
