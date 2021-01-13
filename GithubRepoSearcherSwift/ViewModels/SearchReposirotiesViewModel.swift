//
//  SearchReposirotiesViewModel.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 08.01.2021.
//

import Foundation
import CoreData

class SearchReposirotiesViewModel: NSObject, NSFetchedResultsControllerDelegate {

    private var searchResult: SearchResult? = nil
    var reloadUI: (() -> ())? = nil
    private let repoFinder:RepoFinderProtocol
    private let dbContainer = DatabaseManager.shared.persistantContainer
    lazy var fetchedResultController: NSFetchedResultsController<SearchResult> = {
        let request: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(SearchResult.searchRequest), ascending: false)
        request.sortDescriptors = [sort]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: self.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        return controller
    }()
    
    init(_ repoFinder: RepoFinderProtocol = RepoFinder()) {
        self.repoFinder = repoFinder

        super.init()
        fetchedResultController.delegate = self
        try! fetchedResultController.performFetch()
    }

    func fetchRepos(searchText: String) throws {
        var possibleError:Error? = nil
        repoFinder.findRepositories(with: searchText, dbContainer: dbContainer) { _ in } failure: { (error) in
            possibleError = error
        }
        if let error = possibleError {
            throw(error)
        }
    }

    func cellVM(for indexPath: IndexPath) -> CellViewModel {
        let repo = (repoFinder.searchResult?.results?.allObjects as? Array<Repository>)?[indexPath.row]
        let name = repo?.fullName ?? ""
        let language = repo?.language ?? ""
        return CellViewModel(titleText:name, subtitleText:language)
    }
    
    var context: NSManagedObjectContext = {
        DatabaseManager.shared.persistantContainer.viewContext
    }()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        self.reloadUI?()
    }

    func numberOfRowsInSection() -> Int? {
        repoFinder.searchResult?.results?.count
    }
    
    func numberOfSections() -> Int {
        1
    }
    
    
}
