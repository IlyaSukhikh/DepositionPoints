//
//  PartnersServiceImpl.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreData

final class PartnersServiceImpl: PartnersService {
    
    private let session: URLSession
    private let coreDataController: CoreDataController

    init(session: URLSession, coreDataController: CoreDataController) {
        self.session = session
        self.coreDataController = coreDataController
    }
    
    func fetchPartners(autoretry: Bool) {
        guard let request = URLRequest(endpoint: .partners, method: .get)
            else { return }
        let task = session.dataTask(with: request) { [weak self] data, _, error in

            if let error = error {
                print(error)
                if autoretry {
                    self?.schedureRetry()
                }
                return
            }
            
            guard let data = data else { return }
            self?.coreDataController.performBackgroundTaskAndSave { context in
                let decoder = JSONDecoder()
                decoder.userInfo[.context] = context
                do {
                    _ = try decoder.decode(Response<Partner>.self, from: data)
                }
                catch { print(error) }
            }
        }
        task.resume()
    }
    
    private func schedureRetry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.fetchPartners(autoretry: true)
        }
    }
}
