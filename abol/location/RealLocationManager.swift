//
//  RealLocationManager.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import Foundation
import CoreLocation

class RealLocationManager: NSObject, LocationManagerProtocol {
    let manager = CLLocationManager()
    private var pendingLocationRequests: [(CLLocation?) -> Void] = []
    
    override init() {
        super.init()
    }

    var delegate: CLLocationManagerDelegate? {
        get { manager.delegate }
        set { manager.delegate = newValue }
    }

    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func requestLocation(_ completion: @escaping (CLLocation?) -> Void) {
        pendingLocationRequests.append(completion)
        manager.requestLocation()
    }
    
    func startMonitoring(for region: CLRegion) {
        manager.startMonitoring(for: region)
    }

    func stopMonitoring(for region: CLRegion) {
        manager.stopMonitoring(for: region)
    }
}

extension RealLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last

        // Fulfill all pending one-shot requests
        pendingLocationRequests.forEach { $0(loc) }
        pendingLocationRequests.removeAll()

        // Pass updates to any external delegate
        delegate?.locationManager?(manager, didUpdateLocations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pendingLocationRequests.forEach { $0(nil) }
        pendingLocationRequests.removeAll()
    }
}
