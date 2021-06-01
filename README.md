fdk-aac Build
=============

Instructions to build fdk-aac Conan package.

## Android Multi-ABi

1. Open a terminal.
2. Setup your Android NDK environment variables.
   - The following variables are required:
     - ANDROID_NDK_ROOT
     - ANDROID_NDK_PLATFORM
     - ANDROID_NDK_HOST
   - If Android NDK variables are not defined the script assumes the following values:
     - `ANDROID_NDK_ROOT=/opt/android/ndk/21.3.6528147`
     - `ANDROID_NDK_PLATFORM=android-21`
     - `ANDROID_NDK_HOST=linux-x86_64`
3. Run `build_android_multiabi.sh` script.

4. Headers and Binaries are found in `Android` folder.

## Build fdk_acc for Windows (32 bit):

### Create environment:
1. Launch cmd.exe
2. execute vcvars32.bat (i.e. with VS2019)
```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat with VS2019)
```
3. Get fdk_aac sources (https://github.com/DisplayNote/fdk-aac-fork.git)
4. Go to fdk_aac repo root folder an edit Makefile.vc replace the lines
```
prefix = \usr\local
...
CFLAGS   = /nologo /W3 /Ox /MT /EHsc /Dinline=__inline $(TARGET_FLAGS) $(AM_CPPFLAGS) $(XCFLAGS
```
with
```
%Debug build
prefix = conan-pkg-dbg
...
CFLAGS   = /nologo /W3 /Ox /MDd /EHsc /Dinline=__inline $(TARGET_FLAGS) $(AM_CPPFLAGS) $(XCFLAGS

```
or
```
%Release build
prefix = conan-pkg
...
CFLAGS   = /nologo /W3 /Ox /MD /EHsc /Dinline=__inline $(TARGET_FLAGS) $(AM_CPPFLAGS) $(XCFLAGS

```
5. Build

```
nmake -f Makefile.vc
```
6. Install
```
nmake install -f Makefile.vc
```

7. Clean

```

nmake clean -f Makefile.vc
```

8. Copy `conanfile.py into` install folder and call `conan export-pkg` and `conan upload` to generate Conan packages.

## Create Conan package

After build use `deploy_conan_pkg.py` to export and upload conan package.

To see script options run it without arguments:

```bash
./deploy_conan_pkg.py
```

Output:

```bash
./deploy_conan_pkg.py
error: the following arguments are required: src, dst
usage: deploy_conan_pkg.py [-h] [--os_type [{android,windows,macos,ios}]]
                           [--build_type [{debug,release}]]
                           [--conan_package [CONAN_PACKAGE]] [-u]
                           src dst

Deploy Android Multi-Abi Conan package for ffmpeg.

positional arguments:
  src                   Binary libraries folder.
  dst                   Conan package folder.

optional arguments:
  -h, --help            show this help message and exit
  --os_type [{android,windows,macos,ios}], -os [{android,windows,macos,ios}]
                        Operating System type
  --build_type [{debug,release}], -b [{debug,release}]
                        Build type
  --conan_package [CONAN_PACKAGE], -p [CONAN_PACKAGE]
                        Conan package name
  -u, --upload          Uploads Conan packages.
```
By default fdk_acc/2.1.1@dn/develop package is generated.

If you want to generate another package use `-p` option.

To generate fdk_acc/2.1.1@dn/develop Debug Conan package for android multiabi try this:

```bash
./deploy_conan_pkg.py Android/Debug conan-pkg-dbg
```

To generate fdk_acc/2.2.0@dn/develop Release Conan package for android multiabi and upload packages to JFrog try this:

```bash
./deploy_conan_pkg.py Android/Release conan-pkg -b release -p fdk_acc/2.2.0@dn/develop -u
```
