//
//  DepositionPointAnnotation.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 18/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import MapKit
import UIKit

final class DepositionPointAnnotation: MKPointAnnotation {
    
    let id: String
    let image: Observable<UIImage?>
    
    init(id: String, image: Observable<UIImage?>) {
        self.id = id
        self.image = image
    }
}
