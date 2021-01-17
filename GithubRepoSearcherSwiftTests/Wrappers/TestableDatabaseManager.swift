//
//  TestableDatabaseManager.swift
//  GithubRepoSearcherSwiftTests
//
//  Created by Yaroslav on 13.01.2021.
//

import Foundation
import CoreData
@testable import GithubRepoSearcherSwift

class TestableDatabaseManager: DatabaseManagerProtocol {
    static let shared = TestableDatabaseManager(modelName: "Model")

    let modelName: String
    lazy var persistantContainer: PersistentContainer = {
        let persistantContainer = PersistentContainer(name: modelName)
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        persistantContainer.persistentStoreDescriptions = [persistentStoreDescription]

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
    

    convenience init() {
        self.init(modelName: "Model")
        
    }

     init(modelName: String) {
        self.modelName = modelName
    }

}
