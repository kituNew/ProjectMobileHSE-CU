import XCTest
@testable import LectureHSE1

final class NewsRemoteDataSourceTests: XCTestCase {

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testSearchNewsRequestsNYTAndMapsDocsToNews() async throws {
        var capturedURL: URL?
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (
                try XCTUnwrap(response),
                Data(Self.nytResponseJSON.utf8)
            )
        }
        let dataSource = NewsRemoteDataSource(
            networkService: NetworkService(session: makeMockedURLSession())
        )

        let news = try await dataSource.searchNews(query: "beer")

        let components = try XCTUnwrap(
            URLComponents(url: try XCTUnwrap(capturedURL), resolvingAgainstBaseURL: false)
        )
        XCTAssertEqual(components.path, "/svc/search/v2/articlesearch.json")
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "q" })?.value, "beer")
        XCTAssertEqual(news.count, 1)
        XCTAssertEqual(news.first?.title, "Beer story")
        XCTAssertEqual(news.first?.abstract, "Snippet")
        XCTAssertEqual(news.first?.source, "The New York Times")
        XCTAssertEqual(news.first?.multimedia?.first?.url, "https://www.nytimes.com/images/beer.jpg")
    }

    func testSearchNewsReturnsEmptyArrayWhenDocsAreMissing() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (
                try XCTUnwrap(response),
                Data(#"{"status":"OK","copyright":"","response":{}}"#.utf8)
            )
        }
        let dataSource = NewsRemoteDataSource(
            networkService: NetworkService(session: makeMockedURLSession())
        )

        let news = try await dataSource.searchNews(query: "missing")

        XCTAssertTrue(news.isEmpty)
    }

    private static let nytResponseJSON = """
    {
      "status": "OK",
      "copyright": "",
      "response": {
        "docs": [
          {
            "_id": "nyt-id",
            "abstract": null,
            "snippet": "Snippet",
            "web_url": "https://www.nytimes.com/article",
            "source": "The New York Times",
            "pub_date": "2026-06-18T10:15:00Z",
            "section_name": "Food",
            "subsection_name": "Drinks",
            "headline": {
              "main": "Beer story"
            },
            "byline": {
              "original": "By Test Author"
            },
            "multimedia": {
              "caption": "Caption",
              "default": {
                "url": "images/beer.jpg",
                "height": 600,
                "width": 900
              }
            },
            "uri": "nyt://article/1"
          }
        ],
        "metadata": {
          "hits": 1,
          "offset": 0,
          "time": 1
        }
      }
    }
    """
}
