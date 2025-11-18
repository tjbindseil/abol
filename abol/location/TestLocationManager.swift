//
//  TestLocationManager.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import CoreLocation

class TestLocationManager: CLLocationManager, LocationManagerProtocol {
    private(set) var lastLocation: CLLocation?
    private var pendingRequests: [(CLLocation?) -> Void] = []
    
    static let shared = TestLocationManager()
    override private init() {
        super.init()
    }

    // Protocol stubs
    override var delegate: CLLocationManagerDelegate? {
        get { super.delegate }
        set { super.delegate = newValue }
    }

    override func requestAlwaysAuthorization() {}
    override func startUpdatingLocation() {}
    override func stopUpdatingLocation() {}
    override func startMonitoring(for region: CLRegion) {}
    override func stopMonitoring(for region: CLRegion) {}
}

extension TestLocationManager {
    func requestLocation(_ completion: @escaping (CLLocation?) -> Void) {
        if let loc = lastLocation {
            completion(loc)
        } else {
            // If no location pushed yet, queue it
            pendingRequests.append(completion)
        }
    }

    func pushLocation(lat: Double, lon: Double, accuracy: Double = 5.0) {
        let location = CLLocation(
            coordinate: .init(latitude: lat, longitude: lon),
            altitude: 0,
            horizontalAccuracy: accuracy,
            verticalAccuracy: accuracy,
            timestamp: Date()
        )

        lastLocation = location

        delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [location])

        // Fulfill any pending requestLocation() calls
        pendingRequests.forEach { $0(location) }
        pendingRequests.removeAll()
    }
}
