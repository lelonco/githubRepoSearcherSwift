//
//  DatabaseManager.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 11.01.2021.
//

import CoreData

protocol DatabaseManagerProtocol {
    var persistantContainer: PersistentContainer { get }
    var managedContext: NSManagedObjectContext { get }
    func saveContext(_ managedContext: NSManagedObjectContext?)
}

extension DatabaseManagerProtocol {
    func saveContext(_ managedContext: NSManagedObjectContext? = nil) {
        persistantContainer.saveContext()
    }
}

class DatabaseManager: DatabaseManagerProtocol {
    let modelName: String
    static let shared = DatabaseManager(modelName: "Model")

    lazy var persistantContainer: PersistentContainer = {
        let persistantContainer = PersistentContainer(name: modelName)

        persistantContainer.loadPersistentStores { _, error in
            persistantContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                fatalError("Unresolved error: \(error.localizedDescription)")
            }
        }
        return persistantContainer
    }()

    lazy var managedContext: NSManagedObjectContext = {
        persistantContainer.viewContext
    }()

    init(modelName: String) {
        self.modelName = modelName
    }
}
