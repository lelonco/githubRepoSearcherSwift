//
//  SearchRepositoriesViewController.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 03.01.2021.
//

import UIKit
import CoreData

class SearchRepositoriesViewController: UITableViewController {
    var didSearchModeEnabled = true
    var searchviewModel: SearchReposirotiesViewModel? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var previousSearchedText = ""
    
    lazy var searchBar = UISearchBar(frame: .zero)

    init(viewModel: SearchReposirotiesViewModel) {
        super.init(nibName: nil, bundle: nil)
        searchviewModel = viewModel
        didSearchModeEnabled = false
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        searchviewModel = SearchReposirotiesViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        if !didSearchModeEnabled {
            self.title = searchviewModel?.title()
        } else {
            searchBar.placeholder = "Enter repository name"
            self.navigationItem.titleView = searchBar
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                     target: self,
                                                                     action: #selector(makeRequest))
        }
        refreshControl = UIRefreshControl()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(RepostiryTableViewCell.self,
                                forCellReuseIdentifier: RepostiryTableViewCell.reuseIdentifier)
        self.tableView.separatorStyle = .none
        view.backgroundColor = .white
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchviewModel?.reloadUI = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc
    func makeRequest() {
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        previousSearchedText = text
        do {
            self.refreshControl?.beginRefreshing()
            try searchviewModel?.fetchRepos(searchText: text) {
                self.refreshControl?.endRefreshing()
            }
        } catch {
            self.handleError(error)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        searchviewModel?.titleForHeaderInSection(section: section)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        searchviewModel?.numberOfSections() ?? 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchviewModel?.numberOfRowsInSection() ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepostiryTableViewCell.reuseIdentifier) as? RepostiryTableViewCell else {
            assertionFailure("Cant get cell")
            return UITableViewCell()
        }

        let viewModel = searchviewModel?.cellviewModel(for: indexPath)
        cell.repositoryviewModel = viewModel

        return cell
    }

    @objc
    func refresh(sender: UIRefreshControl) {
        guard sender.isRefreshing  else { return }
        if previousSearchedText.isEmpty {
            sender.endRefreshing()
            return 
        }
        do {
            try self.searchviewModel?.fetchRepos(searchText: previousSearchedText, complition: {
                self.refreshControl?.endRefreshing()
            })
        } catch {
            self.handleError(error)
        }
    }

    func handleError(_ error: Error) {
        var messageText: String
        let nsError = error as NSError
        if nsError.code == -999 {
            messageText = nsError.userInfo["message"] as? String ?? ""
        } else {
            messageText = nsError.localizedDescription
        }
        let alertController = UIAlertController(title: "Error", message: messageText, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.refreshControl?.endRefreshing()
        }
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
}
