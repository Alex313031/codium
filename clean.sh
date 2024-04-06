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
	printf "${bold}${GRE}Script to clean Codium${c0}\n" &&
	printf "${bold}${YEL}Removes node_modules, vscode, assets, and build artifacts.${c0}" &&
	printf "\n"
}
case $1 in
	--help) displayHelp; exit 0;;
esac

printf "\n" &&
printf "${bold}${YEL} Cleaning assets, artifacts, and build directory...${c0}\n" &&
printf "\n" &&

rm -r -f build.env &&
rm -r -f assets &&
rm -r -f vscode &&
rm -r -f VSCode-linux-x64 &&
rm -r -f VSCode-linux-arm64 &&
rm -r -f vscode-reh-linux-x64 &&
rm -r -f vscode-reh-linux-arm64 &&
rm -r -f VSCode-win32-x64 &&
rm -r -f vscode-reh-win32-x64 &&
rm -r -f VSCode-darwin-x64 &&
rm -r -f vscode-reh-darwin-x64 &&
rm -r -f VSCode-darwin-arm64 &&
rm -r -f vscode-reh-darwin-arm64 &&

exit 0
