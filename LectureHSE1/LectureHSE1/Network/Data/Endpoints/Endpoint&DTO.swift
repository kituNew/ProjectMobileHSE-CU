//
//  Endpoint&DTO.swift
//  Founders
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//


import Foundation

protocol Endpoint {
    var baseURL: URL? { get }
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
}

protocol RequestDTO: Encodable {}
protocol ResponseDTO: Decodable {}
