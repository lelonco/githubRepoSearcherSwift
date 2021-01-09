//
//  SearchReposirotiesViewModel.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 08.01.2021.
//

import Foundation
import CoreData

class SearchReposirotiesViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private var persistantContainer: NSPersistentContainer!
    private let networkManager = NetworkManager.shared
    private var searchResult: SearchResult? = nil
    var reloadUI: (() -> ())? = nil
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
    
    override init() {
        super.init()
        persistantContainer = NSPersistentContainer(name: "Model")

        persistantContainer.loadPersistentStores { (storeDescription, error) in
            self.persistantContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error: \(error.localizedDescription)")
            }
        }
        fetchedResultController.delegate = self
        try! fetchedResultController.performFetch()
    }

    func fetchRepos(searchText: String) {
//        findFakeRepos()
        self.searchResult = SearchResult(context: self.persistantContainer.viewContext)
        self.searchResult?.searchRequest = searchText
        self.saveContext()
        
        let request = RequestBuilder.searchRepo(text: searchText)
        let decoder = JSONDecoder()
        networkManager.makeRequest(request) { (response, object) in
            decoder.userInfo[CodingUserInfoKey.context!] = self.persistantContainer.viewContext
            let items = (try! JSONSerialization.jsonObject(with: object as! Data, options: []) as? [String:Any])?["items"]
            let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted])

            let repo = try! decoder.decode([Repository].self, from: data!)
            self.searchResult?.addToResults(NSSet(array: repo))
            print(repo)
            print(try! JSONSerialization.jsonObject(with: object as! Data, options: []))
            self.saveContext()

        } failure: { (error) in
            assertionFailure(error.localizedDescription)
        }
    }
    func findFakeRepos() {
        self.searchResult = SearchResult(context: self.persistantContainer.viewContext)
        self.searchResult?.searchRequest = "albion"
        self.saveContext()
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (_) in

            let path = Bundle.main.path(forResource: "JSON", ofType: "json")
            let object = try! Data(contentsOf: URL(fileURLWithPath: path!) , options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.context!] = self.persistantContainer.viewContext
            let items = (try! JSONSerialization.jsonObject(with: object as! Data, options: []) as? [String:Any])?["items"]
            let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted])
            
            let repo = try! decoder.decode([Repository].self, from: data!)
            self.searchResult?.addToResults(NSSet(array: repo))
            print(repo)
            print(try! JSONSerialization.jsonObject(with: object as! Data, options: []))
            self.saveContext()
            //        try! fetchedResultController.performFetch()
            print(self.fetchedResultController.sections)
        }
    }
    
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }

    func cellVM(for indexPath: IndexPath) -> RepostiryCellViewModel {
        let repo = (searchResult?.results?.allObjects as? Array<Repository>)?[indexPath.row]
        let name = repo?.fullName ?? ""
        let language = repo?.language ?? ""
        return RepostiryCellViewModel(fullName:name, language:language)
    }
    
    func context() -> NSManagedObjectContext {
        self.persistantContainer.viewContext
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        self.reloadUI?()
    }

    func numberOfRowsInSection() -> Int {
        searchResult?.results?.count ?? 0
    }
    
    func numberOfSections() -> Int {
        1
    }
    
    
}
