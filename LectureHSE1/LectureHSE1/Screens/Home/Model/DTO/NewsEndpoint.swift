//
//  NewsEndpoint.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import Foundation

struct NewsEndpoint: Endpoint {
    var baseURL = APIRoutes().baseURL

    var path = APIRoutes().getNews // /content/{source}/{section}.json

    var method = HTTPMethod.get

    var headers: [String: String]?
    
    var queryParameters: [String: String]?
    
    init (source: String, section: String) {
        path = path
            .replacingOccurrences(of: "{source}", with: source)
            .replacingOccurrences(of: "{section}", with: section)
        queryParameters = ["api-key": "N2vILD3AQxJiSjDq22q3rw0AWbNO3ixUtONDlyGd2JbQjRXe"]
    }

}
