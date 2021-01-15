//
//  RepoFinder.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 13.01.2021.
//

import Foundation
import CoreData
protocol RepoFinderProtocol {
    var searchResult:SearchResult? { get }
    func findRepositories(with entity: SearchResult, dbContainer: PersistentContainer , success:@escaping (SearchResult) -> Void, failure:@escaping (Error) -> Void)
}

class RepoFinder: RepoFinderProtocol {
    var searchResult: SearchResult?
    
    private let networkManager = NetworkManager.shared

    func findRepositories(with entity: SearchResult, dbContainer: PersistentContainer, success:@escaping (SearchResult) -> Void, failure: @escaping (Error) -> Void) {
        let context = dbContainer.viewContext
        guard let text = entity.searchRequest else {
            failure(NSError(domain: "Cant get search tex", code: -999, userInfo: nil))
            return
        }
        self.searchResult = entity
        let request = RequestBuilder.searchRepo(text: text)
        let decoder = JSONDecoder()
        networkManager.makeRequest(request, success: { (response, object) in
            decoder.userInfo[CodingUserInfoKey.context!] =  context
            do {
                guard let items = (try JSONSerialization.jsonObject(with: object as! Data, options: []) as? [String:Any])?["items"] else {
                    throw(NSError(domain: "Cant get items", code: -999, userInfo: nil))
                }
                let data = try JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted])
//                print(try JSONSerialization.jsonObject(with: object as! Data, options: []) as? [String:Any])
//                print(String(data: data, encoding: .utf8))
                let repo = try decoder.decode([Repository].self, from: data)
                entity.addToResults(NSSet(array: repo))
                dbContainer.saveContext()
            } catch {
                failure(error)
            }
        }, failure: failure)
    }
    
    
}
