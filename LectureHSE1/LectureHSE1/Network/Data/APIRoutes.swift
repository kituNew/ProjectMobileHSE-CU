//
//  APIRoutes.swift
//  Founders
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import Foundation

struct APIRoutes {
    let baseURL = URL(string: "https://api.nytimes.com")
    let getNews: String = "/svc/search/v2/articlesearch.json"
}
