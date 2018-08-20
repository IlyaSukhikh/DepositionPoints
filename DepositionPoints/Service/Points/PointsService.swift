//
//  PointsService.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import CoreLocation

protocol PointsService {
    func fetchPoints(near location: CLLocationCoordinate2D, radius: CLLocationDistance)
}
