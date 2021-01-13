//
//  DatabaseManager.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 11.01.2021.
//

import CoreData

class DatabaseManager {
    let modelName: String
    static let shared = DatabaseManager(modelName: "Model")
    
    lazy var persistantContainer: PersistentContainer = {
        let persistantContainer = PersistentContainer(name: modelName)

        persistantContainer.loadPersistentStores { (storeDescription, error) in
            self.persistantContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error: \(error.localizedDescription)")
            }
        }
        return persistantContainer
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        persistantContainer.viewContext
    }()
    func saveContext(_ managedContext: NSManagedObjectContext? = nil) {
        let context = managedContext ?? self.managedContext
        if context.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    
}
