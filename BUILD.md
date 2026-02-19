## BUILD INSTRUCTIONS

### Android
#### Recommended tools:

- Android NDK 28
- Cmake
- Bash

```
export NDK=path/to/android-ndk
./build_android_all.sh
```

Script will build artifacts for Android arm, arm64, x86 and x86_64, Debug and Release configurations

### Windows

#### Requisites:

- Visual Studio 16 2019 (MSVC 19)
- Cmake

```
build_windows_all.bat
```

Script will build artifacts for Windows x86 and x86_64, Debug and Release configurations

### Build artifacts

Scripts generate this artifact tree, then conan packages can be created from repo's root folder

```
conan export-pkg . fdk-aac/<version>@dn/<channel> -pr <profile> [-f]
```


```text

├───install
    ├───Windows
    │   ├───Debug
    │   │   ├───include
    │   │   │   └───fdk-aac
    │   │   │           aacdecoder_lib.h
    │   │   │           aacenc_lib.h
    │   │   │           FDK_audio.h
    │   │   │           genericStds.h
    │   │   │           machine_type.h
    │   │   │           syslib_channelMapDescr.h
    │   │   │
    │   │   └───lib
    │   │       ├───x86
    │   │       │       fdk-aac.lib
    │   │       │
    │   │       └───x86_64
    │   │               fdk-aac.lib
    │   │
    │   └───Release
    │       ├───include
    │       │   └───fdk-aac
    │       │           aacdecoder_lib.h
    │       │           aacenc_lib.h
    │       │           FDK_audio.h
    │       │           genericStds.h
    │       │           machine_type.h
    │       │           syslib_channelMapDescr.h
    │       │
    │       └───lib
    │           ├───x86
    │           │       fdk-aac.lib
    │           │
    │           └───x86_64
    │                   fdk-aac.lib
    └───Android
        ├───Debug
        │   ├───include
        │   │   └───fdk-aac
        │   │           aacdecoder_lib.h
        │   │           aacenc_lib.h
        │   │           FDK_audio.h
        │   │           genericStds.h
        │   │           machine_type.h
        │   │           syslib_channelMapDescr.h
        │   │
        │   └───lib
        │       ├───armeabi-v7a
        │       │       libfdk-aac_armeabi-v7a.a
        │       │
        │       ├───arm64-v8a
        │       │       libfdk-aac_arm64-v8a.a
        │       │
        │       ├───x86
        │       │       libfdk-aac_x86.a
        │       │
        │       └───x86_64
        │               libfdk-aac_x86_64.a
        │
        └───Release
            ├───include
            │   └───fdk-aac
            │           aacdecoder_lib.h
            │           aacenc_lib.h
            │           FDK_audio.h
            │           genericStds.h
            │           machine_type.h
            │           syslib_channelMapDescr.h
            │
            └───lib
                ├───armeabi-v7a
                │       libfdk-aac_armeabi-v7a.a
                │
                ├───arm64-v8a
                │       libfdk-aac_arm64-v8a.a
                │
                ├───x86
                │       libfdk-aac_x86.a
                │
                └───x86_64
                        libfdk-aac_x86_64.a

```