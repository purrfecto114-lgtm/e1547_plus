# Release runbook

How this repository cuts releases. Applies to both pre-release (rc) and stable
versions. The whole pipeline is driven by the
[Application Release](../.github/workflows/deployment.yml) workflow; this
document covers the manual preparation it expects.

## Version scheme

- Versions are `X.Y.Z` with a build number: `X.Y.Z+build` (for example
  `21.2.0+115`).
- Pre-releases insert a pre-release segment between the patch and the build:
  `X.Y.0-rc.N+build` (for example `21.3.0-rc.1+116`).
- Every release increments the build number by exactly one, rc or not. The
  stable release that follows the last rc takes the next build number
  (`21.1.0-rc.10+113` was followed by `21.1.0+114`).
- Feature work bumps the minor version; the version is chosen when the first
  rc of the cycle is cut.
- Versions containing `-` are published as GitHub pre-releases and are never
  marked "latest"; the workflow decides this automatically.

## Manual preparation (required)

Prepare releases manually and dispatch the workflow with `version: none`:

- the workflow's `version` choices (major/minor/patch/pre/release) cannot
  produce an `-rc.N` pre-release, and
- its automatic path commits "increased version" as `github_actions`
  instead of this repository's `prepared the <version> release` convention.

(`cider release` does write compare links for entries it releases itself,
  via the `cider.link_template` in pubspec.yaml — but that only covers its
  own `Unreleased` flow, not hand-prepared entries.)

1. **pubspec.yaml** — set `version:` to the new `X.Y.0-rc.N+build` (stable:
   `X.Y.0+build`).
2. **CHANGELOG.md** — add a section for the new version directly under the
   file header:

   ```
   ## [21.3.0-rc.2+117] - 2026-10-17
   ### Added
   - ...
   ```

   and **append a link reference to the bottom of the file**:

   ```
   [21.3.0-rc.2+117]: https://github.com/purrfecto114-lgtm/e1547_plus/compare/21.3.0-rc.1+116...21.3.0-rc.2+117
   ```

   The link reference is not optional decoration. The release pipeline reads
   changelog sections through `cider` → `package:change`, which only
   recognizes a heading when markdown resolves `[version]` into a link —
   without the reference the brackets stay literal, the section is not
   recognized as a release, and the pipeline fails with
   `Bad state: Version ... not found` (this exact failure happened when
   21.3.0-rc.1 was first dispatched).
3. **fastlane/metadata/android/en-US/changelogs/`<build>`.txt** — the release
   body: the changelog section without the heading or date (sections directly
   adjacent, one trailing newline; match the existing files).
4. Commit everything as **`prepared the <version> release`**.
5. Tag the commit — a **lightweight** tag named exactly like the version —
   and push branch and tag:

   ```
   git tag 21.3.0-rc.2+117
   git push origin master refs/tags/21.3.0-rc.2+117
   ```

## Dispatching the build

Workflow: *Application Release* → *Run workflow* on `master`, or via the API:

```json
{
  "ref": "master",
  "inputs": {
    "version": "none",
    "release_title": "21.3.0-rc.2 (Video quality RC 2)",
    "skip_playstore": "true",
    "skip_github_release": "false",
    "skip_forum": "true",
    "dry_run": "false"
  }
}
```

- `version: "none"` — the version was already bumped manually; an automatic
  bump would either not produce an `-rc.N` version or commit outside the
  repository's message convention.
- `release_title` — convention: the version, then a parenthesized summary, e.g.
  `21.1.0-rc.9 (Android 7 stability RC 9)`.
- `skip_playstore` — set to `true` unless the Play Store upload is intended
  for this release. Unlike the forum job, the Play Store upload is NOT
  skipped automatically when its secret is absent — it fails before the
  GitHub release is created.
- `skip_forum` — `true` for rc releases; a forum post is usually only wanted
  for stable releases. This job does skip itself when the forum secrets are
  absent.
- `skip_github_release` — leave `false` for a real release; `true` only
  validates the builds without creating the GitHub release.
- `dry_run` — builds everything and validates, but publishes nothing.

The workflow builds Android (APKs + AAB), iOS, Windows and Linux packages,
then creates the GitHub release from the tag with the fastlane changelog as
the body and attaches the seven release binaries (the AAB stays a workflow
artifact for the Play Store job). Pre-release marking is automatic.

## Known pipeline behavior

- **Transient iOS failures**: the macOS runner sometimes times out
  downloading the Flutter SDK (`curl: (56) Recv failure`). Re-run the failed
  jobs (Actions UI, or `POST .../runs/<id>/rerun-failed-jobs`) — no code
  change is needed.
- **Re-runs use the original commit**: re-running a run does not pick up new
  pushes. If the release commit itself needs a fix, amend it, force-push,
  re-point the tag (delete and re-push) and dispatch a fresh run.
- The forum publish job skips itself when its secrets are absent; the Play
  Store upload does not (see `skip_playstore` above) — pass the flags
  explicitly.

## Stable release after an rc cycle

Same steps with `X.Y.0+<next build>`; the changelog section usually merges the
rc entries of the cycle into one user-facing list, and the link reference
compares against the previous release (rc or stable). The release title drops
the rc suffix. Set `skip_forum`/`skip_playstore` according to intent — this is
the release that gets marked "latest".
