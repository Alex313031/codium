#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

# git workaround
if [[ "${CI_BUILD}" != "no" ]]; then
  git config --global --add safe.directory "/__w/$( echo "${GITHUB_REPOSITORY}" | awk '{print tolower($0)}' )"
fi

if [[ -z "${RELEASE_VERSION}" ]]; then
  if [[ "${VSCODE_LATEST}" == "yes" ]] || [[ ! -f "${VSCODE_QUALITY}.json" ]]; then
    UPDATE_INFO=$( curl --silent --fail "https://update.code.visualstudio.com/api/update/win32/${VSCODE_QUALITY}/0000000000000000000000000000000000000000" )
  else
    MS_COMMIT=$( jq -r '.commit' "${VSCODE_QUALITY}.json" )
    MS_TAG=$( jq -r '.tag' "${VSCODE_QUALITY}.json" )
  fi

  if [[ -z "${MS_COMMIT}" ]]; then
    MS_COMMIT="1a5daa3a0231a0fbba4f14db7ec463cf99d7768e"
    MS_TAG="1.84.2"

    if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
      MS_TAG="1.84.2"
    fi
  fi

  date=$( date +%Y%j )

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    RELEASE_VERSION="${MS_TAG}.${date: -5}-insider"
  else
    RELEASE_VERSION="${MS_TAG}.${date: -5}"
  fi
else
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+-insider$ ]];
    then
      MS_TAG="1.84.2"
    else
      echo "Error: Bad RELEASE_VERSION: ${RELEASE_VERSION}"
      exit 1
    fi
  else
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+$ ]];
    then
      MS_TAG="1.84.2"
    else
      echo "Error: Bad RELEASE_VERSION: ${RELEASE_VERSION}"
      exit 1
    fi
  fi

  if [[ "${MS_TAG}" == "$( jq -r '.tag' "${VSCODE_QUALITY}".json )" ]]; then
    MS_COMMIT=$( jq -r '.commit' "${VSCODE_QUALITY}".json )
  else
    echo "Error: No MS_COMMIT for ${RELEASE_VERSION}"
    exit 1
  fi
fi

echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""

mkdir -p vscode
cd vscode || { echo "'vscode' dir not found"; exit 1; }

git init -q
git remote add origin https://github.com/Microsoft/vscode.git

# figure out latest tag by calling MS update API
if [[ -z "${MS_TAG}" ]]; then
  UPDATE_INFO=$( curl --silent --fail "https://update.code.visualstudio.com/api/update/win32/${VSCODE_QUALITY}/0000000000000000000000000000000000000000" )
  MS_COMMIT="1a5daa3a0231a0fbba4f14db7ec463cf99d7768e"
  MS_TAG="1.84.2"
elif [[ -z "${MS_COMMIT}" ]]; then
  REFERENCE=$( git ls-remote --tags | grep -x ".*refs\/tags\/${MS_TAG}" | head -1 )

  if [[ -z "${REFERENCE}" ]]; then
    echo "Error: The following tag can't be found: ${MS_TAG}"
    exit 1
  elif [[ "${REFERENCE}" =~ ^([[:alnum:]]+)[[:space:]]+refs\/tags\/([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    MS_COMMIT="1a5daa3a0231a0fbba4f14db7ec463cf99d7768e"
    MS_TAG="1.84.2"
  else
    echo "Error: The following reference can't be parsed: ${REFERENCE}"
    exit 1
  fi
fi

echo "MS_TAG=\"${MS_TAG}\""
echo "MS_COMMIT=\"${MS_COMMIT}\""

git fetch --depth 1 origin "${MS_COMMIT}"
git checkout FETCH_HEAD

cd ..

# for GH actions
if [[ "${GITHUB_ENV}" ]]; then
  echo "MS_TAG=${MS_TAG}" >> "${GITHUB_ENV}"
  echo "MS_COMMIT=${MS_COMMIT}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
fi

export MS_TAG
export MS_COMMIT
export RELEASE_VERSION

echo "MS_TAG=\"${MS_TAG}\"" > build.env
echo "MS_COMMIT=\"${MS_COMMIT}\"" >> build.env
echo "RELEASE_VERSION=\"${RELEASE_VERSION}\"" >> build.env
