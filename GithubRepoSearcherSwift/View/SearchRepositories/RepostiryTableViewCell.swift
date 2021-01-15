//
//  RepostiryTableViewCell.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 08.01.2021.
//

import Foundation
import UIKit
class RepostiryTableViewCell: UITableViewCell {

    var repositoryviewModel: CellViewModel? = nil {
        didSet {
            self.textLabel?.text = self.repositoryviewModel?.titleText
            self.detailTextLabel?.text = self.repositoryviewModel?.subtitleText
            self.accessoryView = configureAccessoryView()
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureAccessoryView() -> UIView? {
        guard let stars = self.repositoryviewModel?.starsCount else { return nil }

        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.setTitle(String(stars), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.imageView?.tintColor = .green
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.isUserInteractionEnabled = false
        button.sizeToFit()

        return button
    }
}
