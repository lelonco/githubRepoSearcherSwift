//
//  SearchResult+CoreDataProperties.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 05.01.2021.
//
//

import Foundation
import CoreData


extension SearchResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchResult> {
        return NSFetchRequest<SearchResult>(entityName: "SearchResult")
    }

    @NSManaged public var searchRequest: String?
    @NSManaged public var results: NSSet?

}

// MARK: Generated accessors for results
extension SearchResult {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Repository)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Repository)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}

extension SearchResult : Identifiable {

}
