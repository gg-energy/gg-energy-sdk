# Changelog

Integration changes and fixes are listed by version. Published versions are
immutable; use a newer version for fixes.

## [0.1.5] - 2026-09-23

### Changed

- No SDK API or integration changes from 0.1.4. Use the same Android, iOS, and
  backend integration steps with this release.

## [0.1.4] - 2026-09-23

### Changed

- No SDK API or integration changes from 0.1.3. Use the same Android, iOS, and
  backend integration steps with this release.

## [0.1.3] - 2026-09-23

### Added

- iOS apps can reuse an existing compatible 2GIS FullSDK container with
  `mapProvider: .external(container:)`. The SDK-managed map remains the default,
  and both modes use the same `GGEnergyKit` product.

## [0.1.2] - 2026-09-23

### Fixed

- Publish Android target artifacts under distinct Maven Central coordinates so
  Gradle resolves the Android AAR and its runtime dependencies correctly.
- Publish the host-owned 2GIS integration as
  `gg.team.energy:sdk-energy-android-external-map`.

## [0.1.1] - 2026-09-23

### Changed

- No SDK API or integration changes from 0.1.0.

## [0.1.0] - 2026-09-22

### Added

- Full-screen ggEnergy charging flow for Android and iOS host apps.
- Station discovery, connector selection, payment selection, booking, charging,
  active-session recovery, and session history.
- Android artifacts for either the bundled ggEnergy map or a host-owned 2GIS
  map runtime.
- Bootstrap-token authentication between a partner backend and ggEnergy.

### Changed

- Connector cards show current status instead of adapter count.
- A payment method is chosen before the charge action becomes available.
