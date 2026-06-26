import XCTest
@testable import LectureHSE1

final class CoreDataFavoriteNewsRepositoryTests: XCTestCase {

    func testToggleFavoriteStoresFullNewsInCoreData() throws {
        let repository = CoreDataFavoriteNewsRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let news = makeFavoriteNews()

        let favorites = try repository.toggleFavorite(news)

        XCTAssertEqual(favorites, [news])
        XCTAssertTrue(try repository.isFavorite(news))
        XCTAssertEqual(try repository.fetchFavorites(), [news])
    }

    func testToggleFavoriteAgainRemovesNewsFromCoreData() throws {
        let repository = CoreDataFavoriteNewsRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let news = makeFavoriteNews()

        _ = try repository.toggleFavorite(news)
        let favorites = try repository.toggleFavorite(news)

        XCTAssertEqual(favorites, [])
        XCTAssertFalse(try repository.isFavorite(news))
    }

    func testRemoveFavoriteDeletesOnlyRequestedNews() throws {
        let repository = CoreDataFavoriteNewsRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let first = makeFavoriteNews(title: "First", url: "https://example.com/first")
        let second = makeFavoriteNews(title: "Second", url: "https://example.com/second")

        _ = try repository.toggleFavorite(first)
        _ = try repository.toggleFavorite(second)
        let favorites = try repository.removeFavorite(first)

        XCTAssertEqual(favorites, [second])
        XCTAssertFalse(try repository.isFavorite(first))
        XCTAssertTrue(try repository.isFavorite(second))
    }
}

private func makeFavoriteNews(
    title: String = "Beer story",
    url: String? = "https://example.com/news"
) -> New {
    New(
        section: "Food",
        subsection: "Drinks",
        title: title,
        abstract: "Abstract",
        byline: "Byline",
        source: "NYT",
        url: url,
        updatedDate: Date(timeIntervalSince1970: 1),
        createdDate: Date(timeIntervalSince1970: 1),
        publishedDate: Date(timeIntervalSince1970: 1),
        relatedUrls: [RelatedUrl(suggestedLinkText: title, url: url)],
        multimedia: [
            Multimedia(
                url: "https://example.com/image.jpg",
                height: 300,
                width: 500,
                caption: "Caption"
            )
        ]
    )
}
