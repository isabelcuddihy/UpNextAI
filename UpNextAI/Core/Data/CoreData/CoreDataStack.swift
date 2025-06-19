//
//  CoreDataStack.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/16/25.
//

import Foundation
import CoreData

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UpNextAI") // This should match your .xcdatamodeld file name
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, you'd want better error handling
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        // Automatically merge changes from parent
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Contexts
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Core Data Saving
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        
        context.perform {
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Background save error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Preview Support (for SwiftUI previews)
    static var preview: CoreDataStack = {
        let stack = CoreDataStack()
        
        // Create in-memory store for previews
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        stack.persistentContainer.persistentStoreDescriptions = [description]
        
        // Load the store
        stack.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Preview Core Data error: \(error)")
            }
        }
        
        return stack
    }()
}
