//
//  Screen.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

extension UIScreen {
    
    enum DPI: String {
        case mdpi, hdpi, xhdpi, xxhdpi
    }
    
    var dpi: DPI {
        switch self.scale {
        case 2.0:
            return .xhdpi
        case 3.0:
            return .xxhdpi
        default:
            return .mdpi
        }
    }
}
