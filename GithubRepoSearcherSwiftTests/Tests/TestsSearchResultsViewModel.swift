//
//  TestsSearchResultsViewModel.swift
//  GithubRepoSearcherSwiftTests
//
//  Created by Yaroslav on 13.01.2021.
//

import XCTest
@testable import GithubRepoSearcherSwift

class TestsSearchResultsViewModel: XCTestCase {

    var dbManager:TestableDatabaseManager?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dbManager = TestableDatabaseManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dbManager = nil
    }

    func testFetch() throws {
        let fakeRepoFinder = TestableRepoFinder()
        let testVM = SearchReposirotiesViewModel(fakeRepoFinder)

        XCTAssertNoThrow(try testVM.fetchRepos(searchText: "Test"))
    }
    func testNumberOfRows() throws {
        let fakeRepoFinder = TestableRepoFinder()
        fakeRepoFinder.createFakeEntity()
        let testVM = SearchReposirotiesViewModel(fakeRepoFinder)
       XCTAssert(testVM.numberOfRowsInSection() == 1, "Expected 1 row")
    }
    
    func testNumberOfSections() throws {
        let fakeRepoFinder = TestableRepoFinder()
        fakeRepoFinder.createFakeEntity()
        let testVM = SearchReposirotiesViewModel(fakeRepoFinder)
       XCTAssert(testVM.numberOfSections() == 1, "Expected 1 section")
    }
    
    func testCellVM() throws {
        let fakeRepoFinder = TestableRepoFinder()
        fakeRepoFinder.createFakeEntity()
        let testVM = SearchReposirotiesViewModel(fakeRepoFinder)
        let cellVM = testVM.cellVM(for: IndexPath(row: 0, section: 0))
        
        XCTAssert(cellVM.titleText == "TestRepos/TestRepo", "Unexpected value")
        XCTAssert(cellVM.subtitleText == "TestLanguage", "Unexpected value")
        
    }
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
