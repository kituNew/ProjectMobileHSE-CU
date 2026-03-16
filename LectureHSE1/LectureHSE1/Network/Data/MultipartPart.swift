//
//  MultipartPart.swift
//  Founders
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//


import Foundation

struct MultipartPart {
    let headers: [String: String]
    let body: Data
}
