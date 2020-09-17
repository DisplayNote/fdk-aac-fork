NDK=/home/lucio/Android/Sdk/ndk/19.2.5345600
CROSS_PREFIX=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
PLATFORM=$NDK/platforms/android-16/arch-arm
CPU=arm
PREFIX=$PWD/install
OPTIMIZE_CFLAGS="-fPIC"

./configure --prefix=$PREFIX \
    --with-sysroot=$NDK/sysroot \
    --host=arm-linux \
    --with-pic=no \
    --enable-static \
    --disable-shared \
    CC=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi16-clang \
    CXX=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi16-clang++ \
    RANLIB="${CROSS_PREFIX}ranlib" \
    AR="${CROSS_PREFIX}ar" \
    STRIP="${CROSS_PREFIX}strip" \
    NM="${CROSS_PREFIX}nm" \
    CFLAGS="-fPIC" \
    CXXFLAGS="-fPIC"


