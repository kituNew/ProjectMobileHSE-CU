//
//  NewsResponseDTO.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import Foundation

struct NewsResponseDTO: Codable {
    let status: String
    let copyright: String
    let response: NewsSearchResponseDTO
}

struct NewsSearchResponseDTO: Codable {
    let docs: [NewsItemDTO]
    let metadata: NewsMetadataDTO?
}

struct NewsMetadataDTO: Codable {
    let hits: Int?
    let offset: Int?
    let time: Int?
}

struct NewsItemDTO: Codable {
    let id: String?
    let abstract: String?
    let snippet: String?
    let webUrl: String?
    let source: String?
    let pubDate: String?
    let sectionName: String?
    let subsectionName: String?
    let headline: HeadlineDTO?
    let byline: BylineDTO?
    let multimedia: MultimediaDTO?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case abstract
        case snippet
        case webUrl = "web_url"
        case source
        case pubDate = "pub_date"
        case sectionName = "section_name"
        case subsectionName = "subsection_name"
        case headline
        case byline
        case multimedia
        case uri
    }
}

struct HeadlineDTO: Codable {
    let main: String?
    let kicker: String?
    let printHeadline: String?

    enum CodingKeys: String, CodingKey {
        case main
        case kicker
        case printHeadline = "print_headline"
    }
}

struct BylineDTO: Codable {
    let original: String?
}

struct MultimediaDTO: Codable {
    let caption: String?
    let credit: String?
    let defaultImage: MultimediaImageDTO?
    let thumbnail: MultimediaImageDTO?

    enum CodingKeys: String, CodingKey {
        case caption
        case credit
        case defaultImage = "default"
        case thumbnail
    }
}

struct MultimediaImageDTO: Codable {
    let url: String?
    let height: Int?
    let width: Int?
}
