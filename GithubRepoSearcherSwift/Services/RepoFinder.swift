//
//  RepoFinder.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 13.01.2021.
//

import Foundation

protocol RepoFinderProtocol {
    var searchResult:SearchResult? { get }
    func findRepositories(with text: String, dbContainer: PersistentContainer , success:@escaping (SearchResult) -> Void, failure:@escaping (Error) -> Void)
}

class RepoFinder: RepoFinderProtocol {
    var searchResult: SearchResult?
    
    private let networkManager = NetworkManager.shared

    func findRepositories(with text: String, dbContainer: PersistentContainer, success:@escaping (SearchResult) -> Void, failure: @escaping (Error) -> Void) {
        let context = dbContainer.viewContext
        self.searchResult = SearchResult(context: context)
        self.searchResult?.searchRequest = text
        dbContainer.saveContext()
        
        let request = RequestBuilder.searchRepo(text: text)
        let decoder = JSONDecoder()
        networkManager.makeRequest(request, success: { (response, object) in
            decoder.userInfo[CodingUserInfoKey.context!] =  context
            do {
                guard let items = (try JSONSerialization.jsonObject(with: object as! Data, options: []) as? [String:Any])?["items"] else {
                    throw(NSError(domain: "Cant get items", code: -999, userInfo: nil))
                }
                let data = try JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted])

                let repo = try decoder.decode([Repository].self, from: data)
                self.searchResult?.addToResults(NSSet(array: repo))
                dbContainer.saveContext()
            } catch {
                failure(error)
            }
        }, failure: failure)
    }
    
    
}
