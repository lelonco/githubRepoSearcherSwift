//
//  CachedResultsViewController.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 10.01.2021.
//

import Foundation
import UIKit

class CachedResultsViewController: UITableViewController {

    var cachedResultsViewModel: CachedResultsViewModel?

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        cachedResultsViewModel = CachedResultsViewModel()
        cachedResultsViewModel?.reloadUI = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Cached results"
        tableView.register(RepostiryTableViewCell.self, forCellReuseIdentifier: "Celll")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cachedResultsViewModel?.fetchCachedResults()
    }
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        cachedResultsViewModel?.numberOfSections() ?? 0
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cachedResultsViewModel?.numberOfRowsInSection() ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Celll") as? RepostiryTableViewCell else {
            assertionFailure("Cant get cell")
            return UITableViewCell()
        }

        let viewModel = cachedResultsViewModel?.cellviewModel(for: indexPath)
        cell.repositoryviewModel = viewModel

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let searchviewModel = cachedResultsViewModel?.viewModel(for: indexPath) else { return }
        let viewController = SearchRepositoriesViewController(viewModel: searchviewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
