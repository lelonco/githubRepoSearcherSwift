//
//  CachedResultsViewModel.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 10.01.2021.
//

import Foundation
import CoreData
class CachedResultsViewModel: NSObject {

    private var searchResults: [SearchResult] = []

    private lazy var fetchedResultController: NSFetchedResultsController<SearchResult> = {
        let request: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(SearchResult.searchRequest), ascending: false)
        let context = DatabaseManager.shared.persistantContainer.viewContext
        request.sortDescriptors = [sort]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        return controller
    }()

    var reloadUI: (() -> Void)?

    override init() {
        super.init()
        fetchedResultController.delegate = self
        fetchCachedResults()
    }

    func fetchCachedResults() {
        try? fetchedResultController.performFetch()
        searchResults = fetchedResultController.fetchedObjects ?? []
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
