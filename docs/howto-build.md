# How to build Codium

## Table of Contents

- [Dependencies](#dependencies)
  - [Linux](#dependencies-linux)
  - [MacOS](#dependencies-macos)
  - [Windows](#dependencies-windows)
- [Build Scripts](#build-scripts)
- [Build in Docker](#build-docker)
  - [X64](#build-docker-x64)
  - [ARM 32bits](#build-docker-arm32)
- [Build Snap](#build-snap)
- [Patch Update Process](#patch-update-process)
  - [Semi-Automated](#patch-update-process-semiauto)
  - [Manual](#patch-update-process-manual)

## <a id="dependencies"></a>Dependencies

- node 16
- yarn 1.x
- jq 1.x
- git
- python3.11
- python3-distutils
- python3-setuptools

### <a id="dependencies-linux"></a>Linux

- gcc
- g++
- make
- pkg-config
- libx11-dev
- libxkbfile-dev
- libsecret-1-dev
- libkrb5-dev
- fakeroot
- rpm
- rpmbuild
- dpkg
- imagemagick (for AppImage)
- snapcraft (for .snap)

### <a id="dependencies-macos"></a>MacOS

See [the common dependencies](#dependencies) and XCode 13.x or higher

### <a id="dependencies-windows"></a>Windows

- bash (such as Git Bash from [Git for Windows](https://gitforwindows.org/) or MSYS2)
- powershell
- sed (bundled with Git Bash)
- jq.exe > https://jqlang.github.io/jq/download/ (rename to jq.exe and put in your PATH)
- 7z > https://www.7-zip.org/download.html (download the "7-Zip Extra: standalone console version, 7z DLL, Plugin for Far Manager
" and add to your existing 7-Zip installation folder, then add that folder to your path)
- [WiX Toolset](http://wixtoolset.org/releases/)
- 'Tools for Native Modules' from the official Node.js installer OR Visual Studio 2019/2022 with C++ Workload added

## <a id="build-scripts"></a>Build Scripts

A build helper script can be found at `build/build.sh`.  
A wrapper I made for this script that also passes compiler optimization flags, and patches the source for Win7/8/8.1 is `./build.sh`

- Linux: `./get_repo.sh && ./build.sh --linux`
- MacOS: `./get_repo.sh && ./build.sh --mac`
- Windows: `./get_repo.sh && ./build.sh --win`

 &ndash; Use the `--help` flag to see all available options.  
NOTE: To build for Windows 7/8/8.1 or Ubuntu 18.04/Debian 9, use `./win7_patch.sh` after get_repo.sh, and before build_codium.sh. For MacOS 10.13/10.14, use `./macos_patch.sh` instead.

### Insider

The `insider` version can be built with `./build/build.sh -i` on the `insider` branch.

You can try the latest version with the command `./build/build.sh -il` but the patches might not be up to date.

### Flags

The script `build/build.sh` provides several flags:

- `-i`: build the Insiders version
- `-l`: build with latest version of Visual Studio Code
- `-o`: skip the build step
- `-p`: do not generate the packages/assets/installers
- `-s`: do not retrieve the source code of Visual Studio Code, it won't delete the existing build

## <a id="build-docker"></a>Build in Docker

To build for Linux, you can alternatively build Codium in docker

### <a id="build-docker-x64"></a>X64

Firstly, create the container with:
```
docker run -ti --volume=<local vscodium source>:/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:bionic-x64 bash
```
like
```
docker run -ti --volume=$(pwd):/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:bionic-x64 bash
```

When inside the container, you can use the following commands to build:
```
cd /root/vscodium

./build/build.sh
```

### <a id="build-docker-arm32"></a>ARM 32bits

Firstly, create the container with:
```
docker run -ti --volume=<local vscodium source>:/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:bionic-armhf bash
```
like
```
docker run -ti --volume=$(pwd):/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:bionic-armhf bash
```

When inside the container, you can use the following commands to build:
```
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs desktop-file-utils

cd /root/vscodium

./build/build.sh
```

## <a id="build-snap"></a>Build Snap

```
# for the stable version
cd ./stores/snapcraft/stable

# for the insider version
cd ./stores/snapcraft/insider

# create the snap
snapcraft --use-lxd

# verify the snap
review-tools.snap-review --allow-classic codium*.snap
```

## <a id="patch-update-process"></a>Patch Update Process

## <a id="patch-update-process-semiauto"></a>Semi-Automated

- run `./build/build_<os>.sh`, if a patch is failing then,
- run `./build/update_patches.sh`
- when the script pauses at `Press any key when the conflict have been resolved...`, open `vscode` directory in **Codium**
- fix all the `*.rej` files
- run `yarn watch`
- run `./script/code.sh` until everything is ok
- press any key to continue the script `update_patches.sh`

## <a id="patch-update-process-manual"></a>Manual

- run `./build/build_<os>.sh`, if a patch is failing then,
- open `vscode` directory in **Codium**
- revert all changes
- run `git apply --reject ../patches/<name>.patch`
- fix all the `*.rej` files
- run `yarn watch`
- run `./script/code.sh` until everything is ok
- run `git diff > ../patches/<name>.patch`

### <a id="icons"></a>icons/build_icons.sh

To run `icons/build_icons.sh`, you will need:

- imagemagick
- png2icns (`npm install png2icns -g`)
- librsvg
