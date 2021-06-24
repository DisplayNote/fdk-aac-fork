#!/bin/bash

TAG=`basename $0 .sh`

echo_msg() {
    local readonly msg=$1
    local readonly msg2=$2
    echo "${TAG} INFO : $msg $msg2"
}

exit_error() {
    local readonly msg=$1
    echo "${TAG} ERROR : $msg"
    exit 1
}

usage() {
	echo -e "\nUsage:\n$0 [-h][-b][-e][-u][-v [VERSION]] \n\t-h\t\tShow this message. \n\t-b\t\tBuild fdk_acc library. \n\t-e\t\tExport to Conan. \n\t-u\t\tUpload to Conan. \n\t-v [VERSION]\n\t\t\tConan Package Version."
  exit 0
}

function build_release
{
  local CROSS_PREFIX=${TOOLCHAIN}/bin/${COMPILER_PREFIX}
  
  local PREFIX=${PWD}/Android/Release/${ABI}

  ./configure --prefix=${PREFIX} \
              --with-sysroot=${TOOLCHAIN}/sysroot \
              --host=${HOST} \
              --with-pic=no \
              --enable-static \
              --disable-shared \
              RANLIB="${CROSS_PREFIX}ranlib" \
              AR="${CROSS_PREFIX}ar" \
              STRIP="${CROSS_PREFIX}strip" \
              NM="${CROSS_PREFIX}nm" \
              CFLAGS="-fPIC" \
              CXXFLAGS="-fPIC"

  make clean
  make -j8
  make install
}

function build_debug
{
  local CROSS_PREFIX=${TOOLCHAIN}/bin/${COMPILER_PREFIX}
      
  local PREFIX=${PWD}/Android/Debug/${ABI}

  ./configure --prefix=${PREFIX} \
              --with-sysroot=${TOOLCHAIN}/sysroot \
              --host=${HOST} \
              --with-pic=no \
              --enable-static \
              --disable-shared \
              RANLIB="${CROSS_PREFIX}ranlib" \
              AR="${CROSS_PREFIX}ar" \
              STRIP="${CROSS_PREFIX}strip" \
              NM="${CROSS_PREFIX}nm" \
              CFLAGS="-fPIC" \
              CXXFLAGS="-fPIC"
  
  make clean
  make -j8
  make install
}

build=false
conan_export=false
conan_upload=false
webrtc_path=""
pkg_version=0.0.2

# commit=`git log --pretty=format:'%h' -n 1`
# pkg="x264/${commit}@dn/stable"

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

while [ $# -gt 0 ]; do
  case $1 in
    -b)
      build=true
      ;;
    -e)
      conan_export=true
      ;;
    -u)
      conan_upload=true
      ;;
    -h)
      usage
      ;;
    -v)
      shift
      pkg_version=$1
      ;;
    *)
      exit_error "Unknown param $1"
      ;;
  esac
  shift
done

# Setup Conan pkg name.
pkg="x264/${pkg_version}@dn/develop"

# Check kthe arguments
! $build && ! $conan_export && ! $conan_upload && exit_error "No action set"
#$build && [ -z ${webrtc_path} ] && exit_error "No WebRTC path param set"

# Init globals variables
if [ -z $ANDROID_NDK_ROOT ]; then
  ANDROID_NDK_ROOT=/opt/android/ndk/21.3.6528147
  echo ANDROID_NDK_ROOT not defined.
  echo Setting it up to ${ANDROID_NDK_ROOT}
fi

if [ -z $ANDROID_NDK_PLATFORM ]; then
  ANDROID_NDK_PLATFORM=android-21
  echo ANDROID_NDK_PLATFORM not defined.
  echo Setting it up to ${ANDROID_NDK_PLATFORM}

fi

if [ -z $ANDROID_NDK_HOST ]; then
  ANDROID_NDK_HOST=linux-x86_64
  echo ANDROID_NDK_HOST not defined.
  echo Setting it up to ${ANDROID_NDK_HOST}
fi

TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${ANDROID_NDK_HOST}
ANDROID_VERSION=`echo "${ANDROID_NDK_PLATFORM}"|cut -d - -f 2`

#SYSROOT=${ANDROID_NDK_ROOT}/platforms/android-16/arch-arm/
#CROSS_PREFIX=${ANDROID_NDK_ROOT}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/
export X264_BUILD_PATH=${PWD}/build

# Create build dir if not exists.
if [ ! -e build ]; then
    mkdir build
fi

# Build X264 library
if ( $build ); then

  # Android ARM
  COMPILER=armv7a-linux-androideabi
  COMPILER_PREFIX=arm-linux-androideabi-
  HOST=arm-linux
  ABI=armeabi-v7a

  export CC=${TOOLCHAIN}/bin/${COMPILER}${ANDROID_VERSION}-clang # c compiler path
  export CXX=${TOOLCHAIN}/bin/${COMPILER}${ANDROID_VERSION}-clang++ # c++ compiler path

  build_debug
  build_release

  # Android ARM64
  COMPILER=aarch64-linux-android
  COMPILER_PREFIX=aarch64-linux-android-
  HOST=aarch64-linux
  ABI=arm64-v8a

  export CC=${TOOLCHAIN}/bin/${COMPILER}${ANDROID_VERSION}-clang # c compiler path
  export CXX=${TOOLCHAIN}/bin/${COMPILER}${ANDROID_VERSION}-clang++ # c++ compiler path

  build_debug
  build_release

  echo Android ARM and AARCH64 builds finished
fi

# Conan actions
if ( $conan_export ); then

  conan export-pkg . ${pkg} -pr android.multiabi.debug -f
  conan export-pkg . ${pkg} -pr android.multiabi.release -f

  echo ${pkg} has been export to conan
fi

if ( $conan_upload ); then
  conan upload ${pkg} -r dn --all

  echo ${pkg} has been upload to conan
fi
