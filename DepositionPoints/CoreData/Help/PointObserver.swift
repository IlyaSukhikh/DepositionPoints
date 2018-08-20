//
//  PointObserver.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 18/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreData
import MapKit

final class PointObserver {
    
    public enum ChangeType {
        case insert, update, delete
        
        init?(notificationObjectKey: String) {
            switch notificationObjectKey {
            case NSInsertedObjectsKey:
                self = .insert
            case NSDeletedObjectsKey:
                self = .delete
            case NSUpdatedObjectsKey:
                self = .update
            default:
                return nil
            }
        }
    }
    
    func observePoints(in region: MKCoordinateRegion) throws {
        let minLong = region.center.longitude - region.span.longitudeDelta / 2
        let maxLong = region.center.longitude + region.span.longitudeDelta / 2
        let minLat = region.center.latitude - region.span.latitudeDelta / 2
        let maxLat = region.center.latitude + region.span.latitudeDelta / 2
        self.predicate = NSPredicate(format: "(%f <= longitude) AND (longitude <= %f) AND (%f <= latitude) AND (latitude <= %f) AND partner.picture != nil", argumentArray: [minLong, maxLong, minLat, maxLat])
        try self.performFetch()
    }
    
    var onChange: ((Set<DepositionPoint>, ChangeType) -> Void)?
    
    private(set) var fetchedObjects: Set<DepositionPoint> = []
    
    private var predicate: NSPredicate?
    private let managedObjectContext: NSManagedObjectContext
    private let notificationCenter: NotificationCenter
    private var observer: NSObjectProtocol!

    public init(managedObjectContext: NSManagedObjectContext,
                notificationCenter: NotificationCenter) {
        self.managedObjectContext = managedObjectContext
        self.notificationCenter = notificationCenter
        self.observer = notificationCenter.addObserver(forName: .NSManagedObjectContextObjectsDidChange,
                                                       object: managedObjectContext,
                                                       queue: nil)
        { [weak self] notification in
            guard self?.predicate != nil else { return }
            self?.objectsDidChange(notification: notification)
        }
    }
    
    deinit {
        notificationCenter.removeObserver(observer)
    }
    
    private func performFetch() throws {
        let fetchRequest = NSFetchRequest<DepositionPoint>(entityName: DepositionPoint.entityName)
        fetchRequest.predicate = predicate
        let objects = try Set(managedObjectContext.fetch(fetchRequest))
        
        let newObjects = objects.subtracting(fetchedObjects)
        if !newObjects.isEmpty {
            onChange?(newObjects, .insert)
        }

        let unnededObjects = fetchedObjects.subtracting(objects)
        if !unnededObjects.isEmpty {
            onChange?(unnededObjects, .delete)
        }
        fetchedObjects = objects
    }
    
    private func objectsDidChange(notification: Notification) {
        
        guard !checkNewPartners(notification: notification) else {
            try? performFetch()
            return
        }
        
        self.updateCurrentObject(notification: notification, key: NSInsertedObjectsKey)
        self.updateCurrentObject(notification: notification, key: NSUpdatedObjectsKey)
        self.updateCurrentObject(notification: notification, key: NSDeletedObjectsKey)
    }
    
    private func updateCurrentObject(notification: Notification, key: String) {
        guard let allModifiedObjects = notification.userInfo?[key] as? Set<NSManagedObject>
            else { return }
        guard let changeType = ChangeType(notificationObjectKey: key)
            else { return }
        guard let predicate = self.predicate
            else { return }
        let objectsWithCorrectType: Set<DepositionPoint> = Set(allModifiedObjects.compactMap { $0 as? DepositionPoint})

        let matchingObjects = NSSet(set: objectsWithCorrectType)
            .filtered(using: predicate) as? Set<DepositionPoint> ?? []
        
        switch changeType {
        case .insert:
            fetchedObjects.formUnion(matchingObjects)
        case .delete:
            fetchedObjects.subtract(objectsWithCorrectType)
        case .update:
            // добавим обновленные объекты которые теперь подходят под предикат
            // и удалим которе больше под него не попадают
            let new = fetchedObjects.symmetricDifference(matchingObjects)
            fetchedObjects.formUnion(matchingObjects)
            onChange?(new, .insert)

            let toDelete = fetchedObjects.subtracting(matchingObjects)
            fetchedObjects.subtract(toDelete)
            onChange?(toDelete, .delete)
        }
        onChange?(matchingObjects, changeType)
    }
    
    private func checkNewPartners(notification: Notification) -> Bool {
        guard let allModifiedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            else { return false }
        return allModifiedObjects.first { obj in
            guard let partner = obj as? Partner
                else { return false }
            return !partner.isBlank
        } != nil
    }
}

extension PointObserver.ChangeType: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .delete:
            return "objects deleted"
        case .update:
            return "objects updated"
        case .insert:
            return "new objects inserted"
        }
    }
}
