# Android integration

## 1. Configure Maven Central

No credentials or custom Maven repository are required. Add `mavenCentral()` to
your normal dependency repositories:

```kotlin
repositories {
    google()
    mavenCentral()
}
```

## 2. Choose one artifact

```kotlin
// Default: ggEnergy supplies the map runtime.
implementation("gg.team.energy:sdk-energy:0.1.5")

// Only if your app already owns a compatible 2GIS runtime.
implementation("gg.team.energy:sdk-energy-android-external-map:0.1.5")
```

Do not include both artifacts.

For `sdk-energy-android-external-map`, configure the host's initialized 2GIS
context before opening the SDK:

```kotlin
GGEnergySdk.useHostDgisContext(hostDgisContext)
```

## 3. Open the SDK

Ask your backend for a fresh bootstrap token, then open the SDK from an
`Activity`:

```kotlin
import am.gg.energy.GGEnergySdk

GGEnergySdk.open(
    activity = activity,
    bootstrapToken = bootstrapToken,
)
```

The SDK opens a separate full-screen activity. Do not try to embed its UI in a
fragment or compose view.

## Optional payment picker

If ggEnergy enables host payment selection for your partner, register your
picker before calling `open`:

```kotlin
GGEnergySdk.useHostPaymentPicker(paymentPicker)
```

Your picker completes with the chosen payment method or `null` when the user
cancels. It must never pass card PAN or CVV to the SDK.
