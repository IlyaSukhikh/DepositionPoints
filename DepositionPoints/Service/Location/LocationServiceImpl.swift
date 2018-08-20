//
//  LocationServiceImpl.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import CoreLocation

final class LocationServiceImpl: NSObject, LocationService {
    
    weak var delegate: LocationServiceDelegate?
    
    var location: CLLocation? {
        return locationManager.location
    }
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 15
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.startUpdatingLocation()
    }
    
    deinit {
        self.locationManager.stopUpdatingLocation()
    }
    
    func checkAuthorizationStatus() {
        guard CLLocationManager.locationServicesEnabled() else {
            delegate?.locationDidDenied()
            return
        }
        let status = CLLocationManager.authorizationStatus()
        handleAuthtorization(status: status)
    }
    
    // Private
    
    private let locationManager: CLLocationManager
    
    private func handleAuthtorization(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            delegate?.locationDidAuthorized()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            delegate?.locationDidDenied()
        }
    }
}

extension LocationServiceImpl: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthtorization(status: status)
    }
}
