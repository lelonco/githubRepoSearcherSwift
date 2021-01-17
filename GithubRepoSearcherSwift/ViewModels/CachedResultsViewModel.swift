//
//  CachedResultsViewModel.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 10.01.2021.
//

import Foundation
import MagicalRecord
class CachedResultsViewModel: NSObject {

    private var searchResults: [SearchResult] = []

    private lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = SearchResult.mr_requestAllSorted(by: "searchRequest", ascending: false)
        let context = NSManagedObjectContext.mr_default()
        let controller = SearchResult.mr_fetchController(request,
                                                         delegate: self,
                                                         useFileCache: false,
                                                         groupedBy: nil,
                                                         in: context)
        return controller
    }()

    var reloadUI: (() -> Void)?

    override init() {
        super.init()
        fetchCachedResults()
    }

    func fetchCachedResults() {
        SearchResult.mr_performFetch(fetchedResultController)
        searchResults = (fetchedResultController.fetchedObjects as? [SearchResult]) ?? []
    }

    func cellviewModel(for indexPath: IndexPath) -> CellViewModel {
        let result = searchResults[indexPath.row]
        let name = result.searchRequest ?? "Can't find text of search request "
        let resultsText = "\((result.results?.count ?? 0)) was found"
//        let stars = result.starsCount ?? 0

        return CellViewModel(titleText: name, subtitleText: resultsText, starsCount: nil)
    }

    func viewModel(for indexPath: IndexPath) -> SearchReposirotiesViewModel {
        SearchReposirotiesViewModel(result: searchResults[indexPath.row])
    }

    // MARK: - Table view helpers

    func numberOfRowsInSection() -> Int {
        searchResults.count
    }

    func numberOfSections() -> Int {
        1
    }

    func titleForHeaderInSection(section: Int) -> String {
        return ""
    }
}

extension CachedResultsViewModel: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        self.reloadUI?()
    }
}
