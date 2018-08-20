//
//  Cache.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

protocol Cache {
    
    func save(data: Data, forKey key: String, modified: Date)

    func fetch(dataForKey key: String, completion: @escaping ((data: Data, modified: Date)?) -> Void)
}
