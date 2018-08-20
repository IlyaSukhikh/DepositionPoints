//
//  Response.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation

struct Response<T: Decodable>: Decodable {

    let resultCode: String  // ;(
    let trackingId: String
    let payload: [T]?
    let errorMessage: String?
    let plainMessage: String?
}

extension Response {
    
    var isError: Bool {
        return resultCode != "OK"
    }
}
