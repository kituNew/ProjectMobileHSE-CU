//
//  New.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import Foundation

struct New: Identifiable, Hashable, Codable {
    var id = UUID()
    
    let section: String
    let subsection: String
    let title: String
    let abstract: String
    let byline: String
    let source: String
    let url: String?
    let updatedDate: Date
    let createdDate: Date
    let publishedDate: Date

    let relatedUrls: [RelatedUrl]?
    let multimedia: [Multimedia]?

    var cacheIdentifier: String {
        if let url, !url.isEmpty {
            return url
        }

        return "\(title)|\(publishedDate.timeIntervalSince1970)"
    }
    
    init(section: String, subsection: String, title: String, abstract: String, byline: String, source: String, url: String?, updatedDate: Date, createdDate: Date, publishedDate: Date, relatedUrls: [RelatedUrl]?, multimedia: [Multimedia]?) {
        self.section = section
        self.subsection = subsection
        self.title = title
        self.abstract = abstract
        self.byline = byline
        self.source = source
        self.url = url
        self.updatedDate = updatedDate
        self.createdDate = createdDate
        self.publishedDate = publishedDate
        self.relatedUrls = relatedUrls
        self.multimedia = multimedia
    }
    
    init(news: NewsItemDTO) {
        self.section = news.sectionName ?? ""
        self.subsection = news.subsectionName ?? ""
        self.title = news.headline?.main ?? ""
        self.abstract = news.abstract ?? news.snippet ?? ""
        self.byline = news.byline?.original ?? ""
        self.source = news.source ?? ""
        self.url = news.webUrl

        self.updatedDate = Self.parseISODate(news.pubDate)
        self.createdDate = Self.parseISODate(news.pubDate)
        self.publishedDate = Self.parseISODate(news.pubDate)

        self.relatedUrls = news.webUrl.map {
            [RelatedUrl(suggestedLinkText: news.headline?.main, url: $0)]
        }

        if let image = news.multimedia?.defaultImage ?? news.multimedia?.thumbnail {
            self.multimedia = [
                Multimedia(
                    url: Self.normalizedImageURL(image.url),
                    height: image.height,
                    width: image.width,
                    caption: news.multimedia?.caption
                )
            ]
        } else {
            self.multimedia = nil
        }
    }

    private static func parseISODate(_ value: String?) -> Date {
        guard let value, !value.isEmpty else { return .distantPast }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        if let d = f2.date(from: value) { return d }

        return .distantPast
    }

    private static func normalizedImageURL(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        if value.hasPrefix("http://") || value.hasPrefix("https://") {
            return value
        }
        return "https://www.nytimes.com/" + value
    }
}

struct RelatedUrl: Hashable, Codable {
    let suggestedLinkText: String?
    let url: String?
}

struct Multimedia: Hashable, Codable {
    let url: String?
    let height: Int?
    let width: Int?
    let caption: String?
}
