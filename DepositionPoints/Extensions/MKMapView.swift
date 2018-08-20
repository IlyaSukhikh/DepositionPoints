//
//  MKMapView.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 18/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import MapKit

extension MKMapView {
    
    func register(_ viewClass: Swift.AnyClass) {
        self.register(viewClass, forAnnotationViewWithReuseIdentifier: String(describing: viewClass))
    }
    
    func dequeueReusableAnnotationView(_ viewClass: Swift.AnyClass, for annotation: MKAnnotation) -> MKAnnotationView {
        return dequeueReusableAnnotationView(withIdentifier: String(describing: viewClass), for: annotation)
    }
}
