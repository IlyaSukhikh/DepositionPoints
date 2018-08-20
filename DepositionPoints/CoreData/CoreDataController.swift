//
//  CoreDataController.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataController {
    
    init() {
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DepositionPoints")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext { return self.persistentContainer.viewContext }
    
    func performBackgroundTaskAndSave(_ task: @escaping (NSManagedObjectContext) -> Void ) {
        self.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            task(context)
            do { try context.save() }
            catch { print(error) }
        }
    }
}
