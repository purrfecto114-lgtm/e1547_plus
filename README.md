<table>
  <tr>
    <td width="20%">
      <img src="assets/icon/app/round.png"/>
    </td>
    <td width="80%">
      <h1>e1547</h1>
      <h4>A sophisticated e621 browser</h4>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/commits/master"><img src="https://img.shields.io/github/commit-activity/m/purrfecto114-lgtm/e1547_plus"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/commits/master"><img src="https://img.shields.io/github/last-commit/purrfecto114-lgtm/e1547_plus"></a>
      <a href="blob/master/LICENSE"><img src="https://img.shields.io/github/license/purrfecto114-lgtm/e1547_plus"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/releases/latest"><img src="https://img.shields.io/github/downloads/purrfecto114-lgtm/e1547_plus/total"></a>
    </td>
  </tr>
</table>

## About this fork

This repository is a fork of [e1547](https://github.com/clynamic/e1547) (GPL-3.0),
maintained with a focus on stability on Android 7 and other low memory devices.

The app's updater checks this repository for new versions. Since the fork is
signed with its own key, it cannot be installed over the official release —
see [Upgrading](#upgrading) below.

## Features

- Crossplatform (Android, iOS, Windows, Linux)
- Browse posts and pools
- Edit posts
- Comment on posts
- Download images
- Favorite, up and down vote posts
- Follow tags with notifications
- Local blacklist
- DText parsing
- Video support
- Multiple logins
- Multiple app themes
- Multilingual interface (English, 简体中文, 繁體中文, 日本語, Русский)
- Language selection during onboarding and in the settings
- Stable cursor pagination with a page footer and page jumping
- Search filters for special search terms (order, rating, file type and more), with metatag autocomplete in search inputs

## Localization

The app interface is available in English, Simplified and Traditional Chinese, Japanese and Russian, selectable on the first-launch welcome screen or in the settings at any time.

To add another language, create an `app_<locale>.arb` file in `lib/l10n` with translations for every key of `app_en.arb`, add the language to `appLanguages` in `lib/settings/data/language.dart`, and run `flutter gen-l10n` — the language picker and onboarding step pick it up automatically.

## Screenshots

<p align="center">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png" width="30%">
</p>

## Download

APK, IPA, Windows and Linux packages can be found over at
the [releases](https://github.com/purrfecto114-lgtm/e1547_plus/releases/latest).

A great tool for managing updates for this app is [obtainium](https://github.com/ImranR98/Obtainium) (see [Using Obtainium](#Using-Obtainium) for a more detailed guide).

### Certificate Fingerprints

To verify the authenticity of downloaded APK files, you can check the signing certificate fingerprints:

- **SHA1:** `29:85:3D:AC:C5:EC:58:A2:7F:2B:AC:8D:C0:E7:5A:A6:67:7C:91:73`
- **SHA256:** `10:71:32:BE:71:8B:99:BC:04:1B:0C:56:85:49:BB:89:26:3B:87:92:4F:67:97:FE:07:0E:F4:E0:90:E5:9F:B9`

via a tool like [AppVerifier](https://github.com/soupslurpr/AppVerifier).

## Installation

### Installing on Android

Requires Android 7.0 or newer.

1. Download the [latest APK](https://github.com/purrfecto114-lgtm/e1547_plus/releases/latest)
2. Open it on your Android device with a file manager
3. Click install

#### Using Obtainium

1. Install and open obtainium from [F-Droid](https://f-droid.org/en/packages/dev.imranr.obtainium.fdroid/) or from their [Github](https://github.com/ImranR98/Obtainium)
2. Click on "Add app" on the bottom app drawer
3. Paste https://github.com/purrfecto114-lgtm/e1547_plus/releases/ into the "App source URL*" field
4. Hit the add button, next to the App source URL field
5. Hit the install button in the following menu

#### Which APK should I download?

- Phone with 64 bit support (almost all phones from 2016 onwards) -> `e1547-arm64.apk`
- 32 bit only phone -> `e1547-armv7.apk`
- Doesn't work? -> `e1547-universal.apk`

Prefer the arm64 build whenever your device supports it: 32 bit processes
have a much smaller memory limit, which makes the app far more likely to
be killed by the OS on old, low memory devices.

### Installing on iOS

The app is not available in the AppStore.

- Follow the instructions on [Sideloadly](https://sideloadly.io/)

or

- Jailbreak your device and install the [IPA](https://github.com/purrfecto114-lgtm/e1547_plus/releases/latest) directly

### Upgrading

Updates within this fork install right over older fork releases.

Coming from the official release or another build with a different signing
key, Android will refuse to install over it — the app shares its package
name. Export your database from the old app's settings first, uninstall it,
install this build and import the database again.

## Compilation

You can compile the app from source:

1. Install [Flutter](https://flutter.dev/docs/get-started/install) 3.44.9 or newer (stable)
2. Clone this github repository
3. Run `flutter build <file>` where `<file>` is either `apk` or `ipa`

Building the desktop packages additionally needs `fastlane` (see `.github/workflows/deployment.yml`
for the per-platform requirements, like InnoSetup on Windows or the GTK and mpv
development libraries on Linux).

## Community

Bugs and feature requests for this fork belong in its
[issue tracker](https://github.com/purrfecto114-lgtm/e1547_plus/issues).

The upstream project keeps a [Discord server](https://discord.gg/MRwKGqfmUz)
for the app itself.

## Credit

Based on [e1547](https://github.com/clynamic/e1547) by clragon and
[clynamic](https://clynamic.net), originally written by
[Perlatus](https://github.com/perlatus), with performance optimisations by
[Miyoyo](https://github.com/miyoyo) and contributions from many others.

This fork is maintained for Android 7 and low memory stability.
