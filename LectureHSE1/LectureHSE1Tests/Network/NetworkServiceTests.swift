import Foundation
import XCTest
@testable import LectureHSE1

final class NetworkServiceTests: XCTestCase {

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testRequestBuildsGETRequestWithQueryAndDecodesResponse() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (
                try XCTUnwrap(response),
                Data(#"{"value":"ok"}"#.utf8)
            )
        }
        let service = NetworkService(session: makeMockedURLSession())

        let result: TestResponseDTO = try await service.request(
            endpoint: TestEndpoint(),
            requestDTO: TestRequestDTO()
        )

        let request = try XCTUnwrap(capturedRequest)
        let components = try XCTUnwrap(URLComponents(url: request.url!, resolvingAgainstBaseURL: false))
        XCTAssertEqual(result, TestResponseDTO(value: "ok"))
        XCTAssertEqual(request.httpMethod, HTTPMethod.get)
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "1")
        XCTAssertEqual(components.path, "/v1/items")
        XCTAssertEqual(
            components.queryItems?.first(where: { $0.name == "q" })?.value,
            "beer"
        )
    }

    func testRequestThrowsForNonSuccessStatusCode() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )
            return (try XCTUnwrap(response), Data())
        }
        let service = NetworkService(session: makeMockedURLSession())

        do {
            let _: TestResponseDTO = try await service.request(
                endpoint: TestEndpoint(),
                requestDTO: TestRequestDTO()
            )
            XCTFail("Expected request to throw")
        } catch NetworkError.invalidServerResponseCode(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private struct TestEndpoint: Endpoint {
    let baseURL = URL(string: "https://example.com")
    let path = "/v1/items"
    let method = HTTPMethod.get
    let headers: [String: String]? = ["X-Test": "1"]
    let queryParameters: [String: String]? = ["q": "beer"]
}

private struct TestRequestDTO: RequestDTO {}

private struct TestResponseDTO: Decodable, Equatable {
    let value: String
}
