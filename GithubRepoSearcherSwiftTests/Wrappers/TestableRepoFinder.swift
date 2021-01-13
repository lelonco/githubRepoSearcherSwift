//
//  TestableRepoFinder.swift
//  GithubRepoSearcherSwiftTests
//
//  Created by Yaroslav on 13.01.2021.
//

import Foundation
import CoreData
@testable import GithubRepoSearcherSwift

class TestableRepoFinder: RepoFinderProtocol {
    var searchResult: SearchResult?

    func findRepositories(with text: String, dbContainer: PersistentContainer, success: @escaping (SearchResult) -> Void, failure: @escaping (Error) -> Void) {
        let context = dbContainer.viewContext
        let searchResult = SearchResult(context: context)
        searchResult.searchRequest = text
        dbContainer.saveContext()
        guard let path = Bundle.main.path(forResource: "JSON", ofType: "json") else {
            failure(NSError(domain: "Cant get file path", code: -999, userInfo: nil))
            return
        }
        do {
            let object = try Data(contentsOf: URL(fileURLWithPath: path) , options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.context!] = context
            guard let items = (try JSONSerialization.jsonObject(with: object, options: []) as? [String:Any])?["items"] else {
                throw(NSError(domain: "Cant get items", code: -999, userInfo: nil))
            }
            let data = try JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted])
            
            let repo = try decoder.decode([Repository].self, from: data)
            self.searchResult?.addToResults(NSSet(array: repo))
            dbContainer.saveContext()
            self.searchResult = searchResult

            success(searchResult)

        } catch {
            failure(error)
        }
    }

    func createFakeEntity() {
        let db = TestableDatabaseManager()
        let repo = Repository(context: db.managedContext)
        repo.fullName = "TestRepos/TestRepo"
        repo.language = "TestLanguage"
        repo.name = "TestRepo"
        
        let searchResult = SearchResult(context: db.managedContext)
        searchResult.searchRequest = "TestRequest"
        searchResult.addToResults(repo)
        self.searchResult = searchResult
        db.saveContext()
    }

}
