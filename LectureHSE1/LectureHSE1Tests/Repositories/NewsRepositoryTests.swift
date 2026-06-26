import CoreData
import UIKit
import XCTest
@testable import LectureHSE1

final class NewsRepositoryTests: XCTestCase {

    func testSearchNewsDelegatesToRemoteAndSavesCacheForNormalizedQuery() async throws {
        let coreDataStack = CoreDataStack(inMemory: true)
        let remoteDataSource = FakeNewsRemoteDataSource(
            news: [makeTestNews(title: "Cached")]
        )
        let repository = NewsRepository(
            remoteDataSource: remoteDataSource,
            coreDataStack: coreDataStack
        )

        let news = try await repository.searchNews(query: " Beer ")

        XCTAssertEqual(remoteDataSource.lastQuery, " Beer ")
        XCTAssertEqual(news.map(\.title), ["Cached"])

        let request = NSFetchRequest<NSManagedObject>(
            entityName: CoreDataEntity.cachedNews
        )
        request.predicate = NSPredicate(format: "query == %@", "beer")
        let cachedObjects = try coreDataStack.viewContext.fetch(request)
        let payload = try XCTUnwrap(cachedObjects.first?.value(forKey: "payload") as? Data)
        let cachedNews = try JSONDecoder().decode(New.self, from: payload)

        XCTAssertEqual(cachedObjects.count, 1)
        XCTAssertEqual(cachedNews.title, "Cached")
    }

    func testSearchNewsReplacesOldCacheForSameQuery() async throws {
        let coreDataStack = CoreDataStack(inMemory: true)
        let remoteDataSource = FakeNewsRemoteDataSource(
            news: [makeTestNews(title: "First")]
        )
        let repository = NewsRepository(
            remoteDataSource: remoteDataSource,
            coreDataStack: coreDataStack
        )

        _ = try await repository.searchNews(query: "beer")
        remoteDataSource.news = [makeTestNews(title: "Second")]
        _ = try await repository.searchNews(query: "beer")

        let request = NSFetchRequest<NSManagedObject>(
            entityName: CoreDataEntity.cachedNews
        )
        request.predicate = NSPredicate(format: "query == %@", "beer")
        let cachedObjects = try coreDataStack.viewContext.fetch(request)
        let payload = try XCTUnwrap(cachedObjects.first?.value(forKey: "payload") as? Data)
        let cachedNews = try JSONDecoder().decode(New.self, from: payload)

        XCTAssertEqual(cachedObjects.count, 1)
        XCTAssertEqual(cachedNews.title, "Second")
    }

    func testLoadImageDelegatesToRemoteDataSource() async {
        let image = UIImage()
        let remoteDataSource = FakeNewsRemoteDataSource(
            news: [],
            image: image
        )
        let repository = NewsRepository(
            remoteDataSource: remoteDataSource,
            coreDataStack: CoreDataStack(inMemory: true)
        )

        let result = await repository.loadImage(urlString: "https://example.com/image.png")

        XCTAssertIdentical(result, image)
        XCTAssertEqual(remoteDataSource.lastImageUrl, "https://example.com/image.png")
    }
}

private final class FakeNewsRemoteDataSource: NewsRemoteDataSourceProtocol {
    var news: [New]
    let image: UIImage?
    private(set) var lastQuery: String?
    private(set) var lastImageUrl: String?

    init(news: [New], image: UIImage? = nil) {
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
