import CoreLocation
import UIKit

@MainActor
final class IosCurrentLocation: NSObject, @preconcurrency CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var latestLocation: CLLocation?
    var onLocation: ((CLLocation?) -> Void)? {
        didSet {
            if let latestLocation { onLocation?(latestLocation) }
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func loadIfAuthorized() {
        guard isAuthorized else { return }
        manager.requestLocation()
    }

    func request() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            openLocationSettings()
            onLocation?(nil)
        @unknown default:
            onLocation?(nil)
        }
    }

    var isLocationServiceEnabled: Bool { CLLocationManager.locationServicesEnabled() }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if isAuthorized { manager.requestLocation() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestLocation = locations.last
        onLocation?(latestLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onLocation?(nil)
    }

    private var isAuthorized: Bool {
        manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse
    }

    private func openLocationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }
}
