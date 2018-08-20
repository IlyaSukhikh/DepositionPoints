//
//  MainCoordinator.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

final class MainCoordinator {
    
    let window: UIWindow
    let facotry: ModuleFactory
    
    init(window: UIWindow, moduleFacotry: ModuleFactory) {
        self.window = window
        self.facotry = moduleFacotry
    }
    
    func start() {
        let module = self.facotry.makeMainModule()
        let root = UINavigationController(rootViewController: module)
        self.window.rootViewController = root
        self.window.makeKeyAndVisible()
    }
}
