#!/usr/bin/env bash

if [[ -z "$ANDROID_NDK" ]]; then
  echo "Please specify the Android NDK environment variable \"NDK\"."
  exit 1
fi

cd protobuf
git checkout v23.0

NDK_TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64"
STRIP="$NDK_TOOLCHAIN/bin/llvm-strip"
CLEAN=termux-elf-cleaner

TARGET_ABI="$1"
TARGET_API="27"
PWD="$(pwd)"
generationDir="$PWD/build"
mkdir -p "${generationDir}"

cmake -GNinja -B "$generationDir" \
  -DANDROID_NDK="$ANDROID_NDK" \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI="$TARGET_ABI" \
  -DANDROID_NATIVE_API_LEVEL="$TARGET_API" \
  -DCMAKE_SYSTEM_NAME="Android" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCFLAGS="-fPIE -fPIC" \
  -DLDFLAGS="-llog -lz -lc++_static" \
  -DANDROID_STL="c++_static" \
  -Dprotobuf_BUILD_TESTS=OFF \
  -Dprotobuf_INSTALL=ON \
  
#cmake --build .
ninja -C "$generationDir" "-j$(nproc)" || exit 1

#cd "${generationDir}"
#cmake -DCMAKE_INSTALL_PREFIX="$generationDir/protobuff_install" -P cmake_install.cmake

#tree "$generationDir"

protoc="$generationDir/protoc"
$STRIP --strip-all "$protoc" || exit 1
$CLEAN --api-level "$TARGET_API" "$protoc" || exit 1
