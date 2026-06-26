import XCTest
@testable import LectureHSE1

final class NewMappingTests: XCTestCase {

    func testNewFromDTOUsesSnippetWhenAbstractIsMissingAndNormalizesImageURL() {
        let dto = NewsItemDTO(
            id: "nyt-id",
            abstract: nil,
            snippet: "Snippet text",
            webUrl: "https://www.nytimes.com/article",
            source: "The New York Times",
            pubDate: "2026-06-18T10:15:00Z",
            sectionName: "Food",
            subsectionName: "Drinks",
            headline: HeadlineDTO(
                main: "Beer story",
                kicker: nil,
                printHeadline: nil
            ),
            byline: BylineDTO(original: "By Test Author"),
            multimedia: MultimediaDTO(
                caption: "Caption",
                credit: nil,
                defaultImage: MultimediaImageDTO(
                    url: "images/2026/06/beer.jpg",
                    height: 600,
                    width: 900
                ),
                thumbnail: nil
            ),
            uri: "nyt://article/1"
        )

        let news = New(news: dto)

        XCTAssertEqual(news.title, "Beer story")
        XCTAssertEqual(news.abstract, "Snippet text")
        XCTAssertEqual(news.byline, "By Test Author")
        XCTAssertEqual(news.source, "The New York Times")
        XCTAssertEqual(news.section, "Food")
        XCTAssertEqual(news.subsection, "Drinks")
        XCTAssertEqual(news.url, "https://www.nytimes.com/article")
        XCTAssertEqual(news.relatedUrls?.first?.url, "https://www.nytimes.com/article")
        XCTAssertEqual(
            news.multimedia?.first?.url,
            "https://www.nytimes.com/images/2026/06/beer.jpg"
        )
        XCTAssertGreaterThan(news.publishedDate.timeIntervalSince1970, 0)
    }

    func testCacheIdentifierFallsBackToTitleAndPublishedDateWhenUrlIsMissing() {
        let date = Date(timeIntervalSince1970: 42)
        let news = New(
            section: "",
            subsection: "",
            title: "Offline story",
            abstract: "",
            byline: "",
            source: "",
            url: nil,
            updatedDate: date,
            createdDate: date,
            publishedDate: date,
            relatedUrls: nil,
            multimedia: nil
        )

        XCTAssertEqual(news.cacheIdentifier, "Offline story|42.0")
    }
}
