//
//  MultipartResponseParser.swift
//  Founders
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import Foundation

class MultipartResponseParser {
    
    static func parse(data: Data, boundary: String) throws -> [MultipartPart] {
        guard let fullString = String(data: data, encoding: .utf8) else {
            throw NetworkError.parsingMultipartError
        }
        
        let delimiter = "--" + boundary
        let rawParts = fullString.components(separatedBy: delimiter)
        
        var parts: [MultipartPart] = []
        for rawPart in rawParts {
            let trimmedPart = rawPart.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedPart.isEmpty || trimmedPart == "--" {
                continue
            }
            
            let headerBodySeparator = "\r\n\r\n"
            guard let range = trimmedPart.range(of: headerBodySeparator) else {
                continue
            }
            
            let headerPart = String(trimmedPart[..<range.lowerBound])
            let bodyPart = String(trimmedPart[range.upperBound...])
            
            var headers: [String: String] = [:]
            let headerLines = headerPart.components(separatedBy: "\r\n")
            for line in headerLines {
                let headerComponents = line.components(separatedBy: ":")
                if headerComponents.count >= 2 {
                    let key = headerComponents[0].trimmingCharacters(in: .whitespaces)
                    let value = headerComponents[1...].joined(separator: ":").trimmingCharacters(in: .whitespaces)
                    headers[key] = value
                }
            }
            
            if let bodyData = bodyPart.data(using: .utf8) {
                let part = MultipartPart(headers: headers, body: bodyData)
                parts.append(part)
            }
        }
        
        return parts
    }
    
    static func extractBoundary(from contentType: String) -> String? {
        let components = contentType.components(separatedBy: ";")
        for component in components {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("boundary=") {
                return String(trimmed.dropFirst("boundary=".count))
            }
        }
        return nil
    }
}
