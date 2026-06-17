import UIKit
import XCTest
@testable import LectureHSE1

final class NewsUseCasesTests: XCTestCase {

    func testSearchNewsUseCaseDelegatesQueryToRepository() async throws {
        let repository = FakeNewsRepository()
        let useCase = SearchNewsUseCase(repository: repository)

        let result = try await useCase.execute(query: "beer")

        XCTAssertEqual(repository.lastQuery, "beer")
        XCTAssertEqual(result, repository.news)
    }

    func testLoadNewsImageUseCaseReturnsRepositoryImage() async {
        let image = UIImage()
        let repository = FakeNewsRepository(image: image)
        let useCase = LoadNewsImageUseCase(repository: repository)

        let result = await useCase.execute(urlString: "https://example.com/image.png")

        XCTAssertIdentical(result, image)
        XCTAssertEqual(repository.lastImageUrl, "https://example.com/image.png")
    }
}

private final class FakeNewsRepository: NewsRepositoryProtocol {
    let news: [New]
    let image: UIImage?

    private(set) var lastQuery: String?
    private(set) var lastImageUrl: String?

    init(
        news: [New] = [
            New(
                section: "Food",
                subsection: "Drinks",
                title: "Beer story",
                abstract: "Abstract",
                byline: "Byline",
                source: "NYT",
                url: "https://example.com",
                updatedDate: .distantPast,
                createdDate: .distantPast,
                publishedDate: .distantPast,
                relatedUrls: nil,
                multimedia: nil
            )
        ],
        image: UIImage? = nil
    ) {
        self.news = news
        self.image = image
    }

    func searchNews(query: String) async throws -> [New] {
        lastQuery = query
        return news
    }

    func loadImage(urlString: String?) async -> UIImage? {
        lastImageUrl = urlString
        return image
    }
}
