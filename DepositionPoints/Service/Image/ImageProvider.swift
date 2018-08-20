//
//  ImageProvider.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

protocol ImageProvider {
 
    func fetchImage(_ name: String, dpi: UIScreen.DPI, targetSize: CGSize) -> Observable<UIImage?>
}
