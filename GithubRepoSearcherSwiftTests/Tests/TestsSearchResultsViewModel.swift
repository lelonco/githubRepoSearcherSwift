//
//  TestsSearchResultsViewModel.swift
//  GithubRepoSearcherSwiftTests
//
//  Created by Yaroslav on 13.01.2021.
//

import XCTest
@testable import GithubRepoSearcherSwift

class TestsSearchResultsViewModel: XCTestCase {

    var dbManager: TestableDatabaseManager!
    var fakeRepoFinder: TestableRepoFinder!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dbManager = TestableDatabaseManager.shared
        fakeRepoFinder = TestableRepoFinder(dbManager: dbManager)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dbManager = nil
        fakeRepoFinder = nil
    }

    func testFetch() throws {

        let testviewModel = SearchReposirotiesViewModel(fakeRepoFinder, dbManager: dbManager)

        XCTAssertNoThrow(try testviewModel.fetchRepos(searchText: "Test", complition: {}))
    }
    func testNumberOfRows() throws {
        fakeRepoFinder.createFakeEntity()
        let testviewModel = SearchReposirotiesViewModel(fakeRepoFinder, dbManager: dbManager)
        XCTAssertNoThrow(try testviewModel.fetchRepos(searchText: "TestRequest", complition: {}))
        XCTAssert(testviewModel.numberOfRowsInSection() == 1, "Expected 1 row")
    }

    func testNumberOfSections() throws {

        fakeRepoFinder.createFakeEntity()
        let testviewModel = SearchReposirotiesViewModel(fakeRepoFinder, dbManager: dbManager)
       XCTAssert(testviewModel.numberOfSections() == 1, "Expected 1 section")
    }

    func testCellviewModel() throws {
        fakeRepoFinder.createFakeEntity()
        let testviewModel = SearchReposirotiesViewModel(fakeRepoFinder, dbManager: dbManager)
        XCTAssertNoThrow(try testviewModel.fetchRepos(searchText: "TestRequest", complition: {}))
        let cellviewModel = testviewModel.cellviewModel(for: IndexPath(row: 0, section: 0))

        XCTAssert(cellviewModel.titleText == "TestRepos/TestRepo", "Unexpected value")
        XCTAssert(cellviewModel.subtitleText == "TestLanguage", "Unexpected value")

    }
}
