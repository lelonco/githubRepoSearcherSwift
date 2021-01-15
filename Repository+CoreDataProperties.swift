//
//  Repository+CoreDataProperties.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 15.01.2021.
//
//

import Foundation
import CoreData


extension Repository {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Repository> {
        return NSFetchRequest<Repository>(entityName: "Repository")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var id: Int32
    @NSManaged public var language: String?
    @NSManaged public var name: String?
    @NSManaged public var starsCount: Int32
    @NSManaged public var searchResult: SearchResult?

}

extension Repository : Identifiable {

}
