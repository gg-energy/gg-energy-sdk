# Release checklist

1. Create a feature branch from `develop` and open a pull request into
   `develop`.
2. After merge, run the internal pipeline and publish immutable Android
   `-rc.<build>` packages plus the iOS prerelease XCFramework.
3. Test Android Customer, Android Partner, iOS `gg`, and iOS `ggPartner` against
   that exact version: launch, map, connector status, payment, booking, back,
   reconnect, and active-session recovery.
4. Update `README.md` and `CHANGELOG.md` for every user-visible contract
   change.
5. Open `develop` → `main` only after all internal checks pass. The production
   pipeline publishes the exact `VERSION` to the public repository.
6. Verify Maven coordinates, SwiftPM tag, release notes, assets, and checksums
   before sharing the version.

Never replace a published coordinate, tag, or binary. Fixes receive a new
version. Keep GitHub tokens and server credentials only in CI secrets or local
credential stores.
