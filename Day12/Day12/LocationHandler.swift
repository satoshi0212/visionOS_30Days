import SwiftUI
import MapKit
import os
import CoreLocation

@MainActor class LocationsHandler: ObservableObject {
    let logger = Logger(subsystem: "tokyo.shmdevelopment.liveUpdates", category: "LocationsHandler")

    static let shared = LocationsHandler()

    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?

    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.710057, longitude: 139.810718),
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    ))

    @Published var lastLocation = CLLocation()
    @Published var count = 0
    @Published var isStationary = false

    @Published
    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
    }

    @Published
    var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
        didSet {
            backgroundActivity ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
            UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
        }
    }

    private init() {
        self.manager = CLLocationManager()
    }

    func startLocationUpdates() {
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
        self.logger.info("Starting location updates")
        Task() {
            do {
                self.updatesStarted = true
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if !self.updatesStarted { break }
                    if let loc = update.location {
                        self.lastLocation = loc
                        self.isStationary = update.isStationary
                        self.count += 1
                        self.logger.info("Location \(self.count): \(self.lastLocation)")

                        let center = CLLocationCoordinate2D(
                            latitude: loc.coordinate.latitude,
                            longitude: loc.coordinate.longitude)

                        self.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                            center: center,
                            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                        ))
                    }
                }
            } catch {
                self.logger.error("Could not start location updates")
            }
            return
        }
    }

    func stopLocationUpdates() {
        self.logger.info("Stopping location updates")
        self.updatesStarted = false
    }
}
