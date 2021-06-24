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
        self.cpp_info.libs = tools.collect_libs(self)
        #pass

    def package(self):
        self.copy('*', 'include', 'include')
        self.copy('*', 'lib',     'lib')
        self.copy('*', 'bin',     'bin')
        self.copy('*', 'doc',     'doc')
        self.copy('*', 'apk',     'apk')

    # REQ VIA QMAKE, 
    #def requirements(self):        
    #    qt_exact_requirements(self)
    
    def imports(self):
        dest = os.getenv("CONAN_IMPORT_DEST_PATH", "bin")
        self.copy("*", dst=dest, src="lib")
        self.copy("*", dst="lib", src="lib")
        self.copy("*", dst="include", src="include")
        self.copy("*.qch", dst="doc", src="doc")

    def build(self):
        pass
