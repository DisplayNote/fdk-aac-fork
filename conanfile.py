import os
from conans import ConanFile
from conans import tools

class Fdk_aacConan(ConanFile): 
    settings    = "os", "compiler", "build_type", "arch"
    description = "Package for fdk_aac "
    url = "None"
    license = "None"
    generators = "qmake"
    keep_imports=True
    no_copy_source=True
    #requires = qt_exact_requirements(super)

    def getEnvs(self):
        pass

    def package_info(self):
        if self.settings.os == 'Android':
            if self.settings.arch == 'armv7':
                self.cpp_info.libdirs = ["lib/armeabi-v7a"]
            elif self.settings.arch == 'armv8':
                self.cpp_info.libdirs = ["lib/arm64-v8a"]
            elif self.settings.arch == 'x86_64':
                self.cpp_info.libdirs = ["lib/x86_64"]
            elif self.settings.arch == 'x86':
                self.cpp_info.libdirs = ["lib/x86"]

        self.cpp_info.libs = tools.collect_libs(self)

    def package(self):
        if self.settings.os == 'Android':
            self.copy("*", src=os.path.join("install", str(self.settings.os), str(self.settings.build_type), "include"), dst="include")
            if self.settings.arch == 'armv7':
                self.copy("*", src=os.path.join("install", str(self.settings.os), str(self.settings.build_type), "lib/armeabi-v7a"), dst="lib/armeabi-v7a")
            elif self.settings.arch == 'armv8':
                self.copy("*", src=os.path.join("install", str(self.settings.os), str(self.settings.build_type), "lib/arm64-v8a"), dst="lib/arm64-v8a")
            elif self.settings.arch == 'x86_64':
                self.copy("*", src=os.path.join("install", str(self.settings.os), str(self.settings.build_type), "lib/x86_64"), dst="lib/x86_64")
            elif self.settings.arch == 'x86':
                self.copy("*", src=os.path.join("install", str(self.settings.os), str(self.settings.build_type), "lib/x86"), dst="lib/x86")
            else:
                print('Android architecture not supported = '+ self.settings.arch)
        else:
            self.copy("*", src=os.path.join(str(self.settings.os), str(self.settings.build_type)))

