//
//  MultipartFormData.swift
//  Founders
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//


import Foundation

class MultipartFormData {
    private let boundary: String
    private var data: Data

    init() {
        self.boundary = UUID().uuidString
        self.data = Data()
    }

    func append(_ value: String, forKey key: String) {
        guard let boundaryData = "--\(boundary)\r\n".data(using: .utf8),
              let dispositionData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8),
              let valueData = "\(value)\r\n".data(using: .utf8)
        else { return }
        
        data.append(boundaryData)
        data.append(dispositionData)
        data.append(valueData)
    }

    func append(_ dataPart: Data, forKey key: String, fileName: String, mimeType: String) {
        guard let boundaryData = "--\(boundary)\r\n".data(using: .utf8),
              let dispositionData = "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8),
              let typeData = "Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8),
              let endingData = "\r\n".data(using: .utf8)
        else { return }
        
        data.append(boundaryData)
        data.append(dispositionData)
        data.append(typeData)
        data.append(dataPart)
        data.append(endingData)
    }

    func finish() -> Data {
        guard let endingBoundary = "--\(boundary)--\r\n".data(using: .utf8) else { return data }
        data.append(endingBoundary)
        return data
    }

    func contentType() -> String {
        return "multipart/form-data; boundary=\(boundary)"
    }
}
