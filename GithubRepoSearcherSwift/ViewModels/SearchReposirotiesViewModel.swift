//
//  SearchReposirotiesViewModel.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 08.01.2021.
//

import CoreData
import Connectivity

class SearchReposirotiesViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private let connectivity = Connectivity()
    private var didReachable = true
    private var searchResult: SearchResult?
    var reloadUI: (() -> Void)?
    private let repoFinder: RepoFinderProtocol
    private let dbManager: DatabaseManagerProtocol

    lazy var fetchedResultController: NSFetchedResultsController<SearchResult> = {
        let request: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(SearchResult.searchRequest), ascending: false)
        request.sortDescriptors = [sort]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: self.context(),
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        return controller
    }()

    lazy var repoFetchedResultController: NSFetchedResultsController<Repository>? = nil

    init(result: SearchResult, repoFinder: RepoFinderProtocol = RepoFinder(), dbManager: DatabaseManagerProtocol = DatabaseManager.shared ) {
        self.searchResult = result
        self.repoFinder = repoFinder
        self.dbManager = dbManager
        super.init()

        completeConfiguration()
        updateAndFetchRepos()
    }

    init(_ repoFinder: RepoFinderProtocol = RepoFinder(), dbManager: DatabaseManagerProtocol = DatabaseManager.shared ) {
        self.repoFinder = repoFinder
        self.dbManager = dbManager
        super.init()
        completeConfiguration()
    }

    func completeConfiguration() {
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        configureConnectivityNotifier()
    }

    func fetchRepos(searchText: String, complition: @escaping () -> Void) throws {
        var possibleError: Error?
        let fetchReq: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "searchRequest == %@", searchText)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "searchRequest", ascending: false)]

        var savedResult: SearchResult?
        do {
            savedResult = try context().fetch(fetchReq).first
        } catch {
            throw(error)
        }
        self.searchResult = savedResult ?? SearchResult(context: context())
        self.searchResult?.searchRequest = searchText
        guard let unwrappedResult = self.searchResult else {
            throw(NSError(domain: "Cant unwrap entity", code: -999, userInfo: ["message": "Cant unwrap entity"]))
        }

        dbContainer().saveContext()
        updateAndFetchRepos()
        if !self.didReachable {
            throw(NSError(domain: "You re offline. \nYou steel can get your previous search results",
                          code: -999,
                          userInfo: ["message": "You re offline. \nYou steel can get your previous search results"]))
        }
        repoFinder.findRepositories(with: unwrappedResult, dbContainer: dbContainer()) { result in
            self.searchResult = result
            complition()
        } failure: { error in
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
                                                    managedObjectContext: self.context(),
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

        let name = repo?.fullName ?? ""
        let language = repo?.language ?? ""
        let stars = Int(repo?.starsCount ?? 0)
        return CellViewModel(titleText: name, subtitleText: language, starsCount: stars)
    }

    private func context() -> NSManagedObjectContext {
        self.dbContainer().viewContext
    }

    private func dbContainer() -> PersistentContainer {
        dbManager.persistantContainer
    }

    func title() -> String? {
        searchResult?.searchRequest
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        self.reloadUI?()
    }

    // MARK: - Table view helpers

    func numberOfRowsInSection() -> Int? {
        repoFetchedResultController?.fetchedObjects?.count
    }

    func numberOfSections() -> Int {
        1
    }

    func titleForHeaderInSection(section: Int) -> String? {
        searchResult?.searchRequest
    }
}

// MARK: - Connectivity

extension SearchReposirotiesViewModel {
    func configureConnectivityNotifier() {
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            switch connectivity.status {
            
            case .connected,
                 .connectedViaCellular,
                 .connectedViaWiFi:
                self?.didReachable = true
            case .connectedViaCellularWithoutInternet,
                 .connectedViaWiFiWithoutInternet,
                 .determining,
                 .notConnected:
                self?.didReachable = false
            }
        }
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.startNotifier()
    }
}
