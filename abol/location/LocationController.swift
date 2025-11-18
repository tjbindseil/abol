//
//  LocationController.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import CoreLocation
import Combine

class LocationController: NSObject, CLLocationManagerDelegate, ObservableObject {
    let manager: LocationManagerProtocol
    let notifier: NotificationService

    @Published var armed = false
    @Published var note: String = ""
    @Published var armedAtLat: CLLocationDegrees = 0
    @Published var armedAtLon: CLLocationDegrees = 0

    // Store region
    private var region: CLCircularRegion?

    init(useTestManager: Bool) {
        if useTestManager {
            self.manager = TestLocationManager.shared
            self.notifier = TestNotificationCenter()
        } else {
            self.manager = RealLocationManager()
            self.notifier = RealNotificationService()
        }

        super.init()
        self.manager.delegate = self
        self.manager.requestAlwaysAuthorization()
    }
    
    func armAlarm(note: String) {
        manager.requestLocation { loc in
            guard let loc = loc else {
                print("Failed to get location for arming")
                return
            }
            self.armAlarm(note: note, at: loc.coordinate)
        }
    }
    
    func armAlarm(note: String, at center: CLLocationCoordinate2D) {
        self.armed = true
        self.armedAtLat = center.latitude
        self.armedAtLon = center.longitude
        self.note = note

        let region = CLCircularRegion(
            center: center,
            radius: 50,
            identifier: "leave_area"
        )
        region.notifyOnExit = true

        self.region = region
        manager.startMonitoring(for: region)
    }

    func disarm() {
        self.armed = false
        if let region = region {
            manager.stopMonitoring(for: region)
        }
        region = nil
    }

    // GPS updates
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        // not needed for exit-only test
    }

    // Geofence callback
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
        if armed {
            notifier.scheduleExitNotification(note: note)
        }
    }
}
