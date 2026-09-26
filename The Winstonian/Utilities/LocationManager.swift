// LocationManager.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation
import CoreLocation
import Combine

// MARK: - Location Manager

@MainActor
final class LocationManager: NSObject, ObservableObject {

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?
    @Published var locationError: LocationError?

    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    enum LocationError: LocalizedError {
        case denied
        case restricted
        case unknown
        case timeout

        var errorDescription: String? {
            switch self {
            case .denied:     return "Location access denied. Please enable it in Settings."
            case .restricted: return "Location access is restricted."
            case .unknown:    return "Unable to determine location."
            case .timeout:    return "Location request timed out."
            }
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Async - requests current location; throws on denial or error
    func fetchCurrentLocation() async throws -> CLLocation {
        if let last = lastLocation { return last }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                // Will be triggered after authorization response
            case .denied:
                continuation.resume(throwing: LocationError.denied)
                self.locationContinuation = nil
            case .restricted:
                continuation.resume(throwing: LocationError.restricted)
                self.locationContinuation = nil
            @unknown default:
                continuation.resume(throwing: LocationError.unknown)
                self.locationContinuation = nil
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                if self.locationContinuation != nil {
                    manager.requestLocation()
                }
            } else if manager.authorizationStatus == .denied {
                self.locationContinuation?.resume(throwing: LocationError.denied)
                self.locationContinuation = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            self.lastLocation = location
            self.locationContinuation?.resume(returning: location)
            self.locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            let locationError: LocationError
            if let clError = error as? CLError, clError.code == .denied {
                locationError = .denied
            } else {
                locationError = .unknown
            }
            self.locationError = locationError
            self.locationContinuation?.resume(throwing: locationError)
            self.locationContinuation = nil
        }
    }
}
