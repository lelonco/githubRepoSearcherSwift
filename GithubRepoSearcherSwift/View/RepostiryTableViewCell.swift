//
//  RepostiryTableViewCell.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 08.01.2021.
//

import Foundation
import UIKit

class RepostiryTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
