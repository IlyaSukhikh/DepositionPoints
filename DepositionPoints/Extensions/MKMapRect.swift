//
//  MKMapRect.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 17/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import MapKit

typealias PointArea = (center: CLLocationCoordinate2D, radius: CLLocationDistance)

extension MKMapRect {
    
    func toCircle() -> PointArea {
        let center = MKCoordinateRegionForMapRect(self).center
        let topRight = MKMapPoint(x: MKMapRectGetMinX(self), y: MKMapRectGetMinY(self))
        let bottomLeft = MKMapPoint(x: MKMapRectGetMaxX(self), y: MKMapRectGetMaxY(self))
        let radius = MKMetersBetweenMapPoints(topRight, bottomLeft) / 2
        return (center: center, radius: radius)
    }
}
