import XCTest
@testable import LectureHSE1

final class NewsEndpointTests: XCTestCase {

    func testNewsEndpointBuildsArticleSearchRoute() throws {
        let endpoint = NewsEndpoint(query: "craft beer")

        XCTAssertEqual(endpoint.baseURL?.absoluteString, "https://api.nytimes.com")
        XCTAssertEqual(endpoint.path, "/svc/search/v2/articlesearch.json")
        XCTAssertEqual(endpoint.method, HTTPMethod.get)
        XCTAssertEqual(endpoint.queryParameters?["q"], "craft beer")
        XCTAssertFalse(endpoint.queryParameters?["api-key"]?.isEmpty ?? true)
    }
}
