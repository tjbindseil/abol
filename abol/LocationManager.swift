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

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        manager.requestAlwaysAuthorization()
    }

    func requestCurrentLocation() {
        manager.requestLocation()
    }
    
    func startMonitoring(location: CLLocation, radius: Double = 200) {
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
        let status = manager.authorizationStatus
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
