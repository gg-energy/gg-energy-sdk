# ggEnergy SDK

The ggEnergy SDK provides Android and iOS host applications with a complete
electric-vehicle charging experience: station discovery, connector selection,
payment, booking, live charging, and session history. The SDK owns its
full-screen UI; the host supplies the authenticated user’s short-lived
bootstrap token.

This documentation is identical in the internal prerelease and public
distribution repositories. Only the release channel and repository URL differ.

## Release channels

| Channel | Android Maven repository | Android group | Version |
| --- | --- | --- | --- |
| Internal prerelease | `gg-energy/gg-energy-sdk-internal` | `am.gg.energy.internal` | `0.1.0-rc.<build>` |
| Public release | `gg-energy/gg-energy-sdk` | `am.gg.energy` | `0.1.0` |

Internal artifacts are for ggEnergy development and acceptance testing. They are
immutable; fixes receive a new `-rc.<build>` version. Stable releases are
published only after the same commit passes all internal sample-app checks.

## Android

Add the matching GitHub Packages Maven repository in
`settings.gradle.kts`. Keep credentials in `~/.gradle/gradle.properties` or
environment variables, never in source or an APK:

```kotlin
maven {
    url = uri("https://maven.pkg.github.com/gg-energy/gg-energy-sdk-internal")
    credentials {
        username = providers.gradleProperty("gpr.user")
            .orElse(System.getenv("GITHUB_PACKAGES_USERNAME")).get()
        password = providers.gradleProperty("gpr.key")
            .orElse(System.getenv("GITHUB_PACKAGES_TOKEN")).get()
    }
}
```

Use a classic PAT with `read:packages` for private internal artifacts. Select
exactly one artifact:

```kotlin
// SDK supplies the 2GIS runtime and its restricted SDK key.
implementation("am.gg.energy.internal:sdk-energy:0.1.0-rc.BUILD")

// Public stable equivalent:
implementation("am.gg.energy:sdk-energy:VERSION")

// Only when the host already supplies a compatible 2GIS runtime:
implementation("am.gg.energy:sdk-energy-android-external-map:VERSION")
```

Do not include both Android artifacts. For `external-map`, initialize the host
2GIS context before opening the SDK:

```kotlin
GGEnergySdk.useHostDgisContext(hostDgisContext)
GGEnergySdk.open(activity = activity, bootstrapToken = bootstrapToken)
```

The host backend obtains a short-lived token from its authenticated Terminus
endpoint (`POST /user/bootstrap`) and returns:

```json
{"data":{"bootstrap_token":"<short-lived SDK JWT>"}}
```

Pass it directly to `GGEnergySdk.open`. Do not generate, persist, or hard-code
the token in the app. The SDK exchanges it internally and presents its own
full-screen activity.

An optional host payment picker can be registered with
`GGEnergySdk.useHostPaymentPicker(...)`. It returns an `EnergyPaymentMethod` or
`null` on cancellation; the SDK never receives card PAN or CVV.

## iOS / Swift Package Manager

Add the `GGEnergyKit` package from this repository and select the exact
prerelease tag. Public consumers use the matching tag in `gg-energy-sdk`.

```swift
import GGEnergyKit

try GGEnergySdk.open(
    from: viewController,
    bootstrapToken: bootstrapToken
)
```

The package contains a checksum-protected `GGEnergy.xcframework`, generated
Compose resources, and bundled 2GIS map resources. The host must include:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to show your position and nearby charging stations.</string>
```

The package declares iOS 16 as its minimum deployment target. An optional
`@MainActor EnergyPaymentPicker` supplies host payment UI and must report every
dismissal path, including swipe dismissal.

## Samples and acceptance test

The samples are integration test hosts, not partner deliverables:

```text
apps/android/   Android bundled-2GIS host
apps/ios/       iOS bundled-2GIS host
```

Run Android against an internal artifact:

```bash
./gradlew :apps:android:assembleDebug \
  -PenergyUsePublishedSdk \
  -PenergyGroup=am.gg.energy.internal \
  -PenergyVersion=0.1.0-rc.BUILD
```

Stage the local iOS package with `./gradlew :sdk:stageSwiftPackage`.
Before production, test Android Customer, Android Partner, iOS `gg`, and iOS
`ggPartner`: launch, map loading, connector status, payment, booking, back
navigation, reconnect, and active-session recovery.

## Security and troubleshooting

- Registry tokens and backend credentials belong only in CI secret variables or
  local credential stores.
- `401`: check the repository URL, username, and PAT `read:packages` scope.
- `404`: check group, artifact, version, and internal/public repository.
- `422` during publishing: the coordinate/version already exists; publish a
  new version instead of replacing it.
- Blank 2GIS map: use a restricted key containing the host application ID, or
  initialize the host context for `external-map`.
- Swift checksum failure: use the exact release tag and original ZIP.

## Versioning and support

`VERSION` is the stable source. Internal CI appends `-rc.<build>`; production
uses the exact stable value. Published binaries and tags are immutable. See
[`CHANGELOG.md`](CHANGELOG.md) for user-visible changes and
[`docs/RELEASE.md`](docs/RELEASE.md) for the maintainer checklist. For support,
include SDK version, platform, artifact/channel, toolchain, and a redacted log.

The SDK is distributed under the commercial terms agreed with ggEnergy; this
repository is not a source-code redistribution license.
