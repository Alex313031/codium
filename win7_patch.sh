#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

# Copyright(c) 2024 Alex313031

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
	printf "${bold}${GRE}Script to patch Codium for Windows NT 6.x and Ubuntu 18.04/Debian 9${c0}\n" &&
	printf "${bold}${YEL}Use ./macos_patch.sh for MacOS.${c0}\n" &&
	printf "${bold}${YEL}Use the --help flag to show this help.${c0}\n" &&
	printf "\n"
}
case $1 in
	--help) displayHelp; exit 0;;
esac

cd ./vscode || { printf "\n${RED}Error: 'vscode' dir not found\n\n"; exit 1; }

printf "\n" &&
printf "${GRE}Patching vscode for Windows NT 6.x...${c0}\n" &&
printf "\n" &&

# Make patch
# git diff > ../nt6.patch

git apply --reject ../nt6.patch  &&

printf "\n" &&
printf "${GRE}Patching vscode for 32-bit Windows...${c0}\n" &&
printf "\n" &&

git apply --reject ../win32-ia32.patch  &&

printf "\n" &&
printf "${GRE}Patching vscode for Ubuntu 18.04/Debian 9...${c0}\n" &&
printf "\n" &&

git apply --reject ../bionic.patch  &&

/usr/bin/find ./ \( -type d -name .git -prune -type d -name node_modules -prune \) -o -type f -name package.json -print0 | xargs -0 sed -i 's/\"\@types\/node\"\:\ \"20\.x\"/\"\@types\/node\"\:\ \"16\.x\"/g' &&

cd .. &&

printf "\n" &&
printf "${GRE}Patched for Windows NT 6.x and Ubuntu 18.04/Debian 9!\n" &&
printf "\n" &&
tput sgr0
