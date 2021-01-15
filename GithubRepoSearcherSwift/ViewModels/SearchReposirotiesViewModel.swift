//
//  SearchReposirotiesViewModel.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 08.01.2021.
//

import Foundation
import CoreData

class SearchReposirotiesViewModel: NSObject, NSFetchedResultsControllerDelegate {

    private var searchResult: SearchResult?
    var reloadUI: (() -> Void)?
    private let repoFinder: RepoFinderProtocol
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

    lazy var repoFetchedResultController: NSFetchedResultsController<Repository>? = nil

    init(result: SearchResult, repoFinder: RepoFinderProtocol = RepoFinder()) {
        self.searchResult = result
        self.repoFinder = repoFinder
        super.init()
    }

    init(_ repoFinder: RepoFinderProtocol = RepoFinder()) {
        self.repoFinder = repoFinder

        super.init()
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
    }

    func fetchRepos(searchText: String) throws {
        var possibleError: Error?
        let fetchReq: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "searchRequest == %@", searchText)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "searchRequest", ascending: false)]

            //        request.predicate()
        var savedResult: SearchResult?
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
        updateAndFetchRepos()
        repoFinder.findRepositories(with: unwrappedResult, dbContainer: dbContainer) { result in
            self.searchResult = result
        } failure: { (error) in
            possibleError = error
        }
        if let error = possibleError {
            throw(error)
        }
    }

    func updateAndFetchRepos() {
        createRepoFetchedResults()
        observeRepoFetchedResults()
    }

    func createRepoFetchedResults() {
        guard let result = self.searchResult else { return }
        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(Repository.starsCount), ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 30
        let objectId = result.objectID
        request.predicate = NSPredicate(format: "searchResult == %@", objectId)
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: self.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        self.repoFetchedResultController = controller
    }

    func observeRepoFetchedResults() {
        repoFetchedResultController?.delegate = self
        try? repoFetchedResultController?.performFetch()
    }
    func cellviewModel(for indexPath: IndexPath) -> CellViewModel {
        let repo = repoFetchedResultController?.fetchedObjects?[indexPath.row]

//        let repo = (searchResult?.results?.allObjects as? Array<Repository>)?[indexPath.row]
        let name = repo?.fullName ?? ""
        let language = repo?.language ?? ""
        let stars = Int(repo?.starsCount ?? 0)
        return CellViewModel(titleText: name, subtitleText: language, starsCount: stars)
    }

    var context: NSManagedObjectContext = {
        DatabaseManager.shared.persistantContainer.viewContext
    }()

    func title() -> String? {
        searchResult?.searchRequest
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        self.reloadUI?()
    }

    func numberOfRowsInSection() -> Int? {
        repoFetchedResultController?.fetchedObjects?.count
//        searchResult?.results?.count
    }

    func numberOfSections() -> Int {
        1
    }

    func titleForHeaderInSection(section: Int) -> String? {
        searchResult?.searchRequest
    }

}
