#!/bin/bash

### Windows
# to run with Bash: "C:\Program Files\Git\bin\bash.exe" ./build/build.sh
###

YEL='\033[1;33m' # Yellow
CYA='\033[1;96m' # Cyan
RED='\033[1;31m' # Red
GRE='\033[1;32m' # Green
c0='\033[0m' # Reset Text
bold='\033[1m' # Bold Text
underline='\033[4m' # Underline Text

# --help
displayHelp () {
	printf "\n" &&
	printf "${bold}${GRE}Script to build Codium on Linux.${c0}\n" &&
	printf "${bold}${YEL}Use the --deps flag to install build dependencies.${c0}\n" &&
	printf "${bold}${YEL}Use the -i flag to build with the insider channel.${c0}\n" &&
	printf "${bold}${YEL}Use the -l flag to build with latest tip-o-tree VSCode.${c0}\n" &&
	printf "${bold}${YEL}Use the -o flag to skip building, and only setup source.${c0}\n" &&
	printf "${bold}${YEL}Use the -p flag to skip building assets.${c0}\n" &&
	printf "${bold}${YEL}Use the -s flag to skip (re)downloading the VSCode source.${c0}\n" &&
	printf "${bold}${YEL}Use the --help or -h flag to show this help.${c0}\n" &&
	printf "\n"
}
case $1 in
	--help) displayHelp; exit 0;;
esac
case $1 in
	-h) displayHelp; exit 0;;
esac

export APP_NAME="Codium"
export CI_BUILD="no"
export SHOULD_BUILD="yes"
export SKIP_ASSETS="no"
export SKIP_BUILD="no"
export SKIP_SOURCE="no"
export VSCODE_LATEST="no"
export VSCODE_QUALITY="stable"

export CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s"
export CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s"
export CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s"
export LDFLAGS="-Wl,-O3 -msse3"

while getopts ":ilop" opt; do
  case "$opt" in
    i)
      export VSCODE_QUALITY="insider"
      ;;
    l)
      export VSCODE_LATEST="yes"
      ;;
    o)
      export SKIP_BUILD="yes"
      ;;
    p)
      export SKIP_ASSETS="yes"
      ;;
    s)
      export SKIP_SOURCE="yes"
      ;;
  esac
done

installDeps () {
	sudo apt-get install build-essential git g++ pkg-config automake make gcc libsecret-1-dev fakeroot rpm dpkg dpkg-dev imagemagick libx11-dev libxkbfile-dev nodejs npm node-gyp node-istanbul jq python3 python-is-python3
}
case $1 in
	--deps) installDeps; exit 0;;
esac

case "${OSTYPE}" in
  darwin*)
    export OS_NAME="osx"
    ;;
  msys* | cygwin*)
    export OS_NAME="windows"
    ;;
  *)
    export OS_NAME="linux"
    ;;
esac

UNAME_ARCH=$( uname -m )

if [[ "${UNAME_ARCH}" == "arm64" ]]; then
  export VSCODE_ARCH="arm64"
else
  export VSCODE_ARCH="x64"
fi

echo "OS_NAME=\"${OS_NAME}\""
echo "SKIP_SOURCE=\"${SKIP_SOURCE}\""
echo "SKIP_BUILD=\"${SKIP_BUILD}\""
echo "SKIP_ASSETS=\"${SKIP_ASSETS}\""
echo "VSCODE_ARCH=\"${VSCODE_ARCH}\""
echo "VSCODE_LATEST=\"${VSCODE_LATEST}\""
echo "VSCODE_QUALITY=\"${VSCODE_QUALITY}\""

if [[ "${SKIP_SOURCE}" == "no" ]]; then
  rm -rf vscode* VSCode*

  . get_repo.sh
  . version.sh

  # save variables for later
  echo "MS_TAG=\"${MS_TAG}\"" > build.env
  echo "MS_COMMIT=\"${MS_COMMIT}\"" >> build.env
  echo "RELEASE_VERSION=\"${RELEASE_VERSION}\"" >> build.env
  echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\"" >> build.env
else
  if [[ "${SKIP_ASSETS}" != "no" ]]; then
    rm -rf VSCode*
  fi

  . build.env

  echo "MS_TAG=\"${MS_TAG}\""
  echo "MS_COMMIT=\"${MS_COMMIT}\""
  echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
  echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\""
fi

if [[ "${SKIP_BUILD}" == "no" ]]; then
  if [[ "${SKIP_SOURCE}" != "no" ]]; then
    cd vscode || { echo "'vscode' dir not found"; exit 1; }

    git add .
    git reset -q --hard HEAD

    cd ..
  fi

  . build.sh

  if [[ "${VSCODE_QUALITY}" == "insider" && "${VSCODE_LATEST}" == "yes" ]]; then
    echo "$( cat "insider.json" | jq --arg 'tag' "${MS_TAG/\-insider/}" --arg 'commit' "${MS_COMMIT}" '. | .tag=$tag | .commit=$commit' )" > "insider.json"
  fi
fi

if [[ "${SKIP_ASSETS}" == "no" ]]; then
  if [[ "${OS_NAME}" == "windows" ]]; then
    rm -rf build/windows/msi/releasedir
  fi

  . prepare_assets.sh
fi
