//
//  LocationManager.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()

    @Published var exitEventTriggered = false
    @Published var lastKnownLocation: CLLocation?
    @Published var permissionDenied = false

    @Published var status: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        status = manager.authorizationStatus
    }

    func requestLocationPermission() {
        manager.requestAlwaysAuthorization()
    }

    func requestCurrentLocation() {
        manager.requestLocation()
    }
    
    func startMonitoring(location: CLLocation, radius: Double = 100) {
        exitEventTriggered = false
        
        let region = CLCircularRegion(
            center: location.coordinate,
            radius: radius,
            identifier: "reminderRegion"
        )

        region.notifyOnExit = true
        region.notifyOnEntry = false

        manager.startMonitoring(for: region)
        print("Started monitoring region:", region)
    }

    func stopMonitoring() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        print("Stopped monitoring all regions.")
        
        AlarmManager.updateAlarmState(to: false)
    }
    
    func isLocationAlwyasEnabled() -> Bool {
        return status == .authorizedAlways
    }
    
    func checkLocationPermission() -> String {
        switch status {
        case .authorizedAlways:
            return "Always Allowed"
        case .authorizedWhenInUse:
            return "Only When in Use"
        case .denied, .restricted:
            return "Denied or Restricted"
        case .notDetermined:
            return "Not Determined"
        @unknown default:
            return "Unknown"
        }
    }

    // MARK: - Delegate Callbacks
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        permissionDenied = (status == .denied || status == .restricted)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
        print("TJTAG - Exited region! and AlarmManager.currentArmedState is: \(AlarmManager.currentArmedState)")
        
        if (AlarmManager.currentArmedState) {
            exitEventTriggered = true
        }
        stopMonitoring()
    }

}
