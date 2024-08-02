<div id="vscodium-logo" align="center">
    <br />
    <img src="./Logo.png" alt="VSCodium Logo" width="200"/>
    <h1>Codium</h1>
    <h3>Free/Libre Open Source Software Binaries of <a rel="noopener" target="_blank" href="https://github.com/microsoft/vscode">VS Code</a> - Compiler optimized fork of <a rel="noopener" target="_blank" href="https://github.com/VSCodium/vscodium">VSCodium</a></h3>
</div>

<div id="badges" align="center">

[![current release](https://img.shields.io/github/release/Alex313031/codium.svg)](https://github.com/Alex313031/codium/releases)
[![license](https://img.shields.io/github/license/Alex313031/codium.svg)](https://github.com/Alex313031/codium/blob/master/LICENSE)

</div>

__This is a fork of <a rel="noopener" target="_blank" href="https://github.com/VSCodium/vscodium">VSCodium</a> with compiler optimizations, rebranding as "Codium", restoration of the upstream icon, and *RESTORED WINDOWS 7/8/8.1 Support!*. It also supports Ubuntu 18.04/Debian 9.__

## Table of Contents

- [Download/Install](#download-install)
- [Building](#build)
- [Why Does This Exist](#why)
- [More Info](#more-info)
- [Supported Platforms](#supported-platforms)

## <a id="download-install"></a>Download/Install

:tada: :tada:
Download latest release in the releases section > https://github.com/Alex313031/codium/releases
:tada: :tada:

[More info / helpful tips are here.](https://github.com/Alex313031/codium/blob/master/docs/index.md)

Any issues installing Codium using your package manager should be directed to that repository's issue tracker.

## <a id="build"></a>Building

Build instructions can be found [here](https://github.com/Alex313031/codium/blob/master/docs/howto-build.md)

## <a id="why"></a>Why Does This Exist

This repository contains build files to generate free release binaries of Microsoft's VS Code. When we speak of "free software", we're talking about freedom, not price.

Microsoft's releases of Visual Studio Code are licensed under [this not-FLOSS license](https://code.visualstudio.com/license) and contain telemetry/tracking. According to [this comment](https://github.com/Microsoft/vscode/issues/60#issuecomment-161792005) from a Visual Studio Code maintainer:

> When we [Microsoft] build Visual Studio Code, we do exactly this. We clone the vscode repository, we lay down a customized product.json that has Microsoft specific functionality (telemetry, gallery, logo, etc.), and then produce a build that we release under our license.
>
> When you clone and build from the vscode repo, none of these endpoints are configured in the default product.json. Therefore, you generate a "clean" build, without the Microsoft customizations, which is by default licensed under the MIT license

This repo exists so that you don't have to download+build from source. The build scripts in this repo clone Microsoft's vscode repo, run the build commands, and upload the resulting binaries to [GitHub releases](https://github.com/Alex313031/codium/releases). __These binaries are licensed under the MIT license. Telemetry is disabled.__

If you want to build from source yourself, head over to [Microsoft's vscode repo](https://github.com/Microsoft/vscode) and follow their [instructions](https://github.com/Microsoft/vscode/wiki/How-to-Contribute#build-and-run). This repo exists to make it easier to get the latest version of MIT-licensed VS Code.

Microsoft's build process (which we are running to build the binaries) does download additional files. Those packages downloaded during build are:

- Pre-built extensions from the GitHub:
  - [ms-vscode.js-debug-companion](https://github.com/microsoft/vscode-js-debug-companion)
  - [ms-vscode.js-debug](https://github.com/microsoft/vscode-js-debug)
  - [ms-vscode.vscode-js-profile-table](https://github.com/microsoft/vscode-js-profile-visualizer)
- From [Electron releases](https://github.com/electron/electron/releases) (using [vscode-gulp-electron](https://github.com/Alex313031/vscode-gulp-electron))
  - electron
  - ffmpeg

## <a id="more-info"></a>More Info

### Documentation

For more information on getting all the telemetry disabled, tips for migrating from Visual Studio Code to Codium and more, have a look at [the Docs page](https://github.com/Alex313031/codium/blob/master/docs/index.md) page.

### Troubleshooting

If you have any issue, please check [the Troubleshooting page](https://github.com/Alex313031/codium/blob/master/docs/troubleshooting.md) or the existing issues.

### Extensions and the Marketplace

According to the VS Code Marketplace [Terms of Use](https://aka.ms/vsmarketplace-ToU), _you may only install and use Marketplace Offerings with Visual Studio Products and Services._ For this reason, Codium uses [open-vsx.org](https://open-vsx.org/), an open source registry for VS Code extensions. See the [Extensions + Marketplace](https://github.com/Alex313031/codium/blob/master/docs/index.md#extensions-marketplace) section on the Docs page for more details.

Please note that some Visual Studio Code extensions have licenses that restrict their use to the official Visual Studio Code builds and therefore do not work with Codium. See [this note](https://github.com/Alex313031/codium/blob/master/docs/index.md#proprietary-debugging-tools) on the Docs page for what's been found so far and possible workarounds.

### How are the Codium binaries built?

If you would like to see the commands we run to build `vscode` into Codium binaries, have a look at the workflow files in `.github/workflows` for Windows, GNU/Linux and macOS. These build files call all the other scripts in the repo. If you find something that doesn't make sense, feel free to ask about it in an issue or in [the discussions](https://github.com/Alex313031/codium/discussions).

The builds are run every day, but exit early if there isn't a new release from Microsoft.

## <a id="supported-platforms"></a>Supported Platforms

The minimal version is limited by the core component Electron, you may want to check its [platform prerequisites](https://www.electronjs.org/docs/latest/development/build-instructions-gn#platform-prerequisites).
- [x] macOS (`zip`, `dmg`) OS X 10.13 or newer x64
- [x] macOS (`zip`, `dmg`) macOS 11.0 or newer arm64
- [x] GNU/Linux x64 (`deb`, `rpm`, `AppImage`, `tar.gz`)
- [x] GNU/Linux arm64 (`deb`, `rpm`, `tar.gz`)
- [x] Windows 7 or newer x64
- [x] Windows 7 or newer x86
- [x] Windows Server 2012 R2 or newer arm64

## <a id="license"></a>License

[MIT](https://github.com/Alex313031/codium/blob/master/LICENSE.md)
