import UIKit
import XCTest
@testable import LectureHSE1

final class HomePresenterTests: XCTestCase {

    func testSearchShowsLoadingAndNews() async {
        let news = [makeTestNews(title: "Loaded")]
        let searchUseCase = FakeSearchNewsUseCase(news: news)
        let view = FakeHomeView()
        let presenter = HomePresenter(
            searchNewsUseCase: searchUseCase,
            loadImageUseCase: FakeLoadNewsImageUseCase(),
            router: FakeHomeRouter()
        )
        presenter.view = view

        presenter.search(query: " beer ")
        await view.waitForNews()

        XCTAssertTrue(view.didShowLoading)
        XCTAssertEqual(view.news, news)
        XCTAssertEqual(searchUseCase.lastQuery, "beer")
    }

    func testSearchShowsErrorWhenUseCaseThrows() async {
        let searchUseCase = FakeSearchNewsUseCase(error: TestError.expected)
        let view = FakeHomeView()
        let presenter = HomePresenter(
            searchNewsUseCase: searchUseCase,
            loadImageUseCase: FakeLoadNewsImageUseCase(),
            router: FakeHomeRouter()
        )
        presenter.view = view

        presenter.search(query: "beer")
        await view.waitForError()

        XCTAssertTrue(view.didShowLoading)
        XCTAssertEqual(view.errorMessage, TestError.expected.localizedDescription)
    }

    func testSearchIgnoresBlankQuery() async {
        let searchUseCase = FakeSearchNewsUseCase(news: [])
        let presenter = HomePresenter(
            searchNewsUseCase: searchUseCase,
            loadImageUseCase: FakeLoadNewsImageUseCase(),
            router: FakeHomeRouter()
        )

        presenter.search(query: "   ")
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNil(searchUseCase.lastQuery)
    }

    func testSelectNewsRoutesToDetails() {
        let router = FakeHomeRouter()
        let imageUseCase = FakeLoadNewsImageUseCase()
        let presenter = HomePresenter(
            searchNewsUseCase: FakeSearchNewsUseCase(news: []),
            loadImageUseCase: imageUseCase,
            router: router
        )
        let news = makeTestNews(title: "Selected")

        presenter.selectNews(news)

        XCTAssertEqual(router.selectedNews, news)
        XCTAssertTrue(router.imageLoader as? FakeLoadNewsImageUseCase === imageUseCase)
    }
}

private final class FakeHomeView: HomeViewProtocol {
    private var newsContinuation: CheckedContinuation<Void, Never>?
    private var errorContinuation: CheckedContinuation<Void, Never>?

    private(set) var didShowLoading = false
    private(set) var news: [New] = []
    private(set) var errorMessage: String?

    func showLoading() {
        didShowLoading = true
    }

    func showNews(_ news: [New]) {
        self.news = news
        newsContinuation?.resume()
        newsContinuation = nil
    }

    func showError(_ message: String) {
        errorMessage = message
        errorContinuation?.resume()
        errorContinuation = nil
    }

    func waitForNews() async {
        await withCheckedContinuation { continuation in
            if !news.isEmpty {
                continuation.resume()
            } else {
                newsContinuation = continuation
            }
        }
    }

    func waitForError() async {
        await withCheckedContinuation { continuation in
            if errorMessage != nil {
                continuation.resume()
            } else {
                errorContinuation = continuation
            }
        }
    }
}

private final class FakeSearchNewsUseCase: SearchNewsUseCaseProtocol {
    let error: Error?
    var news: [New]
    private(set) var lastQuery: String?

    init(news: [New] = [], error: Error? = nil) {
        self.news = news
        self.error = error
    }

    func execute(query: String) async throws -> [New] {
        lastQuery = query
        if let error {
            throw error
        }
        return news
    }
}

private final class FakeLoadNewsImageUseCase: LoadNewsImageUseCaseProtocol {
    let image: UIImage?
    private(set) var lastUrlString: String?

    init(image: UIImage? = nil) {
        self.image = image
    }

    func execute(urlString: String?) async -> UIImage? {
        lastUrlString = urlString
        return image
    }
}

private final class FakeHomeRouter: HomeRouting {
    private(set) var selectedNews: New?
    private(set) var imageLoader: LoadNewsImageUseCaseProtocol?

    func showNewsDetails(_ news: New, imageLoader: LoadNewsImageUseCaseProtocol) {
        selectedNews = news
        self.imageLoader = imageLoader
    }
}
