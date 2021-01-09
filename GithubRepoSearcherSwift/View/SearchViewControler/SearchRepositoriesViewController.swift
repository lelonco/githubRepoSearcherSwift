//
//  SearchRepositoriesViewController.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 03.01.2021.
//

import UIKit
import CoreData

class SearchRepositoriesViewController: UITableViewController {
    var searchVM: SearchReposirotiesViewModel? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    lazy var searchBar = UISearchBar(frame: .zero)
    

    init() {
        super.init(nibName: nil, bundle: nil)
        searchVM = SearchReposirotiesViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        searchBar.placeholder = "Enter repository name"
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(makeRequest))

        super.viewDidLoad()
        self.tableView.register(RepostiryTableViewCell.self, forCellReuseIdentifier: "Celll")
        self.tableView.separatorStyle = .none
        view.backgroundColor = .green
        searchVM?.reloadUI = {
            self.tableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    @objc
    func makeRequest() {
        guard let text = searchBar.text else {
            return
        }
        searchVM?.fetchRepos(searchText: text)
//        findFakeRepos()
//        findRepos()
        
    }


    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        searchVM?.numberOfSections() ?? 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchVM?.numberOfRowsInSection() ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Celll") as? RepostiryTableViewCell
        
        let vm = searchVM?.cellVM(for: indexPath)
        
        cell!.textLabel?.text = vm?.fullName
        cell!.detailTextLabel?.text = vm?.language
        cell!.imageView?.image = UIImage(systemName: "repeat.circle.fill")
        cell?.accessoryView = UIImageView(image: UIImage(systemName: "paperplane.circle.fill"))
        return cell!
    }
}

extension SearchRepositoriesViewController:  NSFetchedResultsControllerDelegate {
    
}
