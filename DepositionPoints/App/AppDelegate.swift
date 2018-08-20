//
//  AppDelegate.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var coordinator: MainCoordinator!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        start()
        return true
    }
    
    func start() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let serviceFactory = ServiceFactory()
        let factory = ModuleFactory(serviceFactory: serviceFactory)
        coordinator = MainCoordinator(window: window, moduleFacotry: factory)
        coordinator.start()
    }
}
