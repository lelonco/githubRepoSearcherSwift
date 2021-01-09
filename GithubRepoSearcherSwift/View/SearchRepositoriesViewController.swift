//
//  SearchRepositoriesViewController.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 03.01.2021.
//

import UIKit
import CoreData

class SearchRepositoriesViewController: UITableViewController {
    var searchVM: SearchResult? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    lazy var searchBar = UISearchBar(frame: .zero)
    

    init() {
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        searchBar.placeholder = "Enter repository name"
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(makeRequest))

//        makeRequest()
//        try! fetchedResultController.performFetch()
        
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Celll")
        self.tableView.separatorStyle = .none
        view.backgroundColor = .green
        // Do any additional setup after loading the view.
    }
    @objc
    func makeRequest() {
        
//        findFakeRepos()
//        findRepos()
        
    }
//    func findFakeRepos() {
//        let path = Bundle.main.path(forResource: "JSON", ofType: "json")
//        let object = try! Data(contentsOf: URL(fileURLWithPath: path!) , options: .mappedIfSafe)
//        let decoder = JSONDecoder()
//        decoder.userInfo[CodingUserInfoKey.context!] = self.persistantContainer.viewContext
//        let items = (try! JSONSerialization.jsonObject(with: object as! Data, options: []) as? [String:Any])?["items"]
//        let data = try? JSONSerialization.data(withJSONObject: items, options: [.prettyPrinted])
//
//        let repo = try! decoder.decode([Repository].self, from: data!)
//        let searchResult = SearchResult(context: self.persistantContainer.viewContext)
//        searchResult.searchRequest = "albion"
//        searchResult.addToResults(NSSet(array: repo))
//        print(repo)
//        print(try! JSONSerialization.jsonObject(with: object as! Data, options: []))
//        self.saveContext()
//        try! fetchedResultController.performFetch()
//        print(fetchedResultController.sections)
//    }

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchVM?.results?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Celll")
//        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Celll")
        
        let repos = (searchVM?.results?.allObjects as? Array<Repository>)
        
        cell!.textLabel?.text = repos?[indexPath.row].fullName
        cell!.detailTextLabel?.text = repos?[indexPath.row].language
        cell!.imageView?.image = UIImage(systemName: "repeat.circle.fill")
        cell?.accessoryView = UIImageView(image: UIImage(systemName: "paperplane.circle.fill"))
        return cell!
    }
}

extension SearchRepositoriesViewController:  NSFetchedResultsControllerDelegate {
    
}
