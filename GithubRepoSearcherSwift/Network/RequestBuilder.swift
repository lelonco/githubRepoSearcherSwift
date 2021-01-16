//
//  RequestBuilder.swift
//  TestApi
//
//  Created by Yaroslav on 14.12.2020.
//

import Foundation

enum SortingType: String {
    case asc
    case desc
}

class RequestBuilder {

    static func searchRepo(text: String) -> GitApiRequest {
        let gitApi = GitApiRequest(endPoint: "search/repositories")
        let perPage = 50
        let queryparam = ["q": text, "sort": "stars", "order": "desc", "per_page": "\(perPage)"]
        gitApi.queryParam = queryparam
        return gitApi
    }
}
