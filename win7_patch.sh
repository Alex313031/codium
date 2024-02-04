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

cd vscode || { printf "\n${RED}Error: 'vscode' dir not found\n\n"; exit 1; }

printf "\n" &&
printf "${GRE}Patching vscode for Windows NT 6.x...${c0}\n" &&
printf "\n" &&

# Make patch
# git diff > ../nt6.patch

git apply --reject ../nt6.patch  &&

/usr/bin/find ./ \( -type d -name .git -prune -type d -name node_modules -prune \) -o -type f -name package.json -print0 | xargs -0 sed -i 's/\"\@types\/node\"\:\ \"18\.x\"/\"\@types\/node\"\:\ \"16\.x\"/g' &&

cd .. &&

printf "\n" &&
printf "${GRE}Patched for Windows NT 6.x!\n" &&
printf "\n" &&
tput sgr0
