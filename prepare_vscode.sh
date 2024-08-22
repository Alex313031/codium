#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e

# include common functions
. ./utils.sh

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  cp -rp src/insider/* vscode/
else
  cp -rp src/stable/* vscode/
fi

cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

../update_settings.sh

# apply patches
{ set +x; } 2>/dev/null

for file in ../patches/*.patch; do
  if [[ -f "${file}" ]]; then
    echo applying patch: "${file}";
    # grep '^+++' "${file}"  | sed -e 's#+++ [ab]/#./vscode/#' | while read line; do shasum -a 256 "${line}"; done
    if ! git apply --ignore-whitespace "${file}"; then
      echo failed to apply patch "${file}" >&2
      exit 1
    fi
  fi
done

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  for file in ../patches/insider/*.patch; do
    if [[ -f "${file}" ]]; then
      echo applying patch: "${file}";
      if ! git apply --ignore-whitespace "${file}"; then
        echo failed to apply patch "${file}" >&2
        exit 1
      fi
    fi
  done
fi

for file in ../patches/user/*.patch; do
  if [[ -f "${file}" ]]; then
    echo applying user patch: "${file}";
    if ! git apply --ignore-whitespace "${file}"; then
      echo failed to apply patch "${file}" >&2
      exit 1
    fi
  fi
done

if [[ -d "../patches/${OS_NAME}/" ]]; then
  for file in "../patches/${OS_NAME}/"*.patch; do
    if [[ -f "${file}" ]]; then
      echo applying patch: "${file}";
      if ! git apply --ignore-whitespace "${file}"; then
        echo failed to apply patch "${file}" >&2
        exit 1
      fi
    fi
  done
fi

set -x

export ELECTRON_SKIP_BINARY_DOWNLOAD=1
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

if [[ "${OS_NAME}" == "linux" ]]; then
  export VSCODE_SKIP_NODE_VERSION_CHECK=1

  if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi

  CHILD_CONCURRENCY=1 yarn --check-files --network-timeout 180000
elif [[ "${OS_NAME}" == "osx" ]]; then
  CHILD_CONCURRENCY=1 yarn --network-timeout 180000

  yarn postinstall
else
  # TODO: Should be replaced with upstream URL once https://github.com/nodejs/node-gyp/pull/2825
  # gets merged.
  #rm -rf .build/node-gyp
  #mkdir -p .build/node-gyp
  #cd .build/node-gyp

  #git config --global user.email "$( echo "${GITHUB_USERNAME}" | awk '{print tolower($0)}' )-ci@not-real.com"
  #git config --global user.name "${GITHUB_USERNAME} CI"
  #git clone https://github.com/nodejs/node-gyp.git .
  #git checkout v10.0.1
  #npm install

  #npm_config_node_gyp="$( pwd )/bin/node-gyp.js"
  #export npm_config_node_gyp

  #cd ../..

  if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi

  CHILD_CONCURRENCY=1 yarn --check-files --network-timeout 180000
fi

setpath() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --arg 'path' "${2}" --arg 'value' "${3}" 'setpath([$path]; $value)' "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath_json() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --arg 'path' "${2}" --argjson 'value' "${3}" 'setpath([$path]; $value)' "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

# product.json
cp product.json{,.bak}

setpath "product" "checksumFailMoreInfoUrl" "https://go.microsoft.com/fwlink/?LinkId=828886"
setpath "product" "documentationUrl" "https://go.microsoft.com/fwlink/?LinkID=533484#vscode"
setpath_json "product" "extensionsGallery" '{"serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item"}'
setpath "product" "introductoryVideosUrl" "https://go.microsoft.com/fwlink/?linkid=832146"
setpath "product" "keyboardShortcutsUrlLinux" "https://go.microsoft.com/fwlink/?linkid=832144"
setpath "product" "keyboardShortcutsUrlMac" "https://go.microsoft.com/fwlink/?linkid=832143"
setpath "product" "keyboardShortcutsUrlWin" "https://go.microsoft.com/fwlink/?linkid=832145"
setpath "product" "licenseUrl" "https://github.com/Alex313031/codium/blob/master/LICENSE"
setpath_json "product" "linkProtectionTrustedDomains" '["https://open-vsx.org"]'
setpath "product" "releaseNotesUrl" "https://go.microsoft.com/fwlink/?LinkID=533483#vscode"
setpath "product" "reportIssueUrl" "https://github.com/Alex313031/codium/issues/new"
setpath "product" "requestFeatureUrl" "https://go.microsoft.com/fwlink/?LinkID=533482"
setpath "product" "tipsAndTricksUrl" "https://go.microsoft.com/fwlink/?linkid=852118"
setpath "product" "twitterUrl" "https://go.microsoft.com/fwlink/?LinkID=533687"
setpath "product" "downloadUrl" "https://github.com/Alex313031/codium/releases"

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "product" "nameShort" "Codium Dev"
  setpath "product" "nameLong" "Codium Dev"
  setpath "product" "applicationName" "codium-dev"
  setpath "product" "dataFolderName" "._codium-dev"
  setpath "product" "linuxIconName" "codium-dev"
  setpath "product" "quality" "insider"
  setpath "product" "urlProtocol" "codium-dev"
  setpath "product" "serverApplicationName" "codium-server-dev"
  setpath "product" "serverDataFolderName" ".codium-server-dev"
  setpath "product" "tunnelApplicationName" "codium-tunnel-dev"
  setpath "product" "darwinBundleIdentifier" "com.alex313031.codiumdev"
  setpath "product" "win32AppUserModelId" "Codium.CodiumDev"
  setpath "product" "win32DirName" "Codium Dev"
  setpath "product" "win32MutexName" "codiumdev"
  setpath "product" "win32NameVersion" "Codium Dev"
  setpath "product" "win32RegValueName" "Codium Dev"
  setpath "product" "win32ShellNameShort" "Codium Dev"
  setpath "product" "win32TunnelServiceMutex" "codiumdev-tunnelservice"
  setpath "product" "win32TunnelMutex" "codiumdev-tunnel"
  setpath "product" "win32AppId" "{{FF66572E-3BFA-406A-9247-49B3B29C0235}"
  setpath "product" "win32x64AppId" "{{D9013DD5-DAB5-4B56-BB7B-C9CD34AE28E9}"
  setpath "product" "win32arm64AppId" "{{22AF8398-CAFC-40FE-91F7-AFACE6105057}"
  setpath "product" "win32UserAppId" "{{89E649C8-2300-440A-9E8C-18E3FFEE1B60}"
  setpath "product" "win32x64UserAppId" "{{C0E31517-6820-4DD9-A303-A2DAE3C5EFFB}"
  setpath "product" "win32arm64UserAppId" "{{9F98CAFB-54D9-47BB-A295-340C8D3DF753}"
else
  setpath "product" "nameShort" "Codium"
  setpath "product" "nameLong" "Codium"
  setpath "product" "applicationName" "codium"
  setpath "product" "dataFolderName" "._codium"
  setpath "product" "linuxIconName" "codium"
  setpath "product" "quality" "stable"
  setpath "product" "urlProtocol" "codium"
  setpath "product" "serverApplicationName" "codium-server"
  setpath "product" "serverDataFolderName" ".codium-server"
  setpath "product" "tunnelApplicationName" "codium-tunnel"
  setpath "product" "darwinBundleIdentifier" "com.alex313031.codium"
  setpath "product" "win32AppUserModelId" "Codium.Codium"
  setpath "product" "win32DirName" "Codium"
  setpath "product" "win32MutexName" "codium"
  setpath "product" "win32NameVersion" "Codium"
  setpath "product" "win32RegValueName" "Codium"
  setpath "product" "win32ShellNameShort" "Codium"
  setpath "product" "win32TunnelServiceMutex" "codium-tunnelservice"
  setpath "product" "win32TunnelMutex" "codium-tunnel"
  setpath "product" "win32AppId" "{{E06CEA83-8581-4A27-87AE-E091220B1B7F}"
  setpath "product" "win32x64AppId" "{{6E030886-1BE5-432A-9BD0-15B8C7966EDA}"
  setpath "product" "win32arm64AppId" "{{23C4EC3E-539B-495B-B6BB-2D72A0C7D097}"
  setpath "product" "win32UserAppId" "{{0CFA8296-CF1C-44A7-A880-4C6FFC8DF729}"
  setpath "product" "win32x64UserAppId" "{{D472FFAB-F74B-44BD-85D4-04490D2DE4A7}"
  setpath "product" "win32arm64UserAppId" "{{1E3CC560-C675-4ED4-97A8-48A7AA27B090}"
fi

jsonTmp=$( jq -s '.[0] * .[1]' product.json ../product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

cat product.json

# package.json
cp package.json{,.bak}

setpath "package" "version" "$( echo "${RELEASE_VERSION}" | sed -n -E "s/^(.*)\.([0-9]+)(-insider)?$/\1/p" )"
setpath "package" "release" "$( echo "${RELEASE_VERSION}" | sed -n -E "s/^(.*)\.([0-9]+)(-insider)?$/\2/p" )"

replace 's|Microsoft Corporation|Alex313031|' package.json

# announcements
replace "s|\\[\\/\\* BUILTIN_ANNOUNCEMENTS \\*\\/\\]|$( tr -d '\n' < ../announcements-builtin.json )|" src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts

../undo_telemetry.sh

replace 's|Microsoft Corporation|Codium|' build/lib/electron.js
replace 's|Microsoft Corporation|Codium|' build/lib/electron.ts
replace 's|([0-9]) Microsoft|\1 Codium|' build/lib/electron.js
replace 's|([0-9]) Microsoft|\1 Codium|' build/lib/electron.ts

if [[ "${OS_NAME}" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to codium
  # we need to edit a line in the post install template
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i "s/code-oss/codium-dev/" resources/linux/debian/postinst.template
  else
    sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template
  fi

  # fix the packages metadata
  # code.appdata.xml
  sed -i 's|Visual Studio Code|Codium|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/Alex313031/codium#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://github.com/Alex313031/codium/blob/master/Logo.png|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://github.com/Alex313031/codium#readme|' resources/linux/code.appdata.xml

  # control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|Alex313031 <alex313031@gmail.com>|'  resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://github.com/Alex313031/codium#readme|' resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|Codium|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/Alex313031/codium#download-install|' resources/linux/debian/control.template

  # code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/Alex313031/codium#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|Microsoft Corporation|Alex313031|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|Alex313031 <alex313031@gmail.com>|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://github.com/Alex313031/codium#readme|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|Codium|' resources/linux/rpm/code.spec.template

  # snapcraft.yaml
  sed -i 's|Visual Studio Code|Codium|'  resources/linux/rpm/code.spec.template
elif [[ "${OS_NAME}" == "windows" ]]; then
  # code.iss
  sed -i 's|https://code.visualstudio.com|https://github.com/Alex313031/codium|' build/win32/code.iss
  sed -i 's|Microsoft Corporation|Alex313031|' build/win32/code.iss
fi

cd ..
