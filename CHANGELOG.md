# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [21.7.3+131] - 2026-11-13
### Fixed
- tag suggestions complete the word the cursor is on, keep operators and
  repeated tokens straight, and leave the cursor at the end of the
  completed word instead of the end of the whole text; picking a second
  suggestion right after replaces the tag without doubling the closing
  space, and an IME composition region is left alone so lowercase
  submission no longer tramples an unfinished phrase
- the filter prompt keeps a local draft and hands it to the search once
  per debounce window: keystrokes no longer refetch on every key, an
  external change no longer throws away unapplied edits, and closing
  the prompt still applies what was typed
- the post editor and trait editors warn about unsaved changes when
  leaving, and the discard confirmation is localized like the rest of
  the interface
- selections survive content refreshes: picking by stable keys keeps a
  selection through reloads and item updates, the overlay reports its
  toggled state to screen readers, and a batch whose queue refused work
  — a canceled directory prompt or an all-duplicate batch — keeps what
  was picked
- the task list pages through its history: beyond the first page of
  finished tasks, older ones load on scroll instead of becoming
  unreachable, and a page that failed to load can be retried; the task
  page also counts the outcomes of a finished batch separately
- task bubbles announce their progress and outcome to screen readers,
  and an unknown total shows an indeterminate state instead of a fake
  zero; failed tasks are kept for seven days and then swept, with no
  cap on how many a busy day leaves behind
- canceling a running favorite aborts its request on the network, like
  downloads always could, and a file that races its cancellation into
  the gallery is removed again after the export finishes; task queue
  results also reach the post cache reliably, so a finished task no
  longer skips syncing back into it
- Android file names are cleaned of path separators before they reach
  the gallery, matching the desktop behavior
- a racing external change to the denylist no longer rolls back over
  it, and a slow pull no longer overwrites a push that landed first;
  favorites requests stop mutating the caller's query map, and a post
  with an unknown uploader or rating still parses instead of taking
  the whole page down with it
- account availability is rechecked per account, and a page it pushed
  once does not come back for the same account; a login's avatar fetch
  failing no longer takes the whole account pull down with it
- deep links are consumed only after they are dispatched successfully:
  a cold start whose first frame fails no longer loses its link, and
  one link can no longer navigate twice; the F5 key refreshes the route
  it was pressed on, not whichever page sits at the bottom of the stack
- the fullscreen image fallback stops decoding the original file at
  full size: the file path now carries the same decode cap as previews;
  follow thumbnails decode at their tile size, and the search grid
  scales its decode cap with the device pixel ratio
- history entries get an index on their visited time, so ordering and
  trimming no longer scan the whole table; the schema migrates in place
  on upgrade, and history subtitles are truncated to a sensible length
  before they reach the database, cutting at code point boundaries so
  emoji survive
- the light theme's on-primary color passes WCAG AA against the amber
  primary, and interactive dimming is strong enough to read as disabled
- DText links release their tap recognizers when their text is rebuilt:
  scrolling comment lists no longer leaks a recognizer per link, and
  link previews are provided once per page instead of per text
- the Polish translation regains its plural forms: "2–4 posts" reads
  "posty", not "postów", and the counts that were missing a few/many
  branch get one
- a user who declined notification permission is not asked again on
  every cold start, and returning to the foreground rechecks the grant
  instead of assuming it
- hardcoded prompts (discard edits, jump to page, queue failures,
  retry) are localized, and hosts input fields release their controllers
### Changed
- the README was condensed to half its length without losing a section,
  in both languages

## [21.7.2+130] - 2026-11-11
### Fixed
- a staged import can no longer install itself: validation needs the
  user's explicit restart, and a dismissed confirmation dialog or a killed
  process keeps the current database instead
- an interrupted database swap no longer deletes the only remaining copy
  of the old database while retrying
- imported databases get their cascade triggers rebuilt and their file
  cache index emptied, so deleting an identity keeps working and a
  crafted cache row can no longer point the cleaner outside the cache
  directory
- media downloads travel without the account's credentials: images and
  thumbnails from other hosts never receive the API key or cookies
- the export reports a failed snapshot instead of quietly copying a
  possibly incomplete database file
- the history dedup window is per identity: another account's visit no
  longer swallows this one's entry
- turning the pin off also turns the biometric lock off, so a failing
  sensor can no longer lock the user out with no way back in
- the app no longer wraps its whole interface in ExcludeSemantics, so
  screen readers can see and operate it again
- a login now verifies its credentials against its host before saving
  them: a key the server rejects no longer appears as a signed-in
  account until a favorite or vote exposes it, and an unreachable host
  keeps the form open for a retry
- opening a follow notification acts on the identity that created it:
  the app switches accounts when needed and reports a removed identity
  instead of loading the post with whichever account happens to be
  active
- an Android cold start deep link is handled once: the initial link
  that both deep link entry points report no longer races into
  duplicate navigation
- searches and pools no longer end early when every post on a page is
  client-hidden (flash or fileless entries): pagination advances on the
  raw response while display filtering keeps its own rules
- iOS gallery saves check the plugin's success flag and run one at a
  time: a save Photos rejected no longer completes its task, and
  overlapping saves can no longer swallow each other's callbacks
- cancelling a save no longer deletes a file it did not create:
  overwriting an existing name is not rollback-safe, so only freshly
  created files are removed on rollback
- switching accounts or leaving the app no longer lets an older
  activation overwrite the newer account: superseded results are
  dropped
- a failed optimistic update restores the state it started from
  instead of rolling the whole item back over later successful
  updates, and mutations of the same item now run in order instead of
  interleaving
- DText link previews remove their overlay again when the underlying
  content goes away, instead of leaking on top of the app
- imported databases arrive with their pending and running tasks
  canceled: another device's download queue no longer resumes as
  executable todos on a fresh install
- database exports strip every identity header outside an explicit
  allowlist, so legacy top-level cookie headers (cloudflare clearance
  and bot-manager markers) no longer travel through backups
- request logs scrub sensitive query parameters structurally before an
  event is built: decoded tag queries with spaces can no longer smuggle
  a following secret past the redaction
- the Linux package recommends the xdg desktop portal services its
  file dialogs go through, so a minimal install can no longer start
  fine and fail at its first file dialog

### Changed
- pull-to-refresh and the optimistic mutations now report failures that
  cached_query had swallowed into the query state; the refresh indicator
  shows the failed state while offline
- the Chinese readme's secure display description now matches what the
  app actually does (FLAG_SECURE on Android, the native blur on iOS)
- the unencrypted desktop database export streams the snapshot to the
  picked file instead of buffering the whole database, the import
  probes the encryption magic from the first bytes instead of reading
  the picked file whole, and digests stream their input
- the file cache keeps a byte budget next to its entry count: the
  least recently touched entries are given up first, and entries
  without a known length count as zero
- the Ruby toolchain updates the gems with published fixes for seven
  OSV advisories; the two that need a fastlane major upgrade (excon,
  rubyzip) are recorded as a reviewed baseline, and the validation
  workflow scans the locked dependencies against OSV on every run
- the release workflow runs the reusable validation against the exact
  ref it packages, pins its actions to commit hashes, verifies the
  downloaded forum converter by checksum, enforces the committed
  lockfiles, and separates the unauthenticated conversion from the
  publishing steps

## [21.7.1+129] - 2026-11-08
### Changed
- the torn photo placeholder follows the monochrome outlined icon
  language now: a hard coded red badge no longer fights the themed icon
  row, the torn halves visibly slide apart with ragged stroked edges,
  the mountain ridge is drawn stroked like Material's image glyphs, and
  the exclamation badge is a knocked out glyph in the icon color the way
  Material composes badges

## [21.7.0+128] - 2026-11-08
### Added
- the failed image placeholder is a torn photo with an exclamation badge
  now, which stays readable at thumbnail sizes and no longer looks like a
  loading glitch

### Changed
- the biometric lock demands a pin first, so a failing sensor always
  leaves a way back into the app
- the app re-locks itself when it returns from a real absence in the
  background, and pauses playing videos underneath the lock
- empty states, the status filter and several unnamed buttons carry
  clearer icons and labels, and the onboarding steps show a scroll thumb

### Fixed
- a release tag that is not a version can no longer break the update
  check
- the database import progress dialog ignores the system back gesture
  while it works
- deleted posts without files render the placeholder instead of crashing
  the grid
- long video durations and large text scales no longer overflow the
  player bar, and a loaded video can be seeked before its first step
- the autocomplete cutout follows the fab to the left for left handed
  users
- the desktop escape key no longer pops routes hidden underneath the lock
  screen

## [21.6.0+127] - 2026-11-07
### Added
- the app pin is stored as a salted PBKDF2 hash instead of plain text, and
  existing plain text pins upgrade themselves on the next successful unlock
- consecutive wrong pins feed a persisted backoff that waits from the third
  attempt onwards; restarting the app does not reset the wait

### Changed
- the pin and export key derivations run on a background isolate, so
  unlocking, exporting and importing no longer freeze the interface on
  older phones

### Fixed
- a corrupted or forged pin record can no longer verify any pin in release
  builds
- a biometric success clears the pin backoff, and a device clock set
  backwards cannot stretch a cooldown beyond its cap
- the theme onboarding step scrolls instead of overflowing on short and
  landscape screens
- the pin keypad shrinks as a whole on landscape phones instead of folding
  its lower rows behind the scroll, and long cooldown messages stay inside
  the reserved status line
- the update checker filters desktop release assets again, so windows and
  linux no longer light up for releases without usable binaries
- the minimum android version is pinned to 7, the version the fork verifies
  its behavior against

## [21.5.0+126] - 2026-11-07
### Added
- korean, italian, polish and vietnamese translations of the whole interface,
  with plural forms following each language's own rules
- a quality step in onboarding, picking the video and thumbnail tiers before
  the first search
- the preferred hand picker explains and previews where quick actions land,
  in every language

### Changed
- the onboarding welcome and language pages merge into one: the introduction
  cross-fades through the languages as they are chosen, a compact chip grid
  carries the languages with a scrollbar standing by, and an app icon
  entrance animation eases it in
- the settings page split into one widget per section; every section header
  sits at the list edge, and video quality lives under appearance next to the
  thumbnail quality where users look for it
- video quality and tile size collapse into shared low, medium and high
  tiers; stored values migrate onto their nearest tier once, and the tier
  sizes space themselves so every tier changes the column count on phones
  where the old ladder put two tiers onto the same grid
- the posts filter leads with media specs over content attributes: what a
  post is made of narrows a search faster than what it depicts
- the PIN lock screen is redesigned: a small lock glyph, secret dots that
  fill in inside reserved rows so entering digits never shifts the keypad, an
  error line that spells itself out with a shake, haptic keys whose disabled
  state keeps the keypad silhouette, and a cancel action pinned below the
  content on short screens
- secure display returns to the upstream approach: FLAG_SECURE, a window
  flag every android release supports without any permission, hides the app's
  content from screenshots and the app switcher
- the settings enum pickers and the grid density picker share one dialog, and
  a pass of dead code left by the feature churn went away with it

### Fixed
- biometric unlock works on android: the manifest declares USE_BIOMETRIC and
  the deprecated USE_FINGERPRINT for android 7, the lock explains its three
  states (absent hardware, hardware without an enrolled print, usable lock),
  a direct FingerprintManagerCompat probe rescues devices whose plugin probe
  reports "no biometrics" while the reader holds enrolled prints, and a stale
  prompt cancellation or driver level error fails closed into the retry path
  instead of sticking the lock screen
- the incognito keyboard also switches text fields to a password style
  keyboard, which older keyboards that ignore the no-learning flag still
  respect
- the preference migrations (muted videos, quality tiers) now run in
  production; they had only ever run in tests, letting old resolution names
  collide with new tiers
- a failed thumbnail shows a dedicated broken-image glyph instead of the
  generic warning exclamation
- installing an import keeps the previous database as one recoverable
  app.db.bak generation (kept out of cloud and device-transfer backups on
  android, and out of ios backups), stale journals follow it aside, and a
  failed swap restores it instead of leaving no database
- a staged database import is stamped with the hash of its validated file and
  only that candidate is adopted at the next start; imports whose tables miss
  columns, or that smuggle triggers in, are rejected, and the sanitizer
  disarms those triggers before stripping the credentials
- downloads no longer leave their temporary files behind once the export
  consumed them, and a cancellation that raced the export removes the copy it
  actually wrote - on android through saf too - instead of guessing a path
- the export snapshot flushes the wal before its plain-copy fallback, so a
  fresh export cannot miss the newest committed rows
- a failed wiki request no longer covers up the offline tag description that
  was already available
- switching the video quality while every player slot is taken keeps the
  position and playing state through the retry instead of restarting
- the update dialog's cancel button closes the dialog again: it used to check
  the settings route instead of the dialog itself and swallowed the press
- the section headers of the settings page and the history drawer align with
  their lists again instead of drifting toward the center
- releases refuse to build when the signing secrets are missing instead of
  generating an ad-hoc keystore that could never receive an update

## [21.5.0-rc.3+125] - 2026-11-07
### Changed
- the onboarding language step lays its languages out as a compact chip grid
  with a scrollbar standing by, instead of a tall list that hid most of them
  behind the bottom bar
- the thumbnail tier is titled "thumbnail quality" in the onboarding step and
  the appearance settings, no longer borrowing the grid density's title
- the pin screen greets with a small lock glyph and pins its cancel action
  below the content, instead of an oversized badge that pushed the keypad and
  the cancel off short screens
- secure display returned to the upstream approach: FLAG_SECURE, a window
  flag every android release supports without any permission, hides the app's
  content from screenshots and the app switcher again - the previous native
  cover raced the switcher screenshot and lost on android 7

### Fixed
- the biometric lock explains three states (absent hardware, hardware without
  an enrolled print, usable lock) and rescues devices whose plugin probe
  reports "no biometrics" while the fingerprint reader holds enrolled prints:
  a direct FingerprintManagerCompat probe backs the availability check up on
  android
- a failed thumbnail shows a dedicated broken-image glyph instead of the
  generic warning exclamation
- installing an import keeps the previous database as one recoverable
  app.db.bak generation (kept out of cloud and device-transfer backups on
  android, and out of ios backups), stale journals follow it aside, and a
  failed swap restores it instead of leaving no database
- releases refuse to build when the signing secrets are missing instead of
  generating an ad-hoc keystore that could never receive an update

## [21.5.0-rc.2+124] - 2026-11-07
### Changed
- the PIN entry screen is redesigned: a themed badge, secret dots that fill in as
  digits arrive and shake with an error message that spells itself out, a
  circular keypad with haptics, a backspace key and an optional biometric
  shortcut; the third party lock sheet left the codebase with it

### Fixed
- secure display keeps its promise again: leaving the app shows a dedicated,
  themed shield card in the app switcher instead of the system's generic
  warning placeholder, and the app's content itself stays untouched; the
  previous cover raced the screenshot and lost on android 7, so the cover now
  flips natively on the user-leave hook, before the snapshot is taken
- a failed wiki request no longer covers up the offline tag description that
  was already available
- downloads no longer leave their temporary files behind once the export
  consumed them, and a cancellation that raced the export removes the copy it
  actually wrote - on android through saf too - instead of guessing a path
- a staged database import is stamped with the hash of its validated file and
  only that candidate is adopted at the next start; imports whose tables miss
  columns, or that smuggle triggers in, are rejected, and the sanitizer
  disarms those triggers before stripping the credentials
- switching the video quality while every player slot is taken keeps the
  position and playing state through the retry instead of restarting
- the export snapshot flushes the wal before its plain-copy fallback, so a
  fresh export cannot miss the newest committed rows

## [21.5.0-rc.1+123] - 2026-11-07
### Added
- korean, italian, polish and vietnamese translations of the whole interface, with plural forms following each language's own rules
- a quality step in onboarding, picking the video and thumbnail tiers before the first search
- the preferred hand picker explains and previews where quick actions land, in every language

### Changed
- the posts filter leads with media specs over content attributes: what a post is made of narrows a search faster than what it depicts
- video quality and tile size collapse into shared low, medium and high tiers; stored values migrate onto their nearest tier once
- the onboarding welcome and language pages merge into one: the introduction cross-fades through the languages as they are chosen, and an app icon entrance animation eases it in
- the PIN lock screen gained a lock glyph, themed keypad buttons and matching secret dots
- secure display draws a dedicated privacy cover over the app switcher on android, replacing the generic placeholder ROMs show for flag-secured windows; screenshot blocking on android is traded away for it, ios keeps its native blur
- the settings page split into one widget per section, and the database export and import share one porter for their drift, staging and password plumbing

### Fixed
- biometric unlock works on android: the manifest now declares the USE_BIOMETRIC permission, and android 7 fingerprints additionally need the deprecated USE_FINGERPRINT one; a device without enrolled biometrics spells that out under its dead toggle
- the incognito keyboard also switches text fields to a password style keyboard, which older keyboards that ignore the no-learning flag still respect
- the preference migrations (muted videos, quality tiers) now run in production; they had only ever run in tests, letting old resolution names collide with new tiers
- a database import that fails after validation drops its staged file again, so an error message can no longer coexist with a candidate the next boot silently adopts
## [21.4.0+122] - 2026-11-07
### Added
- the context drawer button lights up while the loaded pages hold blacklisted posts, putting the denylist switch one tap away
- a "receive the latest updates" switch in the development settings; on, update checks also offer prerelease versions, and debug builds can exercise the updater
- a page jump in the posts context drawer, reachable no matter where the list footer has scrolled to
- a community simplified chinese tag dictionary with around 4050 entries covering general, artist, species and meta tags, licensed gpl-3.0, plus a traditional chinese rendering of it

### Changed
- videos start muted again on installs that still carried the old unmuted default; a deliberately chosen sound preference survives
- the posts filter prompt groups its filters into labeled sections with active counts, and gains a reset action that clears every filter while keeping plain search tags
- update checks fall back to the releases atom feed when the github api is rate limited, so shared addresses keep receiving updates
- opening a section from the navigation drawer, a deep link, an in-app root link or a notification tap keeps the first route rooted, so backing out returns somewhere instead of leaving the app
- the navigation drawer highlights whichever section sits on top of the stack
- the last untranslated interface strings are localized across every language

## [21.3.0+121] - 2026-10-31
### Added
- a quality menu to fullscreen videos, listing every re-encoded variant of a post alongside its original file; switching quality keeps the playback position and play state
- an automatic video loading setting, off by default, so videos are only downloaded when they are actually played
- french and brazilian portuguese translations of the whole interface
- a japanese offline dictionary for common tags, and around a hundred more curated simplified chinese entries covering species, fantasy races, clothing, meta and rating tags
- optional password encryption for database exports; importing an encrypted file asks for the password again and rejects wrong ones
- an 18+ confirmation before logging in, phrased like a person and not a legal disclaimer
- swipe to close fullscreen images, an image loading progress bar and a preferred hand setting, merged from upstream
- content hero transitions between post lists and fullscreen views, merged from upstream

### Changed
- the video player pool is sized by device memory and video loads send the app user agent
- filtered overlay labels, prompts and the refresh indicator are localized
- the fullscreen video quality picker sits at the end of the video bar as an icon, and is hidden when a video has no re-encoded variants
- the video resolution setting lists plain sizes and explains that the closest available size is used
- with automatic loading off, browsing no longer fetches videos or their preview frames; a placeholder shows until a video is played

### Fixed
- the ios version probe no longer crashes the app on startup when the os reports an unexpected version format
- video durations past an hour show the hours part instead of silently dropping it, and non-standard quality keys no longer break the video player
- the file cache treats isolate-wrapped sqlite failures like direct ones instead of surfacing them as unknown errors
- download progress arriving after a task was disposed no longer touches dead state
- files exported from downloads canceled during the export are removed again
- database imports without a schema version are rejected instead of importing a potentially corrupt database
- a video route recycled for another post releases the previous player instead of holding two leases
- failed grid thumbnails show a broken image hint instead of a blank tile
- the task list retry button triggers the controller retry again
- identity stream errors are visible instead of an endless spinner
- timeline tag query failures surface an error with a retry instead of spinning forever
- detail loading failures offer a retry button
- blacklists now apply to parent/child posts, avatar posts, thumbnails, visited history and the detail view, merged from upstream
- videos no longer crash when their activity is destroyed, image pinch zoom no longer loses to page scrolling, merged from upstream
- a cancelled follow sync no longer hangs and subscriptions no longer go stale after syncing, merged from upstream
- the floating action button no longer covers inline drawers and bubbles no longer hide at the screen edge, merged from upstream

## [21.3.0-rc.5+120] - 2026-10-31
### Added
- french and brazilian portuguese translations of the whole interface
- a japanese offline dictionary for common tags, and around a hundred more curated simplified chinese entries covering species, fantasy races, clothing, meta and rating tags
- optional password encryption for database exports; importing an encrypted file asks for the password again and rejects wrong ones
- an 18+ confirmation before logging in, phrased like a person and not a legal disclaimer

## [21.3.0-rc.4+119] - 2026-10-31
### Fixed
- the ios version probe no longer crashes the app on startup when the os reports an unexpected version format
- video durations past an hour show the hours part instead of silently dropping it, non-standard quality keys no longer break the video player, and players that are refused no longer look frozen
- the file cache treats isolate-wrapped sqlite failures like direct ones instead of surfacing them as unknown errors
- download progress arriving after a task was disposed no longer touches dead state
- files exported from downloads canceled during the export are removed again
- database imports without a schema version are rejected instead of importing a potentially corrupt database
- a video route recycled for another post releases the previous player instead of holding two leases
- failed grid thumbnails show a broken image hint instead of a blank tile
- the task list retry button triggers the controller retry again
- identity stream errors are visible instead of an endless spinner
- timeline tag query failures surface an error with a retry instead of spinning forever
- detail loading failures offer a retry button

### Changed
- the video player pool is sized by device memory and video loads send the app user agent
- filtered overlay labels, prompts and the refresh indicator are localized
- the screen-lock pin is excluded from android cloud backups
- the cookie capture page no longer downgrades https identities to http
- server-provided download file names are flattened to a single safe path segment

### Added
- regression tests covering the video pool lease invariants and the download queue concurrency
- a ci check that the pinned localization output stays in sync with the arb sources

## [21.3.0-rc.3+118] - 2026-10-18
### Changed
- the fullscreen video quality button is an icon that opens the quality picker, instead of a label stating the active quality, which could crowd and misalign the video bar
- the quality button is hidden when a video has no re-encoded variants, leaving only its source file to pick

## [21.3.0-rc.2+117] - 2026-10-17
### Changed
- the fullscreen video quality picker moved to the end of the video bar, next to the fullscreen button, and its button now shows the active quality instead of an HQ icon
- the video resolution setting lists plain sizes and explains that the closest available size is used, since videos rarely come in standard resolutions

## [21.3.0-rc.1+116] - 2026-10-17
### Added
- a quality menu to fullscreen videos, listing every re-encoded variant of a post alongside its original file
- an automatic video loading setting, off by default, so videos are only downloaded when they are actually played; enabling it explains the consequences and takes effect immediately

### Changed
- switching video quality keeps the current playback position and play state
- the video resolution setting now considers all re-encoded variants of a post, preferring a smaller mp4 re-encode over the original upload when the sizes match
- with automatic loading off, browsing no longer fetches videos or their preview frames; a placeholder shows until a video is played

## [21.2.0+115] - 2026-10-03
### Added
- german and spanish translations of the whole interface
- a chinese description for common tags in the tag prompt, served offline without a wiki request

### Changed
- the japanese and russian translations received a native quality review

### Fixed
- canceling a download now aborts its network transfer, instead of letting it finish invisibly in the background
- download tasks enqueued while another download is running start immediately again; the queue had collapsed to a single lane whenever a worker was busy
- unsupported system languages fall back to english again; adding german had made the fallback pick the alphabetically first language

## [21.1.0+114] - 2026-10-03
### Added
- a system theme that follows the platform dark mode
- a language setting with full interface translations into simplified and traditional chinese, japanese and russian
- a language selection step to onboarding
- more search filters to the posts filter panel: file type, uploader, width, height, tag count and an oldest-first order
- metatag autocomplete to search inputs, suggesting values for special search terms like order:rank
- cursor pagination to post searches sorted by recency, keeping browsing stable while new posts arrive
- a page footer with page and post counts and page jumping to post lists and the follow timeline
- an offline state to post lists, plus a banner showing cached data while offline
- undo snackbars for deleted history entries and blacklist entries
- filtering of blacklisted posts out of follow previews
- a receive timeout to api and update requests

### Changed
- database exports no longer contain saved logins; database imports strip saved logins, reject files from newer app versions, check for missing app tables, and warn about accounts on unexpected hosts
- the database and its sidecar files are excluded from Android cloud backups and iOS/iCloud backups
- the cookie capture webview only navigates to its own host; off-site links and non-http schemes are blocked
- the posts filter panel applies its changes debounced, so typing an uploader name no longer refetches on every keystroke
- desktop downloads now copy files in chunks instead of buffering them entirely in memory
- pointed update checks and repository links at this fork
- tiered the in-memory image cache and capped fullscreen image decoding on android and ios, lowering memory use
- lowered the default video resolution on mobile devices, it can be raised again in the settings
- reduced the file cache from 2000 to 500 files, removing the oldest files once after updating
- excluded x86\_64 from the universal apk, shrinking it from 137 MB to about 87 MB
- post searches with non-id orderings now stop at e621's page limit instead of failing with a server error

### Fixed
- buttons repeating their action or running twice when tapped in quick succession, including the bookmark, follow and login buttons and dialog buttons
- dialog buttons dismissing the page behind them
- canceled tasks being revived when their controller was disposed, and task queue races when switching accounts during a download
- canceled downloads still saving their file to the gallery
- a crash when leaving a video while its double tap seek animation was still playing, and the video bar freezing on the previous video after the player was replaced
- the fullscreen video exit dismissing the page behind it when double tapped
- the blacklist entry undo rolling back later deletions
- videos creating endless players when swiping through many of them, and cache crashes on devices with low storage
- the home app bar logo sitting left of the screen center
- manually typed metatag filters with repeated tokens (like several -type: exclusions) being collapsed when editing any other filter
- a crash when tapping a stale tag autocomplete suggestion
- the follow timeline resetting its search when its panel rebuilt
- empty searches showing a paging footer
- the tag count filter slider stepping by 10 instead of 5
- detail page, history and user date headers not following the app language
- the video seek overlay not following the app language
- the wrong subject in the comment report failure message, and vote failure messages on timeline tiles
- translation wording of the uploader filter label, the database export notice and the follow notification counts

## [21.1.0-rc.10+113] - 2026-10-02
### Fixed
- the bookmark button repeating its action when double tapped
- canceled tasks being revived when their controller was disposed
- the blacklist entry undo rolling back later deletions

## [21.1.0-rc.9+112] - 2026-10-02
### Added
- an offline state to post lists, plus a banner showing cached data while offline
- undo snackbars for deleted history entries and blacklist entries
- a receive timeout to api and update requests

### Changed
- database exports no longer contain saved logins; they are stripped from the exported file before it is saved
- database imports strip saved logins, reject files from newer app versions, check for missing app tables, and warn about accounts on unexpected hosts
- the database and its sidecar files are excluded from Android cloud backups and iOS/iCloud backups
- the cookie capture webview only navigates to its own host; off-site links and non-http schemes are blocked
- the posts filter panel applies its changes debounced, so typing an uploader name no longer refetches on every keystroke

## [21.1.0-rc.8+111] - 2026-10-02
### Fixed
- a crash when leaving a video while its double tap seek animation was still playing
- the video bar freezing on the previous video after the player was replaced
- task queue races when switching accounts during a download, which could leave tasks stuck or marked failed
- canceled downloads still saving their file to the gallery
- the fullscreen video exit dismissing the page behind it when double tapped
- follow and login buttons repeating their action when double tapped

### Changed
- desktop downloads now copy files in chunks instead of buffering them entirely in memory
- the denylist filter cache cleans up in throttled sweeps instead of on every lookup

## [21.1.0-rc.7+110] - 2026-10-01
### Added
- an oldest-first order to the posts filter and its metatag autocomplete
- a page footer with page and post counts and page jumping to the follow timeline
- picture and video categories to the file type filter

### Fixed
- dialog buttons dismissing the page behind them or running twice when tapped in quick succession
- the home app bar logo sitting left of the screen center
- manually typed metatag filters with repeated tokens (like several -type: exclusions) being collapsed when editing any other filter
- a crash when tapping a stale tag autocomplete suggestion
- the follow timeline resetting its search when its panel rebuilt
- empty searches showing a paging footer
- the tag count filter slider stepping by 10 instead of 5
- the russian wording of the uploader filter label

## [21.1.0-rc.6+109] - 2026-10-01
### Added
- more search filters to the posts filter panel: file type, uploader, width, height and tag count
- metatag autocomplete to search inputs, suggesting values for special search terms like order:rank

## [21.1.0-rc.5+108] - 2026-10-01
### Added
- cursor pagination to post searches sorted by recency, keeping browsing stable while new posts arrive
- a page footer with page and post counts and page jumping to post lists
- translations of the remaining status and error messages

### Changed
- post searches with non-id orderings now stop at e621's page limit instead of failing with a server error

### Fixed
- detail page dates not following the app language
- a russian plural mismatch in follow notification counts

## [21.1.0-rc.4+107] - 2026-09-30
### Added
- a language selection step to onboarding
- japanese and russian translations
- a filter button to the posts app bar, exposing search filters and their query syntax
- simplified and traditional chinese translations of the post detail info section, the dtext editor toolbar, the tag drawer and wiki prompt, the post edit form, report and flag flows and the tasks page
- translations of follow notifications, the host unavailable page and desktop share and download prompts

### Changed
- merged duplicate translation keys and polished translation wording

### Fixed
- vote failure messages on timeline tiles

## [21.1.0-rc.3+106] - 2026-09-29
### Added
- simplified and traditional chinese translations of the blacklist editor, search filters and most remaining interface pages
- regression tests for the follow sync blacklist filtering

### Changed
- extended the memory friendly default video resolution tier to ios devices

### Fixed
- history and user date headers not following the app language
- the wrong subject in the comment report failure message

## [21.1.0-rc.2+105] - 2026-09-26
### Added
- a system theme that follows the platform dark mode
- a language setting with simplified and traditional chinese translations of the main interface
- filtering of blacklisted posts out of follow previews

### Changed
- pointed update checks and repository links at this fork
- tiered the in-memory image cache on ios, limiting it to 500 images and 64 MB
- capped fullscreen image decoding to 2048 pixels and about 4 megapixels on ios
- excluded x86\_64 from the universal apk, shrinking it from 137 MB to about 87 MB

## [21.1.0-rc.1+104] - 2026-09-26
### Changed
- Capped fullscreen image decoding to about 4 megapixels on Android
- Tiered the in-memory image cache on Android, limiting it to 300 images and 48 MB on 32 bit and 500 images and 64 MB on 64 bit devices
- Lowered the default video resolution to 480p on 32 bit and 720p on 64 bit Android devices, it can be raised again in the settings
- Reduced the file cache from 2000 to 500 files, removing the oldest files once after updating
- Recommended 64 bit builds in the readme

### Fixed
- Videos creating endless players when swiping through many of them
- Cache crashes on devices with low storage

## [21.1.1+105] - 2026-10-21
### Fixed
- Image pinch zoom

## [21.1.0+104] - 2026-10-20
### Added
- Swipe to close image
- Preferred hand setting

### Fixed
- Video player crashes
- Database export on iOS
- Blacklist not applying

## [21.0.1+103] - 2026-09-02
### Fixed
- Videos playing on after swiping away from them
- Follows staying unread after visiting them
- System bars showing and hiding

## [21.0.0+102] - 2026-08-31
### Added
- Previews for parent, child and pool posts
- Posting and reporting forum replies
- Windows and Linux releases
- Links to headings in wiki and forum pages

### Fixed
- Clearing history
- Missing bookmark and follow thumbnails
- Rewinding a video jumping to its end
- Wide tables overflowing wiki and forum pages
- Blacklist differing from the site
- Reporting posts

## [20.5.0+101] - 2026-07-06
### Added
- Onboarding flow
- Task cancel and clear
- Displaying cropped avatars

### Changed
- Faster parallel task downloads

### Fixed
- Cloudflare challenge resolution
- Post detail performance

## [20.4.0+100] - 2026-05-24
### Added
- Download and favorite task UI

### Fixed
- Tag alias crash on dynamic lookup
- DText parser edge cases

## [20.3.0+99] - 2026-05-19
### Added
- Linux as a build target
- Database import and export
- E621 forum thread link on the About page
- History clear button

### Changed
- Improved DText rendering speed
- Simplified history display

### Fixed
- Editing post sources
- User blocking
- Follow and history thumbnails
- Forum history links

### Removed
- "order:new" search shortcut
- Funding options

## [20.2.0+98] - 2025-06-07
### Added
- support for tag group searches
- blacklist comments support

### Fixed
- iOS background process crash
- downloads on some android devices
- some posts not displaying
- clearing image cache

## [20.1.1+97] - 2025-05-19
### Fixed
- Downloading and showing images in the photo gallery on Android

## [20.1.0+96] - 2025-05-14
### Added
- Forum post reading
- better blacklist performance

### Fixed
- Loading posts

## [20.0.0+95] - 2025-02-16
### Added
- bluesky source icon
- report reason explanations
- contributor tag category
- api key quick link on login screen

### Fixed
- database connection issues

### Removed
- non-e621 clients

## [19.1.0+94] - 2024-06-05
### Added
- X (formerly twitter) source icon

### Changed
- appbar filter icon

### Fixed
- light theme appbars
- post updated\_at error
- dtext newlines

## [19.0.1+93] - 2024-04-26
### Fixed
- black screens on closing search
- certain dtext errors

## [19.0.0+92] - 2024-04-23
### Added
- video resolution setting
- incognito keyboard

### Changed
- follow refresh ui
- improved history search speed

### Fixed
- dtext header issues
- secure display
- downloads on certain hosts

## [18.1.0+91] - 2024-02-25
### Added
- Donation list in about
- Secure display setting

### Changed
- Show unseen follows now persists
- Artist names UI

### Fixed
- Android downloads
- Post info setting being hidden
- Green app border
- Text editor not closing

## [18.0.0+90] - 2024-02-06
### Added
- multiple logins (identities)

### Changed
- settings layout
- log messages format

### Fixed
- cache size bloat

## [17.0.0+89] - 2023-09-15
### Added
- extra about info
- desktop search ui
- ui search filters
- desktop mouse zoom
- new follow edit screen
- more desktop ui

### Changed
- faster dtext parsing
- wiki button ui
- new video player engine

### Fixed
- editing comments

## [16.2.8+88] - 2023-08-22
### Fixed
- empty search history
- post editing inputs

## [16.2.7+87] - 2023-08-21
### Fixed
- adding history entries
- sorting tags

## [16.2.6+86] - 2023-08-21
### Fixed
- adding follows
- adding history

## [16.2.5+85] - 2023-08-20
### Fixed
- android download lag
- infinite loading

## [16.2.4+84] - 2023-08-09
### Fixed
- login for new users with no blacklist

## [16.2.3+83] - 2023-07-30
### Fixed
- downloads on android (again, for the final time)
- bookmarks being erroneously refreshed
- lag when selecting date for history search

## [16.2.2+82] - 2023-06-30
### Fixed
- bookmarks unintentionally being refreshed
- downloads crashing on some android devices

## [16.2.1+81] - 2023-06-10
### Fixed
- bookmarks showing incorrect data
- notifications failing to send

## [16.2.0+80] - 2023-06-06
### Added
- mark as read option for follow tiles
- opening posts from notifications

### Fixed
- wiki dialogs
- bookmarks appearing in timeline

## [16.1.0+79] - 2023-05-28
### Added
- Grouping notifications
- Notifications in foreground

### Changed
- Split notifications per tag
- Split Follows into Subscriptions and Bookmarks

### Fixed
- Pool order switch

## [16.0.0+78] - 2023-05-07
### Added
- notifications for follows
- log files
- more log entries
- log entry multi-select
- better server status catching

### Changed
- split timeline and follows
- hide blacklisted pool thumbnails

### Fixed
- editing follows
- app layout when opening virtual keyboards

## [15.4.2+77] - 2023-03-23
### Fixed
- performance
- settings ui jumping

## [15.4.1+76] - 2023-03-22
### Fixed
- duplicate download folders
- history sharing
- favorites displaying unavailable posts

## [15.4.0+75] - 2023-03-16
### Added
- blocking users

### Fixed
- tapping tag suggestions

## [15.3.1+74] - 2023-03-03
### Fixed
- wiki sheet actions overflowing
- removing unseen filter when marking all as read
- autocomplete breaking tags when using negatives
- autocomplete tapping on certain devices

## [15.3.0+73] - 2023-02-24
### Changed
- about screen design
- order of follows in folders and timeline

### Fixed
- cloudflare check when logged out
- adding posts to wrong host history

## [15.2.0+72] - 2023-02-16
### Added
- sheet handles
- windows installer build files
- new custom host screen
- pageview buttons for desktops

### Fixed
- search race condition
- pool history
- link ending parsing
- refreshing favorites
- follow timeline with multitag searches
- blacklist sync
- replying to comments with quotes
- history adding blacklisted posts
- layout in flag post screen

## [15.1.0+71] - 2022-12-28
### Added
- cloudflare cookie resolving
- favorite counts on user page

### Changed
- user page layouts for wide screens
- appbar design

### Fixed
- favorites for users without login
- comment upvoting
- loading parent/child posts

## [15.0.1+70] - 2022-12-11
### Changed
- pool reader mode now enabled by default

### Fixed
- error displays for when the site is down
- retrying loading items
- favorite and upvote setting

## [15.0.0+69] - 2022-11-28
### Added
- multi-select for follows
- pool thumbnails
- cancelling requests

### Changed
- dtext spoiler design
- dtext parsing
- pool tile design
- topic tile design

### Fixed
- saving logins
- parsing comments and replies with warnings

### Removed
- follows migration

## [14.0.1+68] - 2022-11-08
### Fixed
- host switch in settings

## [14.0.0+67] - 2022-11-07
### Added
- android download location
- fast follow updating algorithm

### Changed
- follows are now host dependant

### Fixed
- history entries on wrong host
- no history entry on host switch
- history link sharing
- downloads on certain android devices

## [13.0.1+66] - 2022-10-23
### Fixed
- pool parsing
- auto-vote on favoriting
- comment upvoting

## [13.0.0+65] - 2022-10-09
### Added
- follow timeline screen

### Fixed
- performance issues with favoriting
- video mute button

## [12.2.0+64] - 2022-09-06
### Added
- pool reader mode

### Fixed
- history mass-deleting

## [12.1.1+63] - 2022-09-06
### Fixed
- deleting history entries

## [12.1.0+62] - 2022-09-05
### Added
- better tablet layouts
- infinite history
- more history entry types
- pool search suggestions
- better link parsing

### Changed
- history filter drawer
- login screen design
- search button is no longer behind autocomplete

### Fixed
- history performance
- large image grid performance
- mass-favoriting
- pool search switches
- blacklist sync on login
- detail gallery swiping requesting new pages
- duplicate posts
- log file exports
- editing posts
- blacklisting avatars

### Removed
- "tiles adapt their size" grid option
- tap comment to reply

## [12.0.0+61] - 2022-07-31
### Added
- infinite history
- more history entry types
- pool search suggestions
- better link parsing

### Changed
- search button is no longer behind autocomplete

### Fixed
- detail gallery swiping requesting new pages
- duplicate posts
- log file exports
- editing posts
- blacklisting avatars

### Removed
- "tiles adapt their size" grid option
- tap comment to reply

## [11.0.0+60] - 2022-06-21
### Added
- deep link support
- app lockscreen
- logging for errors
- website link in about
- more tablet layouts

### Changed
- dtext parsing
- snackbars to material banners

### Removed
- combined follow screen

## [10.1.3+59] - 2022-04-15
### Changed
- history limit to 3'000

## [10.1.2+58] - 2022-04-15
### Changed
- history screen is no longer a root view

### Fixed
- lag when deleting history entries
- deleting history entries over limit

## [10.1.1+57] - 2022-04-06
### Added
- history link in drawer

### Changed
- dtext parsing

### Fixed
- unable to read follows while refreshing

### Removed
- fullscreen UI setting

## [10.1.0+56] - 2022-03-19
### Added
- filter for history
- history limit of 5'000 entries or older than 30 days
- better tablet layouts

### Changed
- follow and history tile sizes

## [10.0.1+55] - 2022-03-14
### Added
- history for posts, pools and tags
- http request caching
- double tap appbar to scroll to top

### Changed
- switched version number format to more closely resemble semantic versioning (1.9.10 -> 9.10.0)
- hiding post children if all are deleted

### Fixed
- downloaded posts not showing in gallery (android)
- blacklist syncrhonisation
- comment parsing
- follow tiles not updating during refresh

### Removed
- scroll to top button

## [1.9.10+53] - 2021-12-15
### Fixed
- support for android 12
- videos not muting immediately
- post reports always failing

## [1.9.9+52] - 2021-11-25
### Fixed
- gallery desynchronisation issue

## [1.9.7+50] - 2021-11-24
### Changed
- logged in user only actions are now always visible

### Fixed
- detail view swiping requesting pages

## [1.9.6+49] - 2021-11-23
### Added
- user profiles
- voting on comments
- reporting comments
- scroll to top button

### Changed
- target sdk to 30

### Fixed
- post duplication
- video ui
- forum usernames

### Removed
- double tapping appbar to scroll to top

## [1.9.5+48] - 2021-11-16
### Added
- context (right side) drawer buttons in appbars
- jump to last page button for topics

### Changed
- appbar design
- grid stagger settings name

### Fixed
- logging in
- dtext links

## [1.9.4+47] - 2021-11-14
### Added
- reporting posts
- flagging posts

### Changed
- blue color theme
- default home screen search
- default video mute

### Fixed
- editing post tags

## [1.9.3+46] - 2021-11-07
### Fixed
- android apk being invalid
- sending comments
- mass-favoriting

## [1.9.2+45] - 2021-11-01
### Fixed
- blacklisting follows
- download indicators
- downloads failing

## [1.9.1+44] - 2021-10-30
### Added
- video mute button
- mute video settings

### Changed
- video skip animation

### Fixed
- login update
- blacklist editor

## [1.9.0+43] - 2021-10-27
### Added
- blacklist sync with server (please backup your blacklist)
- advanced settings menu
- auto-upvote when favoriting
- post tile info bar
- hiding system ui in fullscreen
- experimental forum access
- right side drawer actions for pool order
- right side drawer actions for comment order
- loading screens for dtext links

### Changed
- settings options order
- app icon
- app theme colors
- dtext link parsing

### Fixed
- swiping on videos
- posts not refreshing on login/logout
- post tile size not updating
- hero animations in landscape
- updating user avatar

## [1.8.1+42] - 2021-07-07
### Added
- loading indicator for new pages
- double tapping videos to skip

### Changed
- follow appbar action location to drawer
- system ui visibility in fullscreen to visible

### Fixed
- post editing issues

## [1.8.0+41] - 2021-06-19
### Added
- following screen

### Changed
- pool ordering
- progress indicators
- landscape mode
- performance

### Fixed
- iOS video playing
- editing posts

## [1.7.4+40] - 2021-05-27
### Added
- video support on iOS
- image downloads for iOS
- blacklisting with \~

### Changed
- dtext parsing
- error message design
- light theme design

### Fixed
- image zoom reset
- wiki dialog tag subtraction

## [1.7.3+39] - 2021-04-15
### Added
- blacklist drawer
- multi-tag following
- adding tags to the current search
- more post tile grid options

### Changed
- wiki dialog design
- video player UI design
- dtext parsing
- themes

## [1.7.2+38] - 2020-11-16
### Added
- better tag search

### Fixed
- performance issues
- webm issues
- favorite / blacklist issues

## [1.7.1+37] - 2020-11-16
### Added
- post tile size configuration
- post tile staggering
- multiselecting post tiles with longpress

### Changed
- tag input design
- comments to be sorted oldest first

### Fixed
- tag input issues

## [1.7.0+36] - 2020-10-23
### Added
- video support
- ui animations
- user avatar in drawer
- opening webms

### Changed
- detail view design

## [1.6.2+35] - 2020-09-26
### Added
- user avatar in drawer
- opening webms

### Changed
- detail view design

## [1.6.1+34] - 2020-09-15
### Added
- image preloading

### Changed
- appbar design to floating

### Fixed
- lag when swiping
- keyboard closing when choosing autocomplete

## [1.6.0+33] - 2020-08-10
### Added
- writing comments
- editing comments
- replying to comments
- swichting host without page resets

### Fixed
- blacklist ignoring rating
- pool duplicate pages

## [1.5.2+32] - 2020-07-26
### Changed
- following screen design

## [1.5.1+31] - 2020-07-21
### Fixed
- post editing

## [1.5.0+30] - 2020-07-21
### Added
- editing posts
- infinite fullscreen swiping
- dtext spoilers

### Changed
- package name
- blacklist page design

### Fixed
- tag autocomplete

## [1.4.3+29] - 2020-07-11
### Added
- warning about host switching
- replacing underscores with spaces in tags

### Fixed
- multiple artists bug
- alignment of large images

## [1.4.2+27] - 2020-06-23
### Changed
- changelog to display all new versions

### Fixed
- update notification

## [1.4.1+26] - 2020-06-23
### Fixed
- system ui color changing

## [1.4.0+25] - 2020-06-23
### Added
- themes
- showing blacklisted images

### Fixed
- blacklist issues

## [1.3.5+24] - 2020-06-09
### Added
- iOS support
- colors for tags
- centering small images in detail view
- swiping between images in fullscreen
- search tab in drawer

## [1.3.4+23] - 2020-05-17
### Added
- better landscape design

### Fixed
- blacklist removing favorites
- nested nested dtext parsing

## [1.3.3+22] - 2020-05-02
### Fixed
- parsing updated\_at json

## [1.3.2+21] - 2020-05-01
### Fixed
- downloads on android 10
- nested dtext parsing

## [1.3.1+20] - 2020-04-24
### Added
- wiki dialog in search appbar
- following pools

## [1.3.0+19] - 2020-04-23
### Added
- followed tags page
- following tags in wiki dialog
- multiline editor for blacklist

## [1.2.8+18] - 2020-04-22
### Changed
- dtext parsing

## [1.2.7+17] - 2020-04-21
### Added
- blocking tags in wiki dialog
- dtext parsing

### Fixed
- wiki dialog overflow

## [1.2.6+16] - 2020-04-20
### Added
- tag autocomplete for search
- hiding blacklisted post detail images

### Fixed
- logging in

## [1.2.5+15] - 2020-04-19
### Added
- local blacklist
- comment age and edited status

### Changed
- refreshing is now pull to refresh

## [1.2.4+14] - 2020-04-17
### Added
- voting on posts
- viewing post comments

### Fixed
- displaying quotes

## [1.2.3+13] - 2020-04-16
### Added
- opening deleted post children

### Fixed
- pool pages loading
- displaying onsite links

## [1.2.2+12] - 2020-04-14
### Added
- sharing post links
- sharing pool links
- long press tags to view wiki
- viewing deleted posts
- more dtext support
- addvanced pool information

### Fixed
- settings refreshing the correct page
- downloading posts
- dtext parsing links
- opening posts from a different post causing infinite load
- post duplicates in pools

## [1.2.1+11] - 2020-04-13
### Added
- post parent links
- post children links
- clickable links in post descriptions

### Fixed
- pool page lag
- post blackscreens
- favorite button while logged out
- settings changes refreshing the app

## [1.2.0+10] - 2020-04-13
### Added
- post descriptions
- more post information
- clicking on tags to launch search
- pool links on posts
- changelogs in about screen
- update hint in drawer
- pool descriptions in pool screen
- login button in settings

### Fixed
- repeating posts

## [1.1.5+9] - 2020-04-11
### Added
- more dtext support for pool descriptions
- version check on about screen

### Changed
- settings design
- app reloading after settings change

### Fixed
- network interupts causing infinite loading

## [1.1.4+8] - 2020-04-11
### Added
- support for newer API keys

## [1.1.3+7] - 2020-04-11
### Added
- pool descriptions
- links in pool descriptions

### Changed
- app theme to be darker
- empty post pages now indicate emptyness

### Fixed
- clicking multiple artists

## [1.1.2+6] - 2020-04-10
### Fixed
- Fixed hiding webms

## [1.1.1+5] - 2020-04-10
### Added
- logout button in drawer
- setting to hide webms
- support for landscape

### Changed
- login screen design
- about screen design
- favorites screen to prompt login

### Fixed
- pool order

## [1.1.0+4] - 2020-04-10
### Added
- pool search
- clicking on artist names to launch a search

## [1.0.1+2] - 2020-03-16
### Changed
- pagination to infinite scroll

## [1.0.0+1] - 2020-03-08
### Added
- favorites and hot screens in drawer

### Changed
- post detail design
- favorite button to be floating

### Fixed
- API client bindings

[21.1.0-rc.6+109]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.5+108...21.1.0-rc.6+109
[21.1.0-rc.5+108]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.4+107...21.1.0-rc.5+108
[21.1.0-rc.4+107]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.3+106...21.1.0-rc.4+107
[21.1.0-rc.3+106]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.2+105...21.1.0-rc.3+106
[21.1.0-rc.2+105]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.1+104...21.1.0-rc.2+105
[21.1.0-rc.1+104]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/9d59f7d9...21.1.0-rc.1+104
[21.1.1+105]: https://github.com/clragon/e1547/compare/21.1.0+104...21.1.1+105
[21.1.0+104]: https://github.com/clragon/e1547/compare/21.0.1+103...21.1.0+104
[21.0.1+103]: https://github.com/clragon/e1547/compare/21.0.0+102...21.0.1+103
[21.0.0+102]: https://github.com/clragon/e1547/compare/20.5.0+101...21.0.0+102
[20.5.0+101]: https://github.com/clragon/e1547/compare/20.4.0+100...20.5.0+101
[20.4.0+100]: https://github.com/clragon/e1547/compare/20.3.0+99...20.4.0+100
[20.3.0+99]: https://github.com/clragon/e1547/compare/20.2.0+98...20.3.0+99
[20.2.0+98]: https://github.com/clragon/e1547/compare/20.1.1+97...20.2.0+98
[20.1.1+97]: https://github.com/clragon/e1547/compare/20.1.0+96...20.1.1+97
[20.1.0+96]: https://github.com/clragon/e1547/compare/20.0.0+95...20.1.0+96
[20.0.0+95]: https://github.com/clragon/e1547/compare/19.1.0+94...20.0.0+95
[19.1.0+94]: https://github.com/clragon/e1547/compare/19.0.1+93...19.1.0+94
[19.0.1+93]: https://github.com/clragon/e1547/compare/19.0.0+92...19.0.1+93
[19.0.0+92]: https://github.com/clragon/e1547/compare/18.1.0+91...19.0.0+92
[18.1.0+91]: https://github.com/clragon/e1547/compare/18.0.0+90...18.1.0+91
[18.0.0+90]: https://github.com/clragon/e1547/compare/17.0.0+89...18.0.0+90
[17.0.0+89]: https://github.com/clragon/e1547/compare/16.2.8+88...17.0.0+89
[16.2.8+88]: https://github.com/clragon/e1547/compare/16.2.7+87...16.2.8+88
[16.2.7+87]: https://github.com/clragon/e1547/compare/16.2.6+86...16.2.7+87
[16.2.6+86]: https://github.com/clragon/e1547/compare/16.2.5+85...16.2.6+86
[16.2.5+85]: https://github.com/clragon/e1547/compare/16.2.4+84...16.2.5+85
[16.2.4+84]: https://github.com/clragon/e1547/compare/16.2.3+83...16.2.4+84
[16.2.3+83]: https://github.com/clragon/e1547/compare/16.2.2+82...16.2.3+83
[16.2.2+82]: https://github.com/clragon/e1547/compare/16.2.1+81...16.2.2+82
[16.2.1+81]: https://github.com/clragon/e1547/compare/16.2.0+80...16.2.1+81
[16.2.0+80]: https://github.com/clragon/e1547/compare/16.1.0...16.2.0
[16.1.0+79]: https://github.com/clragon/e1547/compare/16.0.0...16.1.0
[16.0.0+78]: https://github.com/clragon/e1547/compare/15.4.2...16.0.0
[15.4.2+77]: https://github.com/clragon/e1547/compare/15.4.1...15.4.2
[15.4.1+76]: https://github.com/clragon/e1547/compare/15.4.0...15.4.1
[15.4.0+75]: https://github.com/clragon/e1547/compare/15.3.1...15.4.0
[15.3.1+74]: https://github.com/clragon/e1547/compare/15.3.0...15.3.1
[15.3.0+73]: https://github.com/clragon/e1547/compare/15.2.0...15.3.0
[15.2.0+72]: https://github.com/clragon/e1547/compare/15.1.0...15.2.0
[15.1.0+71]: https://github.com/clragon/e1547/compare/15.0.1...15.1.0
[15.0.1+70]: https://github.com/clragon/e1547/compare/15.0.0...15.0.1
[15.0.0+69]: https://github.com/clragon/e1547/compare/14.0.1...15.0.0
[14.0.1+68]: https://github.com/clragon/e1547/compare/14.0.0...14.0.1
[14.0.0+67]: https://github.com/clragon/e1547/compare/13.0.1...14.0.0
[13.0.1+66]: https://github.com/clragon/e1547/compare/13.0.0...13.0.1
[13.0.0+65]: https://github.com/clragon/e1547/compare/12.2.0...13.0.0
[12.2.0+64]: https://github.com/clragon/e1547/compare/12.1.1...12.2.0
[12.1.1+63]: https://github.com/clragon/e1547/compare/12.1.0...12.1.1
[12.1.0+62]: https://github.com/clragon/e1547/compare/12.0.0...12.1.0
[12.0.0+61]: https://github.com/clragon/e1547/compare/11.0.0...12.0.0
[11.0.0+60]: https://github.com/clragon/e1547/compare/10.1.3...11.0.0
[10.1.3+59]: https://github.com/clragon/e1547/compare/10.1.2...10.1.3
[10.1.2+58]: https://github.com/clragon/e1547/compare/10.1.1...10.1.2
[10.1.1+57]: https://github.com/clragon/e1547/compare/10.1.0...10.1.1
[10.1.0+56]: https://github.com/clragon/e1547/compare/10.0.1...10.1.0
[10.0.1+55]: https://github.com/clragon/e1547/compare/1.9.10...10.0.1
[1.9.10+53]: https://github.com/clragon/e1547/compare/1.9.9...1.9.10
[1.9.9+52]: https://github.com/clragon/e1547/compare/1.9.7...1.9.9
[1.9.7+50]: https://github.com/clragon/e1547/compare/1.9.6...1.9.7
[1.9.6+49]: https://github.com/clragon/e1547/compare/1.9.5...1.9.6
[1.9.5+48]: https://github.com/clragon/e1547/compare/1.9.4...1.9.5
[1.9.4+47]: https://github.com/clragon/e1547/compare/1.9.3...1.9.4
[1.9.3+46]: https://github.com/clragon/e1547/compare/1.9.2...1.9.3
[1.9.2+45]: https://github.com/clragon/e1547/compare/1.9.1...1.9.2
[1.9.1+44]: https://github.com/clragon/e1547/compare/1.9.0...1.9.1
[1.9.0+43]: https://github.com/clragon/e1547/compare/1.8.1...1.9.0
[1.8.1+42]: https://github.com/clragon/e1547/compare/1.8.0...1.8.1
[1.8.0+41]: https://github.com/clragon/e1547/compare/1.7.4...1.8.0
[1.7.4+40]: https://github.com/clragon/e1547/compare/1.7.3...1.7.4
[1.7.3+39]: https://github.com/clragon/e1547/compare/1.7.2...1.7.3
[1.7.2+38]: https://github.com/clragon/e1547/compare/1.7.1...1.7.2
[1.7.1+37]: https://github.com/clragon/e1547/compare/1.7.0...1.7.1
[1.7.0+36]: https://github.com/clragon/e1547/compare/1.6.2...1.7.0
[1.6.2+35]: https://github.com/clragon/e1547/compare/1.6.1...1.6.2
[1.6.1+34]: https://github.com/clragon/e1547/compare/1.6.0...1.6.1
[1.6.0+33]: https://github.com/clragon/e1547/compare/1.5.2...1.6.0
[1.5.2+32]: https://github.com/clragon/e1547/compare/1.5.1...1.5.2
[1.5.1+31]: https://github.com/clragon/e1547/compare/1.5.0...1.5.1
[1.5.0+30]: https://github.com/clragon/e1547/compare/1.4.3...1.5.0
[1.4.3+29]: https://github.com/clragon/e1547/compare/1.4.2...1.4.3
[1.4.2+27]: https://github.com/clragon/e1547/compare/1.4.1...1.4.2
[1.4.1+26]: https://github.com/clragon/e1547/compare/1.4.0...1.4.1
[1.4.0+25]: https://github.com/clragon/e1547/compare/1.3.5...1.4.0
[1.3.5+24]: https://github.com/clragon/e1547/compare/1.3.4...1.3.5
[1.3.4+23]: https://github.com/clragon/e1547/compare/1.3.3...1.3.4
[1.3.3+22]: https://github.com/clragon/e1547/compare/1.3.2...1.3.3
[1.3.2+21]: https://github.com/clragon/e1547/compare/1.3.1...1.3.2
[1.3.1+20]: https://github.com/clragon/e1547/compare/1.3.0...1.3.1
[1.3.0+19]: https://github.com/clragon/e1547/compare/1.2.8...1.3.0
[1.2.8+18]: https://github.com/clragon/e1547/compare/1.2.7...1.2.8
[1.2.7+17]: https://github.com/clragon/e1547/compare/1.2.6...1.2.7
[1.2.6+16]: https://github.com/clragon/e1547/compare/1.2.5...1.2.6
[1.2.5+15]: https://github.com/clragon/e1547/compare/1.2.4...1.2.5
[1.2.4+14]: https://github.com/clragon/e1547/compare/1.2.3...1.2.4
[1.2.3+13]: https://github.com/clragon/e1547/compare/1.2.2...1.2.3
[1.2.2+12]: https://github.com/clragon/e1547/compare/1.2.1...1.2.2
[1.2.1+11]: https://github.com/clragon/e1547/compare/1.2.0...1.2.1
[1.2.0+10]: https://github.com/clragon/e1547/compare/1.1.5...1.2.0
[1.1.5+9]: https://github.com/clragon/e1547/compare/1.1.4...1.1.5
[1.1.4+8]: https://github.com/clragon/e1547/compare/1.1.3...1.1.4
[1.1.3+7]: https://github.com/clragon/e1547/compare/1.1.2...1.1.3
[1.1.2+6]: https://github.com/clragon/e1547/compare/1.1.1...1.1.2
[1.1.1+5]: https://github.com/clragon/e1547/compare/1.1.0...1.1.1
[1.1.0+4]: https://github.com/clragon/e1547/compare/1.0.1...1.1.0
[1.0.1+2]: https://github.com/clragon/e1547/compare/1.0.0...1.0.1
[1.0.0+1]: https://github.com/clragon/e1547/releases/tag/1.0.0
[21.1.0-rc.7+110]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.6+109...21.1.0-rc.7+110
[21.1.0-rc.8+111]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.7+110...21.1.0-rc.8+111
[21.1.0-rc.9+112]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.8+111...21.1.0-rc.9+112
[21.1.0-rc.10+113]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.9+112...21.1.0-rc.10+113
[21.1.0+114]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0-rc.10+113...21.1.0+114
[21.2.0+115]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.1.0+114...21.2.0+115
[21.3.0-rc.1+116]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.2.0+115...21.3.0-rc.1+116
[21.3.0-rc.2+117]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.3.0-rc.1+116...21.3.0-rc.2+117
[21.3.0-rc.3+118]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.3.0-rc.2+117...21.3.0-rc.3+118
[21.3.0-rc.4+119]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.3.0-rc.3+118...21.3.0-rc.4+119
[21.3.0+121]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.3.0-rc.5+120...21.3.0+121
[21.3.0-rc.5+120]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.3.0-rc.4+119...21.3.0-rc.5+120
[21.4.0+122]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.3.0+121...21.4.0+122
[21.5.0-rc.1+123]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.4.0+122...21.5.0-rc.1+123
[21.5.0-rc.2+124]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.5.0-rc.1+123...21.5.0-rc.2+124

[21.5.0-rc.3+125]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.5.0-rc.2+124...21.5.0-rc.3+125
[21.5.0+126]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.5.0-rc.3+125...21.5.0+126
[21.6.0+127]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.5.0+126...21.6.0+127
[21.7.0+128]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.6.0+127...21.7.0+128
[21.7.1+129]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.7.0+128...21.7.1+129
