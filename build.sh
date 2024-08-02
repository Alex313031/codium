#!/bin/bash

# Copyright(c) 2024 Alex313031

YEL='\033[1;33m' # Yellow
CYA='\033[1;96m' # Cyan
RED='\033[1;31m' # Red
GRE='\033[1;32m' # Green
c0='\033[0m' # Reset Text
bold='\033[1m' # Bold Text
underline='\033[4m' # Underline Text

# Error handling
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "${RED}Failed $*"; }

# --help
displayHelp () {
	printf "\n" &&
	printf "${bold}${GRE}Script to build Codium for Linux or Windows.${c0}\n" &&
	printf "${bold}${YEL}Use the --deps flag to install build dependencies.${c0}\n" &&
	printf "${bold}${YEL}Use the --linux flag to build for Linux.${c0}\n" &&
	printf "${bold}${YEL}Use the --linux-arm flag to build for Linux (arm64).${c0}\n" &&
	printf "${bold}${YEL}Use the --avx flag to build for Linux (AVX Version).${c0}\n" &&
	printf "${bold}${YEL}Use the --win flag to build for Windows (x64).${c0}\n" &&
	printf "${bold}${YEL}Use the --win32 flag to build for Windows (x86).${c0}\n" &&
	printf "${bold}${YEL}Use the --mac flag to build for MacOS.${c0}\n" &&
	printf "${bold}${YEL}Use the --mac-arm flag to build for MacOS (arm64).${c0}\n" &&
	printf "${bold}${YEL}Use the --clean flag to remove all artifacts.\n" &&
	printf "${bold}${YEL}Use the --help flag to show this help.${c0}\n" &&
	printf "\n"
}
case $1 in
	--help) displayHelp; exit 0;;
esac

# Install prerequisites
installDeps () {
	sudo apt-get install build-essential git g++ pkg-config automake make gcc libsecret-1-dev \
	fakeroot rpm dpkg dpkg-dev imagemagick libkrb5-dev libx11-dev libxkbfile-dev jq python3 librsvg
}
case $1 in
	--deps) installDeps; exit 0;;
esac

cleanCodium () {
	./clean.sh
}
case $1 in
	--clean) cleanCodium; exit 0;;
esac

buildLinux (){
printf "\n" &&
printf "${bold}${GRE}Building Codium for Linux...${c0}\n" &&
printf "\n" &&
tput sgr0 &&

export CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export LDFLAGS="-Wl,-O3 -msse3 -s" &&

. ./build/build.sh -s
}
case $1 in
	--linux) buildLinux; exit 0;;
esac

buildLinuxArm (){
printf "\n" &&
printf "${bold}${GRE}Building Codium for Linux...${c0}\n" &&
printf "\n" &&
tput sgr0 &&

export CFLAGS="-DNDEBUG -O3 -g0 -s" &&
export CXXFLAGS="-DNDEBUG -O3 -g0 -s" &&
export CPPFLAGS="-DNDEBUG -O3 -g0 -s" &&
export LDFLAGS="-Wl,-O3 -s" &&

. ./build/build.sh -s -a
}
case $1 in
	--linux-arm) buildLinuxArm; exit 0;;
esac

buildLinuxAVX (){
printf "\n" &&
printf "${bold}${GRE}Building Codium for Linux (AVX Version)...${c0}\n" &&
printf "\n" &&
tput sgr0 &&

export CFLAGS="-DNDEBUG -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -O3 -g0 -s" &&
export CXXFLAGS="-DNDEBUG -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -s" &&
export CPPFLAGS="-DNDEBUG -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -s" &&
export LDFLAGS="-Wl,-O3 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -maes -s" &&

printf "\n" &&
printf "${GRE}Patching vscode to use AVX Electron...${c0}\n" &&
printf "\n" &&

cd ./vscode || { printf "\n${RED}Error: 'vscode' dir not found\n\n"; exit 1; }

git apply --reject ../avx.patch  &&
cd .. &&

printf "\n" &&
printf "${GRE}Done!${c0}\n" &&
printf "\n" &&

. ./build/build.sh -s
}
case $1 in
	--avx) buildLinuxAVX; exit 0;;
esac

buildWin64 (){
printf "\n" &&
printf "${bold}${GRE}Building Codium for Windows (x64)...${c0}\n" &&
printf "\n" &&
tput sgr0 &&

# Set msvs_version for node-gyp on Windows
export MSVS_VERSION="2022" &&
export GYP_MSVS_VERSION="2022" &&
set MSVS_VERSION="2022" &&
set GYP_MSVS_VERSION="2022" &&

export CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export LDFLAGS="-Wl,-O3 -msse3 -s" &&
set CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set LDFLAGS="-Wl,-O3 -msse3 -s" &&

. ./build/build.sh -s
}
case $1 in
	--win) buildWin64; exit 0;;
esac

buildWin32 (){
printf "\n" &&
printf "${bold}${GRE}Building Codium for Windows (x86)...${c0}\n" &&
printf "\n" &&
tput sgr0 &&

# Set msvs_version for node-gyp on Windows
export MSVS_VERSION="2022" &&
export GYP_MSVS_VERSION="2022" &&
set MSVS_VERSION="2022" &&
set GYP_MSVS_VERSION="2022" &&

export CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
export LDFLAGS="-Wl,-O3 -msse3 -s" &&
set CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s" &&
set LDFLAGS="-Wl,-O3 -msse3 -s" &&

. ./build/build.sh -s -w
}
case $1 in
	--win32) buildWin32; exit 0;;
esac

buildMac (){
printf "\n" &&
printf "${bold}${GRE}Building Codium for MacOS (x86_64 version)...${c0}\n" &&
printf "\n" &&
tput sgr0 &&

export CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s -Wno-unused-command-line-argument" &&
export CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s -Wno-unused-command-line-argument" &&
export CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s -Wno-unused-command-line-argument" &&
export LDFLAGS="-msse3 -s" &&

. ./build/build.sh -s
}
case $1 in
	--mac) buildMac; exit 0;;
esac

buildMacArm (){
printf "\n" &&
printf "${bold}${GRE}Building Codium for MacOS (arm64 version)...${c0}\n" &&
printf "\n" &&
tput sgr0 &&

export CFLAGS="-DNDEBUG -O3 -g0 -s -Wno-unused-command-line-argument" &&
export CXXFLAGS="-DNDEBUG -O3 -g0 -s -Wno-unused-command-line-argument" &&
export CPPFLAGS="-DNDEBUG -O3 -g0 -s -Wno-unused-command-line-argument" &&
export LDFLAGS="-s" &&

. ./build/build.sh -s -a
}
case $1 in
	--mac-arm) buildMacArm; exit 0;;
esac

printf "\n" &&
printf "${bold}${GRE}Script to build Codium for Linux or Windows.${c0}\n" &&
printf "${bold}${YEL}Use the --deps flag to install build dependencies.${c0}\n" &&
printf "${bold}${YEL}Use the --linux flag to build for Linux.${c0}\n" &&
printf "${bold}${YEL}Use the --linux-arm flag to build for Linux (arm64).${c0}\n" &&
printf "${bold}${YEL}Use the --avx flag to build for Linux (AVX Version).${c0}\n" &&
printf "${bold}${YEL}Use the --win flag to build for Windows (x64).${c0}\n" &&
printf "${bold}${YEL}Use the --win32 flag to build for Windows (x86).${c0}\n" &&
printf "${bold}${YEL}Use the --mac flag to build for MacOS.${c0}\n" &&
printf "${bold}${YEL}Use the --mac-arm flag to build for MacOS (arm64).${c0}\n" &&
printf "${bold}${YEL}Use the --clean flag to remove all artifacts.\n" &&
printf "${bold}${YEL}Use the --help flag to show this help.${c0}\n" &&
printf "\n" &&
tput sgr0
