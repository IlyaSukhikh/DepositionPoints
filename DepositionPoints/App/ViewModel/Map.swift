//
//  Map.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol MapOutput: AnyObject {
    
    func showUserLocation()
    
    func navigateTo(region: MKCoordinateRegion)
    
    func showLocatioUnavaliableAlert()
    
    func show(annotations: [MKAnnotation])

    func remove(annotations: [MKAnnotation])
}

final class Map {
    
    weak var output: MapOutput?
    
    private let locationService: LocationService
    private let pointsService: PointsService
    private let partnersService: PartnersService
    private let pointObserver: PointObserver
    private let imageProvider: ImageProvider
    private let debouncer: Debouncer
    private var _annotations: Set<DepositionPointAnnotation> = []

    var annotations: [MKAnnotation] {
        return Array(_annotations)
    }
    
    init(locationService: LocationService,
         pointsService: PointsService,
         partnersService: PartnersService,
         pointObserver: PointObserver,
         imageProvider: ImageProvider,
         debouncer: Debouncer) {
        
        self.locationService = locationService
        self.pointsService = pointsService
        self.partnersService = partnersService
        self.pointObserver = pointObserver
        self.imageProvider = imageProvider
        self.debouncer = debouncer
        
        self.locationService.delegate = self
        self.pointObserver.onChange = { [weak self] objects, changeType in
            guard let strongSelf = self
                else { return }
            switch changeType {
            case .insert:
                let mapped = objects.map(strongSelf.makeAnnotation)
                strongSelf._annotations.formUnion(mapped)
                strongSelf.output?.show(annotations: mapped)
            case .delete:
                let ids = Set(objects.map { $0.externalId })
                let toDelete = strongSelf._annotations.filter { ids.contains($0.id) }
                strongSelf._annotations.subtract(toDelete)
                strongSelf.output?.remove(annotations: Array(toDelete))
            default:
                break
            }
        }
        
        self.checkPartners()
    }
    deinit {
        debouncer.invalidate()
    }
    
    private let defaultRegion: MKCoordinateRegion = {
        let center = CLLocationCoordinate2D(latitude: 55.804410, longitude: 37.490461)
        return MKCoordinateRegionMakeWithDistance(center, 1000, 1000)
    }()
    
    private func makeRegion(location: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
    }
    
    private func makeAnnotation(depositionPoint: DepositionPoint) -> DepositionPointAnnotation {
        let image = imageProvider.fetchImage(depositionPoint.picture ?? "",
                                             dpi: UIScreen.main.dpi,
                                             targetSize: AnnotationView.imageSize)
        let annotation = DepositionPointAnnotation(id: depositionPoint.externalId, image: image)
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(depositionPoint.latitude),
                                                       longitude: CLLocationDegrees(depositionPoint.longitude))
        return annotation
    }
    
    private func checkPartners() {
        partnersService.fetchPartners(autoretry: true)
    }
}

// MARK: LocationServiceDelegate

extension Map: LocationServiceDelegate {
    
    func locationDidAuthorized() {
        output?.showUserLocation()
        moveToUserLocation()
    }
    
    func locationDidDenied() {
        output?.navigateTo(region: defaultRegion)
        output?.showLocatioUnavaliableAlert()
    }
}

// MARK: Input

extension Map {
    
    func checkUserLocation() {
        locationService.checkAuthorizationStatus()
    }
    
    func moveToUserLocation() {
        guard let location = locationService.location?.coordinate
            else { return }
        output?.navigateTo(region: makeRegion(location: location))
    }
    
    func fetchPoints(in area: (center: CLLocationCoordinate2D, radius: CLLocationDistance),
                     region: MKCoordinateRegion) {
        debouncer.execute { [weak self] in
            self?._fetchPoints(in: area, region: region)
        }
    }
    
    private func _fetchPoints(in area: (center: CLLocationCoordinate2D, radius: CLLocationDistance),
                             region: MKCoordinateRegion) {
        do {
            try pointObserver.observePoints(in: region)
            pointsService.fetchPoints(near: area.center, radius: area.radius)
        } catch {
            print(error)
        }
    }
}
