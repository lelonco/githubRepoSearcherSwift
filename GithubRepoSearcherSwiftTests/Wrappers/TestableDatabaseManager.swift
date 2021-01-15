//
//  TestableDatabaseManager.swift
//  GithubRepoSearcherSwiftTests
//
//  Created by Yaroslav on 13.01.2021.
//

import Foundation
import CoreData
@testable import GithubRepoSearcherSwift

class TestableDatabaseManager: DatabaseManager {

    convenience init() {
        self.init(modelName: "Model")
    }

    override init(modelName: String) {
        super.init(modelName: modelName)

        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType

        let container = PersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [persistentStoreDescription]

        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)")
            }
        }
        self.persistantContainer = container
        self.managedContext = container.viewContext
    }

}
