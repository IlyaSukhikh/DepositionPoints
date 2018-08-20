//
//  URLRequest.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation

extension URLRequest {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case head = "HEAD"
        case delete = "DELETE"
        case put = "PUT"
        case patch = "PATCH"
    }
    
    init?(endpoint: Endpoint, method: HTTPMethod) {
        guard let url = endpoint.url
            else { return nil }
        self.init(url: url)
        self.httpMethod = method.rawValue
    }
}
