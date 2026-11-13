<table>
  <tr>
    <td width="20%">
      <img src="assets/icon/app/round.png"/>
    </td>
    <td width="80%">
      <h1>e1547</h1>
      <h4>A sophisticated e621 browser</h4>
      <a href="README.zh-CN.md"><img src="https://img.shields.io/badge/README-简体中文-orange" alt="简体中文"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/commits/master"><img src="https://img.shields.io/github/commit-activity/m/purrfecto114-lgtm/e1547_plus"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/commits/master"><img src="https://img.shields.io/github/last-commit/purrfecto114-lgtm/e1547_plus"></a>
      <a href="blob/master/LICENSE"><img src="https://img.shields.io/github/license/purrfecto114-lgtm/e1547_plus"></a>
      <a href="https://github.com/purrfecto114-lgtm/e1547_plus/releases"><img src="https://img.shields.io/github/downloads/purrfecto114-lgtm/e1547_plus/total"></a>
    </td>
  </tr>
</table>

## About this fork

This repository is a fork of [e1547](https://github.com/clynamic/e1547) (GPL-3.0), maintained with a focus on stability on Android 7 and other low memory devices. It rebases on upstream 21.1.1 and carries its own `21.2.x` and newer release line — every change is listed per release in the [changelog](CHANGELOG.md).

On top of upstream, this fork ships:

- a stability batch for Android 7 and low memory devices — sized image caches, a video player pool capped by device memory, guarded cache database access and memory-adaptive defaults
- a security batch — database exports stripped of saved logins and optionally AES-256-GCM protected (with a password prompt on import), hardened imports, a locked-down cookie webview, database files excluded from OS backups, request timeouts, a salted PBKDF2 app pin with a persisted backoff against guessing, and a biometric lock that works on Android 7's fingerprint API

The fork's changes are offered back upstream as pull requests ([#190](https://github.com/clynamic/e1547/pull/190)–[#193](https://github.com/clynamic/e1547/pull/193)).

The in-app updater checks this repository for new versions; since the fork is signed with its own key, it cannot be installed over the official release — see [Upgrading](#upgrading) below.

## Features

- Crossplatform (Android, iOS, Windows, Linux)
- Browse, edit and comment on posts, and browse pools
- Download images with mid-transfer cancellation; favorite and vote posts
- Follow tags with notifications, and a local blacklist
- DText parsing, and video support with a quality picker and on-demand loading
- Multiple logins and app themes
- Multilingual interface — thirteen languages, plus offline tag dictionaries (around 4000 simplified chinese descriptions with a traditional rendering, around 370 japanese)
- Language and media quality selection during onboarding and in the settings
- PIN and biometric device locks, with the system's screenshot blocker over the app switcher (off by default, in the settings)
- Password-protected database exports (AES-256-GCM), with a password prompt on import
- An incognito keyboard mode, and an 18+ age confirmation before logging in
- Stable cursor pagination with a page footer and page jumping
- Search filters for special search terms (order, rating, file type…), with metatag autocomplete grouped into labeled sections

### Desktop notes

The desktop builds are compiled from the same code but are the younger siblings; known gaps, in rough order of impact:

- **Cloudflare challenges cannot be solved on desktop** — the cookie webview is mobile only, so desktop users can only retry and wait.
- **No screen capture protection on Windows/Linux** — the secure display setting hides itself there (Windows has a native equivalent, not yet wired up).
- **No background sync or notifications on desktop** — follow updates refresh while the app is open only.
- **The updater opens the releases page** on desktop, filtered by platform, instead of downloading in place.

Everything else — browsing, videos, the adaptive wide window layout, database import and export, the full interface — behaves the same as on mobile.

## Localization

The interface is available in thirteen languages, selectable on the first-launch welcome screen or in the settings at any time. Japanese and Russian have had a native review pass; Korean, Italian, Polish and Vietnamese are machine translated, not yet reviewed by native speakers.

To add another language, create an `app_<locale>.arb` file in `lib/l10n` with translations for every key of `app_en.arb`, add the language to `appLanguages` in `lib/settings/data/language.dart`, and run `flutter gen-l10n`.

## Screenshots

<p align="center">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png" width="30%">
  <img src="fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png" width="30%">
</p>

## Download

APK, IPA, Windows and Linux packages can be found over at the [releases](https://github.com/purrfecto114-lgtm/e1547_plus/releases) page. Stable releases are marked "latest"; `rc` pre-releases track work in progress and install over previous rc builds of the same cycle. Updates can be managed with [obtainium](https://github.com/ImranR98/Obtainium), with https://github.com/purrfecto114-lgtm/e1547_plus/releases/ as the app source.

### Certificate Fingerprints

To verify the authenticity of downloaded APK files, check the signing certificate fingerprints:

- **SHA1:** `29:85:3D:AC:C5:EC:58:A2:7F:2B:AC:8D:C0:E7:5A:A6:67:7C:91:73`
- **SHA256:** `10:71:32:BE:71:8B:99:BC:04:1B:0C:56:85:49:BB:89:26:3B:87:92:4F:67:97:FE:07:0E:F4:E0:90:E5:9F:B9`

via a tool like [AppVerifier](https://github.com/soupslurpr/AppVerifier).

## Installation

### Installing on Android

Requires Android 7.0 or newer.

1. Download the [latest APK](https://github.com/purrfecto114-lgtm/e1547_plus/releases)
2. Open it on your Android device with a file manager
3. Click install

#### Which APK should I download?

- Phone with 64 bit support (almost all phones from 2016 onwards) -> `e1547-arm64.apk`
- 32 bit only phone -> `e1547-armv7.apk`
- Doesn't work? -> `e1547-universal.apk`

Prefer the arm64 build whenever your device supports it: 32 bit processes have a much smaller memory limit, which makes the app far more likely to be killed by the OS on old, low memory devices.

### Installing on iOS

The app is not available in the AppStore — follow the instructions on [Sideloadly](https://sideloadly.io/), or jailbreak your device and install the [IPA](https://github.com/purrfecto114-lgtm/e1547_plus/releases) directly.

### Upgrading

Updates within this fork install right over older fork releases. Coming from the official release or another differently-signed build, Android will refuse to install over it — export your database from the old app's settings first, uninstall it, install this build and import the database again.

## Compilation

1. Install [Flutter](https://flutter.dev/docs/get-started/install) 3.44.9 or newer (stable)
2. Clone this github repository
3. Run `flutter build <file>` where `<file>` is either `apk` or `ipa`

Building the desktop packages additionally needs `fastlane` (see `.github/workflows/deployment.yml` for per-platform requirements, like InnoSetup on Windows or the GTK and mpv development libraries on Linux).

## Community

Bugs and feature requests for this fork belong in its [issue tracker](https://github.com/purrfecto114-lgtm/e1547_plus/issues); the upstream project keeps a [Discord server](https://discord.gg/MRwKGqfmUz) for the app itself.

## Credit

Based on [e1547](https://github.com/clynamic/e1547) by clragon and [clynamic](https://clynamic.net), originally written by [Perlatus](https://github.com/perlatus), with performance optimisations by [Miyoyo](https://github.com/miyoyo) and contributions from many others. The Chinese offline tag descriptions incorporate the community dictionary of the [e621 标签汉化&中文搜索](https://sleazyfork.org/en/scripts/554343) userscript by jcjyids (GPL-3.0-or-later).

This fork is maintained for Android 7 and low memory stability.
