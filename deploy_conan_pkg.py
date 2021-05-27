#!/usr/bin/python3
'''
Created on Apr 30, 2021

@author: Gustavo Puche
'''
import argparse
import logging
import os
import platform
import shutil
from tempfile import mkstemp
from shutil import copy
from os import remove, close
from distutils.dir_util import copy_tree
import fileinput
import subprocess
import sys
from pathlib import Path

def replaceStringFile(filename,text_to_search,replacement_text):
    '''
    
    Replace string into file

    '''

    with fileinput.FileInput(filename, inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace(text_to_search, replacement_text), end='')

def clear_file_flag(filename,flag):
    '''
    
    Clears flag in file

    '''
    replaceStringFile(filename,flag,"")
            
class Deployer():
    '''

    Deploy class

    '''

    def __init__(self, src, dst, system, build, pkg):
        '''

        Deployer constructor

        '''

        self.src = src
        self.dst = dst
        self.system  = system
        self.build = build
        self.pkg = pkg

        # Needed to prevent copytree Error if self.dst exists.
        shutil.rmtree(self.dst, True)
                
        # Creates main project folder.
        if not os.path.exists(self.dst):
            logging.info("Create main folder "+self.dst)
            os.mkdir(self.dst)
        else:
            logging.info("Main folder "+self.dst+" already exists!!!")


    def deploy(self):
        '''

        Deploy Conan package from binaries.

        '''

        ########################################
        # Debug
        logging.warning("Init Deployment ...")

        # Copy conanfile.py.
        shutil.copy('conanfile.py',self.dst+'/conanfile.py')

        if self.system == 'android':
            # Copy res/test to path/test
            shutil.copytree(self.src+'/armeabi-v7a/include',self.dst+'/include')
        else:
            # Copy res/test to path/test
            shutil.copytree(self.src+'/include',self.dst+'/include')

        # Destination libs path.
        dst_libs_path = self.dst+'/lib'

        # Creates lib dir.
        os.mkdir(dst_libs_path)


        if self.system == 'android':

            # Do it twice.
            for i in range(2):

                # Setup libs path
                if i == 0:
                    # armeabi libs path
                    src_libs_path = self.src+'/armeabi-v7a/lib'
                    lib_suffix = '_armeabi-v7a'
                else:
                    # arm64-v8a libs path
                    src_libs_path = self.src+'/arm64-v8a/lib'
                    lib_suffix = '_arm64-v8a'

                # Gets all files in armeabi libs path.
                files = os.listdir(src_libs_path)

                # For each file in armeabi libs path.
                for index, file in enumerate(files):
                    if not os.path.isdir(os.path.join(src_libs_path, file)):
                        shutil.copy(os.path.join(src_libs_path, file),os.path.join(dst_libs_path, file))
                        if file.endswith(".a"):
                            os.rename(os.path.join(dst_libs_path, file), os.path.join(dst_libs_path, file.replace('.a',lib_suffix+'.a')))
                        elif file.endswith(".la"):
                            os.rename(os.path.join(dst_libs_path, file), os.path.join(dst_libs_path, file.replace('.la',lib_suffix+'.la')))

        elif self.system == 'windows':

            src_bin_path  = self.src+'/bin'
            dst_bin_path  = self.dst+'/bin'
            src_libs_path = self.src+'/lib'

            # Creates bin dir.
            os.mkdir(dst_bin_path)
            
            # Gets all files in armeabi libs path.
            files = os.listdir(src_bin_path)

            for index, file in enumerate(files):
                logging.info("file: "+file)
                if not os.path.isdir(os.path.join(src_libs_path, file)):
                    if file.endswith(".dll"):
                        logging.info("copy dll: "+file)
                        shutil.copy(os.path.join(src_bin_path, file),os.path.join(dst_bin_path, file))
                    elif file.endswith(".lib") or file.endswith(".pdb"):
                        logging.info("copy lib: "+file)
                        shutil.copy(os.path.join(src_bin_path, file),os.path.join(dst_libs_path, file))

            # Copy pdb if in debug mode.
            if self.build == 'debug':
                for path in Path(self.src+'/..').rglob('*.pdb'):
                    logging.info("copy debug symbols: "+path.name)
                    shutil.copy(os.path.join(path.parent, path.name),os.path.join(dst_libs_path, path.name))

            

        # Export conan package locally.
        self.build_local_conan_pkg()


    def build_local_conan_pkg(self):
        '''

        Runs conan export-pkg into conan pkg folder.
        
        '''

        if self.system == 'android':

            conan_profile = "android.multiabi."+self.build

        elif self.system == 'windows':

            conan_profile = "msvc19.x86."+self.build

        ########################################
        # Conan stuff
        os.chdir(self.dst)

        # Info message.
        logging.info("Change to "+os.getcwd())
        logging.info("Conan package: "+self.pkg)
        logging.info("Conan profile: "+conan_profile)
            
        subprocess.run(["conan","export-pkg",".",self.pkg,"--profile",conan_profile,"-f"])

    def upload_conan_pkgs(self):
        '''
        
        Uploads conan packages

        '''

        subprocess.run(["conan","upload",self.pkg,"-r","dn","--all"])
        
    def __clear_bak_files(self):
        '''

        Clears bak files from replacestringfile function.

        '''
        bak_files=list(Path(self.path).rglob("*.bak"))
        for item in bak_files:
            logging.info("Cleaning "+str(item))
            os.remove(item)

class MyParser(argparse.ArgumentParser):

    '''

    Parser class to input arguments

    '''

    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)


def main(argv=None):
    '''

    Main function to console testing

    '''
    if argv is None:
        argv = sys.argv

        # Parse arguments
        parser = MyParser(description='Deploy Android Multi-Abi Conan package for ffmpeg.')
        parser.add_argument('src', help='Binary libraries folder.')
        parser.add_argument('dst', help='Conan package folder.')
        parser.add_argument('--os_type','-os', const='android', default='android', nargs='?', choices=['android','windows','macos','ios'], help='Operating System type')
        parser.add_argument('--build_type','-b', const='debug', default='debug', nargs='?', choices=['debug','release'], help='Build type')
        parser.add_argument('--conan_package','-p', const='fdk_aac/2.1.1@dn/develop', default='fdk_aac/2.1.1@dn/develop', nargs='?', help='Conan package name')
        parser.add_argument('-u', '--upload', action='store_true', help='Uploads Conan packages.')

        args = parser.parse_args()

        logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)

        # Input filename
        logging.warning("Conan package folder path: " + args.src)

        # Calls Deploryer constructor
        deployer = Deployer(args.src,args.dst,args.os_type,args.build_type,args.conan_package)

        # Deploy project.
        deployer.deploy()

        
        if args.upload:
            deployer.upload_conan_pkgs()

if __name__ == "__main__":
    import sys
    sys.exit(main())
