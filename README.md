# ggEnergy SDK

Add EV charging to your Android or iOS app. The SDK opens a full-screen
experience for finding stations, booking, payment, charging, and history.

## Get started

1. Request partner credentials from [info@goenergy.am](mailto:info@goenergy.am).
2. Add the SDK using the [Android](docs/android.md) or [iOS](docs/ios.md) guide.
3. Have **your backend** create a bootstrap token for your signed-in user.
4. Pass that token to the SDK when the user opens Energy.

Android apps without an existing 2GIS integration can install from Maven
Central:

```kotlin
implementation("gg.team.energy:sdk-energy:0.2.0")
```

If your Android app already has a compatible 2GIS runtime, choose the
[external-map artifact](docs/android.md).

## iOS quick start (remote SPM)

Requires **iOS 16 or later**.

1. In Xcode, choose **File → Add Package Dependencies**.
2. Enter `https://github.com/gg-energy/gg-energy-sdk.git`.
3. Select **Exact Version: 0.2.0** and add **GGEnergyKit** to your app target.
4. Add a location usage description to `Info.plist` ([example](docs/ios.md#2-allow-location-access)).
5. Get a fresh bootstrap token from your backend and open the SDK on the main thread:

```swift
import GGEnergyKit

try GGEnergySdk.open(
    from: viewController,
    bootstrapToken: bootstrapToken
)
```

Xcode downloads the SDK and checks its checksum automatically. See the
[iOS guide](docs/ios.md) if your app already uses 2GIS or needs local dependencies.

## Bootstrap API

Your backend calls this API for an authenticated user. Keep `client_secret` on
your server; never put it in the mobile app.

```http
POST https://energy-ocpi.team.gg/sdk/bootstrap
Content-Type: application/json
```

```json
{
  "client_id": "<your-client-id>",
  "client_secret": "<your-client-secret>",
  "external_user_id": "<external-user-id>"
}
```

`external_user_id` is the signed-in user's stable, unique ID in your system.
Derive it from the authenticated server session; do not trust a user ID supplied
by the mobile app. The response contains a one-time token:

```json
{
  "bootstrap_token": "<bootstrap-token>"
}
```

Return the token to the app and open the SDK with it:
[Android launch example](docs/android.md#3-open-the-sdk) ·
[iOS launch example](docs/ios.md#3-open-energy).
Request a new token for every launch; do not store or log it. Your app must
authenticate the user, and only your backend may use the partner credentials.
See [Backend integration](docs/backend-integration.md) for failure handling.

## Help and releases

- Integration support: [info@goenergy.am](mailto:info@goenergy.am)
- Changes by version: [CHANGELOG.md](CHANGELOG.md)
- Security reports: [SECURITY.md](SECURITY.md)
