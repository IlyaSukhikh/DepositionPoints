//
//  Endpoint.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

enum Endpoint {
    
    case partners
    case points(latitude: Double, longitude: Double, radius: Int)
    case image(name: String, dpi: UIScreen.DPI)
}

extension Endpoint {

    //https://www-qa.tinkoff.ru/api/v1/
    //https://www-qa.tcsbank.ru/api/v1/
    
    private static let baseURL = "https://api.tinkoff.ru/v1/"

    private var absoluteString: String {
        switch self {
        case .partners:
            return Endpoint.baseURL + "deposition_partners?accountType=Credit"
        case .points(let latitude, let longitude, let radius):
            return Endpoint.baseURL + "deposition_points?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
        case .image(let name, let dpi):
            return "https://static.tinkoff.ru/icons/deposition-partners-v3/\(dpi.rawValue)/\(name)"
        }
    }
    
    var url: URL? {
        return URL(string: absoluteString)
    }
}
