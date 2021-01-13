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
    
    lazy var fetchedResultController: NSFetchedResultsController<SearchResult> = {
        let request: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(SearchResult.searchRequest), ascending: false)
        request.sortDescriptors = [sort]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: DatabaseManager.shared.persistantContainer.newBackgroundContext(),
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        return controller
    }()
    
    var reloadUI: (() -> ())? = nil

    override init() {
        super.init()
        fetchedResultController.delegate = self
        try! fetchedResultController.performFetch()
        searchResults.append(contentsOf: fetchedResultController.fetchedObjects ?? []) 
    }
    
    func cellVM(for indexPath: IndexPath) -> CellViewModel {
        let result = searchResults[indexPath.row]
        let name = result.searchRequest ?? "Can't find text of search request "
        let resultsText = "\((result.results?.count ?? 0)) was found"
        return CellViewModel(titleText:name, subtitleText:resultsText)
    }

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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        self.reloadUI?()
    }
}
