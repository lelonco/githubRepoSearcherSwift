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

    func findRepositories(with entity: SearchResult,
                          context: NSManagedObjectContext,
                          success: @escaping (SearchResult) -> Void, failure: @escaping (Error) -> Void) {
        if let seatchResult = self.searchResult {
            success(seatchResult)
            return
        }
        let context = context.viewContext
        let searchResult = SearchResult(context: context)
        guard entity.searchRequest != nil  else {
            failure(NSError(domain: "Cant get search tex", code: -999, userInfo: nil))
            return
        }
        self.searchResult = entity
        context.saveContext()
        guard let path = Bundle.main.path(forResource: "JSON", ofType: "json") else {
            failure(NSError(domain: "Cant get file path", code: -999, userInfo: nil))
            return
        }
        do {
            let object = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.context!] = context
            guard let items = (try JSONSerialization.jsonObject(with: object,
                                                                options: []) as? [String: Any])?["items"] else {
                throw(NSError(domain: "Cant get items", code: -999, userInfo: nil))
            }
            let data = try JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted])

            let repo = try decoder.decode([Repository].self, from: data)
            self.searchResult?.addToResults(NSSet(array: repo))
            context.saveContext()
            self.searchResult = searchResult

            success(searchResult)

        } catch {
            failure(error)
        }
    }

    func createFakeEntity() {
        let testableDB = TestableDatabaseManager()
        let repo = Repository(context: testableDB.managedContext)
        repo.fullName = "TestRepos/TestRepo"
        repo.language = "TestLanguage"
        repo.name = "TestRepo"

        let searchResult = SearchResult(context: testableDB.managedContext)
        searchResult.searchRequest = "TestRequest"
        searchResult.addToResults(repo)
        self.searchResult = searchResult
        testableDB.saveContext()
    }

}
