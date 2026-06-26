import XCTest
@testable import LectureHSE1

final class FavoriteNewsUseCasesTests: XCTestCase {

    func testFetchFavoriteNewsUseCaseReturnsRepositoryItems() throws {
        let news = makeNews(title: "Saved")
        let repository = FakeFavoriteNewsRepository(favorites: [news])
        let useCase = FetchFavoriteNewsUseCase(repository: repository)

        let result = try useCase.execute()

        XCTAssertEqual(result, [news])
        XCTAssertEqual(repository.fetchCalls, 1)
    }

    func testIsFavoriteNewsUseCaseDelegatesToRepository() throws {
        let news = makeNews(url: "https://example.com/favorite")
        let repository = FakeFavoriteNewsRepository(favorites: [news])
        let useCase = IsFavoriteNewsUseCase(repository: repository)

        let result = try useCase.execute(news: news)

        XCTAssertTrue(result)
        XCTAssertEqual(repository.lastCheckedIdentifier, news.cacheIdentifier)
    }

    func testToggleFavoriteNewsUseCaseAddsAndRemovesNews() throws {
        let news = makeNews(title: "Toggle")
        let repository = FakeFavoriteNewsRepository()
        let useCase = ToggleFavoriteNewsUseCase(repository: repository)

        XCTAssertEqual(try useCase.execute(news: news), [news])
        XCTAssertEqual(try useCase.execute(news: news), [])
    }
}

private final class FakeFavoriteNewsRepository: FavoriteNewsRepositoryProtocol {
    private var favorites: [New]
    private(set) var fetchCalls = 0
    private(set) var lastCheckedIdentifier: String?

    init(favorites: [New] = []) {
        self.favorites = favorites
    }

    func fetchFavorites() throws -> [New] {
        fetchCalls += 1
        return favorites
    }

    func isFavorite(_ news: New) throws -> Bool {
        lastCheckedIdentifier = news.cacheIdentifier
        return favorites.contains { $0.cacheIdentifier == news.cacheIdentifier }
    }

    func toggleFavorite(_ news: New) throws -> [New] {
        if favorites.contains(where: { $0.cacheIdentifier == news.cacheIdentifier }) {
            favorites.removeAll { $0.cacheIdentifier == news.cacheIdentifier }
        } else {
            favorites.insert(news, at: 0)
        }

        return favorites
    }

    func removeFavorite(_ news: New) throws -> [New] {
        favorites.removeAll { $0.cacheIdentifier == news.cacheIdentifier }
        return favorites
    }
}

private func makeNews(
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
        updatedDate: .distantPast,
        createdDate: .distantPast,
        publishedDate: .distantPast,
        relatedUrls: nil,
        multimedia: nil
    )
}
