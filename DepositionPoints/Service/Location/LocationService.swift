//
//  LocationService.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import CoreLocation

protocol LocationServiceDelegate: AnyObject {

    func locationDidAuthorized()
    
    func locationDidDenied()
}

protocol LocationService: AnyObject {

    func checkAuthorizationStatus()
    
    var delegate: LocationServiceDelegate? { get set }
    var location: CLLocation? { get }
}


