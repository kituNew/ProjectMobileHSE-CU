//
//  NewsEndpoint.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import Foundation

struct NewsEndpoint: Endpoint {
    var baseURL = APIRoutes().baseURL

    var path = APIRoutes().getNews

    var method = HTTPMethod.get

    var headers: [String: String]?
    
    var queryParameters: [String: String]?
    
    init(query: String) {
        queryParameters = [
            "q": query,
            "api-key": "gAyEnGAME1VzDKDEVj4HHrm8W51m0QmXIaJDIn9JCLXzcm4u"
        ]
    }

}
