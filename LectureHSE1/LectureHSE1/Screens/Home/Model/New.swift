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
    let updatedDate: Date
    let createdDate: Date
    let publishedDate: Date

    let relatedUrls: [RelatedUrl]?
    let multimedia: [Multimedia]?
    
    init(section: String, subsection: String, title: String, abstract: String, byline: String, source: String, updatedDate: Date, createdDate: Date, publishedDate: Date, relatedUrls: [RelatedUrl]?, multimedia: [Multimedia]?) {
        self.section = section
        self.subsection = subsection
        self.title = title
        self.abstract = abstract
        self.byline = byline
        self.source = source
        self.updatedDate = updatedDate
        self.createdDate = createdDate
        self.publishedDate = publishedDate
        self.relatedUrls = relatedUrls
        self.multimedia = multimedia
    }
    
    init(news: NewsItemDTO) {
        self.section = news.section ?? ""
        self.subsection = news.subsection ?? ""
        self.title = news.title ?? ""
        self.abstract = news.abstract ?? ""
        self.byline = news.byline ?? ""
        self.source = news.source ?? ""

        self.updatedDate = Self.parseISODate(news.updatedDate)
        self.createdDate = Self.parseISODate(news.createdDate)
        self.publishedDate = Self.parseISODate(news.publishedDate)

        self.relatedUrls = news.relatedUrls?.map {
            RelatedUrl(suggestedLinkText: $0.suggestedLinkText, url: $0.url)
        }

        self.multimedia = news.multimedia?.map {
            Multimedia(url: $0.url, height: $0.height, width: $0.width, caption: $0.caption)
        }
    }

    private static func parseISODate(_ value: String?) -> Date {
        guard let value, !value.isEmpty else { return .distantPast }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        if let d = f2.date(from: value) { return d }

        return .distantPast
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
