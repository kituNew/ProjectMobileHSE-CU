//
//  NetworkError.swift
//  Founders
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//


import Foundation

enum NetworkError: Error {
    case internalError
    case unknownError
    case emailAlreadyExists
    case weakPassword
    case invalidCredentials
    case unverifiedCredentials
    case invalidServerResponseCode(Int)
    case invalidMultipartResponse
    case parsingMultipartError
}

