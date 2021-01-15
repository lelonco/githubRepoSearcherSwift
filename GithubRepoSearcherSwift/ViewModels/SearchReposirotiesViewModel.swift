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
    
    init(result:SearchResult, repoFinder: RepoFinderProtocol = RepoFinder()) {
        self.searchResult = result
        self.repoFinder = repoFinder
        super.init()
    }
    
    init(_ repoFinder: RepoFinderProtocol = RepoFinder()) {
        self.repoFinder = repoFinder

        super.init()
        fetchedResultController.delegate = self
        try! fetchedResultController.performFetch()
    }

    func fetchRepos(searchText: String) throws {
        var possibleError:Error? = nil
        let fetchReq: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "searchRequest == %@", searchText)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "searchRequest", ascending: false)]
        
            //        request.predicate()
        var savedResult: SearchResult? = nil
        do {
            savedResult = try context.fetch(fetchReq).first
        } catch {
            throw(error)
        }
        self.searchResult = savedResult ?? SearchResult(context: context)
        self.searchResult?.searchRequest = searchText
        guard let unwrappedResult = self.searchResult else {
            throw(NSError(domain: "Cant unwrap entity", code: -999, userInfo: nil))
        }
        dbContainer.saveContext()
        repoFinder.findRepositories(with: unwrappedResult, dbContainer: dbContainer) { result in
            self.searchResult = result
        } failure: { (error) in
            possibleError = error
        }
        if let error = possibleError {
            throw(error)
        }
    }

    func cellVM(for indexPath: IndexPath) -> CellViewModel {
        let repo = (searchResult?.results?.allObjects as? Array<Repository>)?[indexPath.row]
        let name = repo?.fullName ?? ""
        let language = repo?.language ?? ""
        let stars = Int(repo?.starsCount ?? 0)
        return CellViewModel(titleText:name, subtitleText:language,starsCount: stars)
    }
    
    var context: NSManagedObjectContext = {
        DatabaseManager.shared.persistantContainer.viewContext
    }()
    
    func title() -> String? {
        searchResult?.searchRequest
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        self.reloadUI?()
    }

    func numberOfRowsInSection() -> Int? {
        searchResult?.results?.count
    }
    
    func numberOfSections() -> Int {
        1
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        searchResult?.searchRequest
    }
    
    
}
