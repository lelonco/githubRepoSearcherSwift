//
//  TestRepositoryParse.swift
//  GithubRepoSearcherSwiftTests
//
//  Created by Yaroslav on 14.01.2021.
//

import XCTest
@testable import GithubRepoSearcherSwift

class TestRepositoryParse: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecode() throws {
        let dbManager = TestableDatabaseManager()
        let context = dbManager.managedContext
        guard let path = Bundle.main.path(forResource: "JSON", ofType: "json") else {
            throw(NSError(domain: "Cant get file path", code: -999, userInfo: nil))
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
            XCTAssert(repo.count == 2, "Expected count: 2, but found: \(repo.count)")
            XCTAssert(repo.first?.fullName == "franciscojt/albion", "Expected count: franciscojt/albion, but found: " + (repo.first?.fullName ?? "nil"))
            XCTAssert(repo.first?.language == "Ruby", "Expected count: Ruby, but found: " + (repo.first?.language ?? "nil"))
            XCTAssert(repo.first?.name == "albion", "Expected count: albion, but found: " + (repo.first?.name ?? "nil"))

            XCTAssert(repo.last?.fullName == "HebasTheDemonic/AlbionAssistant", "Expected count: HebasTheDemonic/AlbionAssistant, but found: " + (repo.last?.fullName ?? "nil"))
            XCTAssert(repo.last?.language == "C#", "Expected count: C#, but found: " + (repo.last?.language ?? "nil"))
            XCTAssert(repo.last?.name == "AlbionAssistant", "Expected count: AlbionAssistant, but found: " + (repo.last?.name ?? "nil"))

        } catch {
            XCTAssertThrowsError(error)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            let dbManager = TestableDatabaseManager()
            let context = dbManager.managedContext
            guard let path = Bundle.main.path(forResource: "JSON", ofType: "json") else { return }
            guard let object = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else { return}
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.context!] = context
            guard let items = (try? JSONSerialization.jsonObject(with: object,
                                                                 options: []) as? [String: Any])?["items"] else {
                return
            }
            guard let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted]) else {
                return
            }

            _ = try? decoder.decode([Repository].self, from: data)
        }
    }

}
