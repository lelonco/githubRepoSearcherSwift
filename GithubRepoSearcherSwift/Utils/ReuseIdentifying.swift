//
//  ReuseIdentifying.swift
//  GithubRepoSearcherSwift
//
//  Created by Yaroslav on 16.01.2021.
//

import Foundation

protocol ReuseIdentifying {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
