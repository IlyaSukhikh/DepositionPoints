//
//  ServiceFactory.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import CoreLocation

final class ServiceFactory {
    
    let coreDataController = CoreDataController()
    
    func makeLocationService() -> LocationService {
        let service = LocationServiceImpl(locationManager: CLLocationManager())
        return service
    }
    
    func makePartnersService() -> PartnersService {
        let service = PartnersServiceImpl(session: URLSession.shared, coreDataController: coreDataController)
        return service
    }
    
    func makePointsService() -> PointsService {
        let service = PointsServiceImpl(session: URLSession.shared, coreDataController: coreDataController)
        return service
    }
    
    func makeCache() -> Cache {
        return DiskCache(fileManager: FileManager.default)
    }
    
    func makeImageProvider() -> ImageProvider {
        let service = ImageProviderImpl(session: URLSession.shared, cache: makeCache())
        return service
    }
    
    func makePointsObserver() -> PointObserver {
        return PointObserver(managedObjectContext: coreDataController.viewContext,
                             notificationCenter: .default)
    }
}
