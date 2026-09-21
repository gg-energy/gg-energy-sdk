# Changelog

All notable ggEnergy SDK changes are documented here. Versions follow Semantic
Versioning. Internal validation versions append `-rc.<build>` and are published
only to the private repository.

## [0.1.0] - 2026-09-22

### Added

- Android Maven artifacts and iOS `GGEnergyKit` SwiftPM/XCFramework delivery.
- Station discovery, connector selection, payment, booking, live charging,
  active-session recovery, WebSocket updates, and session summary.
- Bundled-2GIS and host-owned-2GIS Android integration variants.
- Android and iOS sample hosts and complete partner integration documentation.

### Changed

- Connector cards show connection status instead of adapter counts.
- Payment selection is explicit and host payment pickers are supported.
- Android host-owned map artifact is named `sdk-energy-android-external-map`.

### Distribution

- Internal: `am.gg.energy.internal`, version `0.1.0-rc.<build>`.
- Public: `am.gg.energy`, version `0.1.0`.

## [Unreleased]

Add user-visible changes here before merging the next feature branch into
`develop`.
