//
//  PointsServiceImpl.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

final class PointsServiceImpl: PointsService {
    
    private let session: URLSession
    private let coreDataController: CoreDataController
    
    init(session: URLSession, coreDataController: CoreDataController) {
        self.session = session
        self.coreDataController = coreDataController
    }
    
    func fetchPoints(near coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let endpoint: Endpoint = .points(latitude: coordinate.latitude,
                                         longitude: coordinate.longitude,
                                         radius: Int(radius))
        guard let request = URLRequest(endpoint: endpoint, method: .get)
            else { return }
        let task = session.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data else { return }
            self?.coreDataController.performBackgroundTaskAndSave { context in
                let decoder = JSONDecoder()
                decoder.userInfo[.context] = context
                do {
                    _ = try decoder.decode(Response<DepositionPoint>.self, from: data)
                }
                catch { print(error) }
            }
        }
        task.resume()
    }
}
