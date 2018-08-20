//
//  ModuleFactory.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

final class ModuleFactory {
    
    let serviceFactory: ServiceFactory
    
    init(serviceFactory: ServiceFactory) {
        self.serviceFactory = serviceFactory
    }
    
    func makeMainModule() -> ViewController {
        let map = Map(locationService: serviceFactory.makeLocationService(),
                      pointsService: serviceFactory.makePointsService(),
                      partnersService: serviceFactory.makePartnersService(),
                      pointObserver: serviceFactory.makePointsObserver(),
                      imageProvider: serviceFactory.makeImageProvider(),
                      debouncer: Debouncer(limit: 0.2, queue: .main))
        let viewController = UIStoryboard.main.initMainViewController()
        viewController.map = map
        map.output = viewController
        return viewController
    }
}

extension UIStoryboard {
    
    static let main = UIStoryboard(name: "Main", bundle: nil)
    
    func initMainViewController() -> ViewController {
        let identifier = String(describing: ViewController.self)
        guard let viewController = self.instantiateViewController(withIdentifier: identifier) as? ViewController
            else { fatalError("cant init ViewController") }
        return viewController
    }
}
