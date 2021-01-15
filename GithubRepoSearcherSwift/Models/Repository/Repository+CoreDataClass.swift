//
//  Repository+CoreDataClass.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 05.01.2021.
//
//

import Foundation
import CoreData

public class Repository: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case name
        case language
        case fullName = "full_name"
        case id
        case starsCount = "stargazers_count"
    }

    required convenience public init(from decoder: Decoder) throws {
        // return the context from the decoder userinfo dictionary
        guard let contextUserInfoKey = CodingUserInfoKey.context,
              let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "Repository", in: managedObjectContext)
        else {
            let error = NSError(domain: "Decode failure", code: -999, userInfo: nil)
            throw(error)
        }
        // Super init of the NSManagedObject
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.id = try values.decode(Int32.self, forKey: .id)
            self.name = try values.decode(String.self, forKey: .name)
            self.language = (try? values.decode(String.self, forKey: .language)) ?? "Can't find language :("
            self.fullName = (try? values.decode(String.self, forKey: .fullName))  ?? "Can't find name :("
            self.starsCount = try values.decode(Int32.self, forKey: .starsCount)
        } catch {
            print("error")
        }
    }
}
