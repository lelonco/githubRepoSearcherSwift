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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(RepostiryTableViewCell.self, forCellReuseIdentifier: "Celll\(didSearchModeEnabled)")
        self.tableView.separatorStyle = .none
        view.backgroundColor = .white
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
        guard let text = searchBar.text else {
            return
        }
        do {
            try searchviewModel?.fetchRepos(searchText: text)
        } catch {
            print(error.localizedDescription)
        }
//        findFakeRepos()
//        findRepos()

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? RepostiryTableViewCell else {
            assertionFailure("Cant get cell")
            return UITableViewCell()
        }

        let viewModel = searchviewModel?.cellviewModel(for: indexPath)
        cell.repositoryviewModel = viewModel

        return cell
    }
}

extension SearchRepositoriesViewController: NSFetchedResultsControllerDelegate {
}
