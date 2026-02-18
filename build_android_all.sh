#!/usr/bin/env bash

# --- Ensure bash ---
if [ -z "${BASH_VERSION:-}" ]; then
  echo "❌ This script must be executed with bash."
  echo "   Use: bash build_android_all.sh"
  exit 1
fi

set -euo pipefail

# --- Configuration (overridable via environment variables) ---
NDK="${NDK:-}"
API="${API:-26}"
OS_NAME="${OS_NAME:-Android}"

SRC_DIR="${SRC_DIR:-$PWD}"

# Required output layout:
# install/<OS>/<Debug|Release>/lib/<ABI>/
OUT_ROOT="${OUT_ROOT:-$PWD/install}"
BUILD_ROOT="${BUILD_ROOT:-$PWD/build}"

ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
CONFIGS=("Debug" "Release")

# --- Environment validation ---
echo "🔎 Validating environment..."

if [[ -z "$NDK" ]]; then
  echo "❌ NDK variable is not defined."
  echo "   Please export it before running:"
  echo "   export NDK=/path/to/android-ndk"
  exit 1
fi

if [[ ! -d "$NDK" ]]; then
  echo "❌ NDK not found at: $NDK"
  exit 1
fi

if [[ ! -f "$NDK/build/cmake/android.toolchain.cmake" ]]; then
  echo "❌ android.toolchain.cmake not found inside the NDK."
  exit 1
fi

if ! command -v cmake >/dev/null 2>&1; then
  echo "❌ cmake is not installed or not available in PATH."
  exit 1
fi

if [[ ! -f "$SRC_DIR/CMakeLists.txt" ]]; then
  echo "❌ CMakeLists.txt not found in: $SRC_DIR"
  echo "   Are you inside the fdk-aac repository?"
  exit 1
fi

echo "✅ Environment OK"
echo
echo "OS       : $OS_NAME"
echo "NDK      : $NDK"
echo "API      : $API"
echo "Source   : $SRC_DIR"
echo "Install  : $OUT_ROOT/$OS_NAME/<Debug|Release>/(lib|include)"
echo "Build    : $BUILD_ROOT/$OS_NAME/<ABI>/<Debug|Release>"
echo

mkdir -p "$OUT_ROOT" "$BUILD_ROOT"

# --- Build loop ---
for ABI in "${ABIS[@]}"; do
  for CFG in "${CONFIGS[@]}"; do
    CFG_LC="$(echo "$CFG" | tr '[:upper:]' '[:lower:]')"  # Debug -> debug, Release -> release

    echo "======================================"
    echo "🚀 Building: $OS_NAME | ABI: $ABI | Config: $CFG (API $API)"
    echo "======================================"

    BUILD_DIR="$BUILD_ROOT/$OS_NAME/$ABI/$CFG"
    PREFIX="$OUT_ROOT/$OS_NAME/$CFG"   # ABI will be placed under lib/<ABI> later

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    cmake -S "$SRC_DIR" -B "$BUILD_DIR" \
      -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
      -DANDROID_ABI="$ABI" \
      -DANDROID_PLATFORM="android-$API" \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DCMAKE_BUILD_TYPE="$CFG" \
      -DCMAKE_INSTALL_PREFIX="$PREFIX"

    cmake --build "$BUILD_DIR" --parallel
    cmake --install "$BUILD_DIR"

    # Final required layout:
    # <OUT_ROOT>/<OS>/<CFG>/lib/<ABI>/libfdk-aac_<ABI>.a
    SRC_LIB="$PREFIX/lib/libfdk-aac.a"
    DST_LIB_DIR="$PREFIX/lib/$ABI"
    DST_LIB="$DST_LIB_DIR/libfdk-aac_${ABI}.a"

    mkdir -p "$DST_LIB_DIR"

    if [[ -f "$SRC_LIB" ]]; then
      mv -f "$SRC_LIB" "$DST_LIB"
      echo "✅ Generated: $DST_LIB"
    else
      echo "❌ $SRC_LIB not found"
      echo "   Contents of $PREFIX/lib:"
      ls -la "$PREFIX/lib" || true
      exit 1
    fi

    echo
  done
done

echo "🎉 Build completed successfully."
echo "Final layout:"
echo "  $OUT_ROOT/$OS_NAME/<Debug|Release>/lib/<ABI>/libfdk-aac_<ABI>.a"
echo "  $OUT_ROOT/$OS_NAME/<Debug|Release>/include/..."

