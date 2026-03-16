//
//  FoundersNetworkService.swift
//  Founders
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import Foundation
import UIKit
import CryptoKit

final class NetworkService {
    private let session: URLSession
    public let localStorageManager: LocalStorageManager
    public let decoder = JSONDecoder()

    init(session: URLSession = .shared, localStorageManager: LocalStorageManager = LocalStorageManager()) {
        self.session = session
        self.localStorageManager = localStorageManager
    }

    func request<Request: Encodable, Response: Decodable>(
        endpoint: Endpoint,
        requestDTO: Request
    ) async throws -> Response {
        let urlRequest = try createURLRequest(
            endpoint: endpoint,
            requestDTO: requestDTO
        )
        
        let (data, response) = try await session.data(for: urlRequest)

        try validateResponse(response)

        return try parseResponse(data: data)
    }

    private func createURLRequest<Request: Encodable>(
        endpoint: Endpoint,
        requestDTO: Request
    ) throws -> URLRequest {
        guard let baseURL = endpoint.baseURL else {
            throw NetworkError.internalError
        }

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint.path

        guard var components = urlComponents else {
            throw NetworkError.internalError
        }

        applyQueryParameters(to: &components, queryParameters: endpoint.queryParameters)

        guard let url = components.url else {
            throw NetworkError.internalError
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method

        applyHeaders(to: &urlRequest, headers: endpoint.headers)

        if endpoint.method != HTTPMethod.get {
            try configureRequestBody(
                for: &urlRequest,
                requestDTO: requestDTO
            )
        }

        return urlRequest
    }
    
    private func applyHeaders(to request: inout URLRequest, headers: [String: String]?) {
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
    private func applyQueryParameters(to urlComponents: inout URLComponents, queryParameters: [String: String]?) {
        guard let queryParameters = queryParameters, !queryParameters.isEmpty else { return }
        
        let queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
    }

    private func configureRequestBody<Request: Encodable>(
        for request: inout URLRequest,
        requestDTO: Request
    ) throws {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestDTO)
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }

        let statusCode = httpResponse.statusCode

        if !(200...299).contains(statusCode) {
            throw NetworkError.invalidServerResponseCode(statusCode)
        }
    }

    private func parseResponse<Response: Decodable>(
        data: Data
    ) throws -> Response {
        return try decoder.decode(Response.self, from: data)
    }
    
    func downloadImage(from url: URL) async throws -> UIImage {
        if let cachedImage = try? fetchImageFromCache(url: url) {
            return cachedImage
        }
        
        let (tempLocalUrl, response) = try await session.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidServerResponseCode(
                (response as? HTTPURLResponse)?.statusCode ?? 0
            )
        }
        
        let imageData = try Data(contentsOf: tempLocalUrl)
        
        guard let uiImage = UIImage(data: imageData) else {
            throw NetworkError.internalError
        }
        
        try saveImageToCache(uiImage: uiImage, url: url)
        
        return uiImage
    }
    
    func saveImageToCache(uiImage: UIImage, url: URL) throws {
        let cacheKey = generateCacheKey(for: url)
        
        guard let imageData = uiImage.pngData() else {
            throw NetworkError.internalError
        }
        
        try localStorageManager.save(
            imageData,
            forKey: cacheKey,
            storageType: .caches
        )
    }
    
    func fetchImageFromCache(url: URL) throws -> UIImage? {
        let cacheKey = generateCacheKey(for: url)
        
        guard let imageData: Data = try localStorageManager.fetch(
            forKey: cacheKey,
            storageType: .caches
        ) else {
            return nil
        }
        
        guard let uiImage = UIImage(data: imageData) else {
            try? localStorageManager.remove(forKey: cacheKey, storageType: .caches)
            return nil
        }
        
        return uiImage
    }
    
    private func generateCacheKey(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let digest = SHA256.hash(data: data)
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return "image_cache_" + hex
    }
}
