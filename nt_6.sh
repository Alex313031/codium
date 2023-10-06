#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# Make patch
# git diff -U1 > ../nt6.patch

git apply --ignore-whitespace ../nt6.patch  &&

/usr/bin/find ./ \( -type d -name .git -prune -type d -name node_modules -prune \) -o -type f -name package.json -print0 | xargs -0 sed -i 's/\"\@types\/node\"\:\ \"18\.x\"/\"\@types\/node\"\:\ \"16\.x\"/g' &&

cd ..

echo "Patched for Windows NT 6.x!"
