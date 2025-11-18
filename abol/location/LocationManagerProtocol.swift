//
//  LocationManagerProtocol.swift
//  abol
//
//  Created by TJ Bindseil on 11/18/25.
//

import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func requestLocation(_ completion: @escaping (CLLocation?) -> Void)
    func startMonitoring(for region: CLRegion)
    func stopMonitoring(for region: CLRegion)
}
