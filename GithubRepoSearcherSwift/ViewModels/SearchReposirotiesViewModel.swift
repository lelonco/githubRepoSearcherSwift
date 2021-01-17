//
//  SearchReposirotiesViewModel.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 08.01.2021.
//

import MagicalRecord
import Connectivity

class SearchReposirotiesViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private let connectivity: Connectivity = Connectivity()
    private var didReachable = true
    private var searchResult: SearchResult?
    var reloadUI: (() -> Void)?
    private let repoFinder: RepoFinderProtocol
//    private let dbContainer = DatabaseManager.shared.persistantContainer
    lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = SearchResult.mr_createFetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(SearchResult.searchRequest), ascending: false)
        request.sortDescriptors = [sort]
        let controller = SearchResult.mr_fetchController(request,
                                                         delegate: self,
                                                         useFileCache: false,
                                                         groupedBy: nil,
                                                         in: NSManagedObjectContext.mr_default())
        return controller
    }()

    lazy var repoFetchedResultController: NSFetchedResultsController<NSFetchRequestResult>? = nil

    init(result: SearchResult, repoFinder: RepoFinderProtocol = RepoFinder()) {
        self.searchResult = result
        self.repoFinder = repoFinder
        super.init()

        completeConfiguration()
        updateAndFetchRepos()
    }

    init(_ repoFinder: RepoFinderProtocol = RepoFinder()) {
        self.repoFinder = repoFinder

        super.init()
        completeConfiguration()
    }

    func completeConfiguration() {
//        fetchedResultController.delegate = self
        SearchResult.mr_performFetch(fetchedResultController)
//        try? fetchedResultController.performFetch()
        configureConnectivityNotifier()
    }

    func fetchRepos(searchText: String, complition: @escaping () -> Void) throws {
        var possibleError: Error?
        let fetchReq: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "searchRequest == %@", searchText)
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "searchRequest", ascending: false)]

        var savedResult: SearchResult?
        do {
            savedResult = try context.fetch(fetchReq).first
        } catch {
            throw(error)
        }
        self.searchResult = savedResult ?? SearchResult(context: context)
        self.searchResult?.searchRequest = searchText
        guard let unwrappedResult = self.searchResult else {
            throw(NSError(domain: "Cant unwrap entity", code: -999, userInfo: ["message": "Cant unwrap entity"]))
        }

        do {
            try self.context.save()
        } catch {
            throw(error)
        }
//        dbContainer.saveContext()
        updateAndFetchRepos()
        if !self.didReachable {
            throw(NSError(domain: "You re offline. \nYou steel can get your previous search results",
                          code: -999,
                          userInfo: ["message": "You re offline. \nYou steel can get your previous search results"]))
        }
        repoFinder.findRepositories(with: unwrappedResult, context: self.context) { result in
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
        let request = Repository.mr_requestAllSorted(by: "starsCount", ascending: false)
//        let sort = NSSortDescriptor(key: #keyPath(Repository.starsCount), ascending: false)
//        request.sortDescriptors = [sort]
        request.fetchLimit = 30
        let objectId = result.objectID
        request.predicate = NSPredicate(format: "searchResult == %@", objectId)
        let controller = Repository.mr_fetchController(request,
                                                       delegate: self,
                                                       useFileCache: false,
                                                       groupedBy: nil,
                                                       in: self.context)
        self.repoFetchedResultController = controller
    }

    func observeRepoFetchedResults() {
        guard let controller = self.repoFetchedResultController else { return }
        Repository.mr_performFetch(controller)
    }
    func cellviewModel(for indexPath: IndexPath) -> CellViewModel {
        let repo = repoFetchedResultController?.fetchedObjects?[indexPath.row] as? Repository

        let name = repo?.fullName ?? ""
        let language = repo?.language ?? ""
        let stars = Int(repo?.starsCount ?? 0)
        return CellViewModel(titleText: name, subtitleText: language, starsCount: stars)
    }

    var context: NSManagedObjectContext = {
        NSManagedObjectContext.mr_default()
    }()

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
