//
//  ManagedObject.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreData

open class ManagedObject: NSManagedObject {}

public protocol ManagedObjectType: NSFetchRequestResult {
    static var entityName: String { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}

public protocol DefaultManagedObjectType: ManagedObjectType {}

public extension ManagedObjectType {
    
    public static var entityName: String { return String(describing: self) }
}

public extension ManagedObjectType where Self: ManagedObject {
    
    public static func findOrCreateInContext(moc: NSManagedObjectContext,
                                             matchingPredicate predicate: NSPredicate,
                                             configure: ((Self) -> Void)? = nil) -> Self {
        guard let obj = findOrFetchInContext(moc: moc, matchingPredicate: predicate) else {
            return self.createInContext(moc: moc, configure: configure)
        }
        return obj
    }
    
    public static func createInContext(moc: NSManagedObjectContext,
                                       configure: ((Self) -> Void)? = nil) -> Self {
        let newObject: Self = moc.insertObject()
        configure?(newObject)
        return newObject
    }
    
    public static func findOrFetchInContext(moc: NSManagedObjectContext,
                                            matchingPredicate predicate: NSPredicate) -> Self? {
        guard let obj = materializedObjectInContext(moc: moc, matchingPredicate: predicate) else {
            return fetchInContext(context: moc) { request in
                request.predicate = predicate
                request.fetchLimit = 1
                }.first
        }
        return obj
    }
    
    public static func fetchInContext(context: NSManagedObjectContext,
                                      matchingPredicate predicate: NSPredicate) -> [Self] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        request.predicate = predicate
        guard let result = try! context.fetch(request) as? [Self] else {
            fatalError("Fetched objects have wrong type")
        }
        return result
    }
    
    public static func fetchInContext(context: NSManagedObjectContext,
                                      configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> Void = { _ in }) -> [Self] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        configurationBlock(request)
        do {
            let fetchResult = try context.fetch(request)
            guard let result = fetchResult as? [Self] else { fatalError("Fetched objects have wrong type") }
            return result
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    internal static func materializedObjectInContext(moc: NSManagedObjectContext,
                                                     matchingPredicate predicate: NSPredicate) -> Self? {
        for obj in moc.registeredObjects where !obj.isFault && !obj.isDeleted {
            guard let res = obj as? Self, predicate.evaluate(with: res) else { continue }
            return res
        }
        return nil
    }
}

public extension NSManagedObjectContext {
    
    public func insertObject<A: ManagedObject>() -> A where A: ManagedObjectType {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }
}
