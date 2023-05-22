//
//  Context.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 16.04.2023.
//

import CoreData

final class Context {
    static let shared = Context().context
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init() {
        let modelName = "TrackerCoreDataModel"
        self.persistentContainer = {
            let container = NSPersistentContainer(name: modelName)
            container.loadPersistentStores(completionHandler: { (_, error) in
                if error != nil {
                    fatalError("Can't load persistent container")
                }
            })
            return container
        }()
        
        self.context = persistentContainer.viewContext
    }
}
