import UIKit
import XCTest
@testable import LectureHSE1

final class FavoritesPresenterTests: XCTestCase {

    func testViewWillAppearShowsFavorites() {
        let favorites = [makeTestNews(title: "Favorite")]
        let view = FakeFavoritesView()
        let presenter = FavoritesPresenter(
            fetchFavoriteNewsUseCase: FakeFetchFavoriteNewsUseCase(favorites: favorites),
            toggleFavoriteNewsUseCase: FakeToggleFavoriteNewsUseCase(),
            loadImageUseCase: FakeFavoriteImageUseCase(),
            router: FakeFavoritesRouter()
        )
        presenter.view = view

        presenter.viewWillAppear()

        XCTAssertEqual(view.favorites, favorites)
    }

    func testToggleFavoriteShowsUpdatedFavorites() {
        let news = makeTestNews(title: "Favorite")
        let view = FakeFavoritesView()
        let presenter = FavoritesPresenter(
            fetchFavoriteNewsUseCase: FakeFetchFavoriteNewsUseCase(),
            toggleFavoriteNewsUseCase: FakeToggleFavoriteNewsUseCase(favorites: [news]),
            loadImageUseCase: FakeFavoriteImageUseCase(),
            router: FakeFavoritesRouter()
        )
        presenter.view = view

        presenter.toggleFavorite(news)

        XCTAssertEqual(view.favorites, [news])
    }

    func testToggleFavoriteShowsErrorWhenUseCaseThrows() {
        let view = FakeFavoritesView()
        let presenter = FavoritesPresenter(
            fetchFavoriteNewsUseCase: FakeFetchFavoriteNewsUseCase(),
            toggleFavoriteNewsUseCase: FakeToggleFavoriteNewsUseCase(error: TestError.expected),
            loadImageUseCase: FakeFavoriteImageUseCase(),
            router: FakeFavoritesRouter()
        )
        presenter.view = view

        presenter.toggleFavorite(makeTestNews())

        XCTAssertEqual(view.errorMessage, TestError.expected.localizedDescription)
    }

    func testSelectNewsRoutesToDetails() {
        let router = FakeFavoritesRouter()
        let imageUseCase = FakeFavoriteImageUseCase()
        let presenter = FavoritesPresenter(
            fetchFavoriteNewsUseCase: FakeFetchFavoriteNewsUseCase(),
            toggleFavoriteNewsUseCase: FakeToggleFavoriteNewsUseCase(),
            loadImageUseCase: imageUseCase,
            router: router
        )
        let news = makeTestNews(title: "Selected")

        presenter.selectNews(news)

        XCTAssertEqual(router.selectedNews, news)
        XCTAssertTrue(router.imageLoader as? FakeFavoriteImageUseCase === imageUseCase)
    }
}

private final class FakeFavoritesView: FavoritesViewProtocol {
    private(set) var favorites: [New] = []
    private(set) var errorMessage: String?

    func showFavorites(_ favorites: [New]) {
        self.favorites = favorites
    }

    func showError(_ message: String) {
        errorMessage = message
    }
}

private final class FakeFetchFavoriteNewsUseCase: FetchFavoriteNewsUseCaseProtocol {
    let favorites: [New]
    let error: Error?

    init(favorites: [New] = [], error: Error? = nil) {
        self.favorites = favorites
        self.error = error
    }

    func execute() throws -> [New] {
        if let error {
            throw error
        }
        return favorites
    }
}

private final class FakeToggleFavoriteNewsUseCase: ToggleFavoriteNewsUseCaseProtocol {
    let favorites: [New]
    let error: Error?

    init(favorites: [New] = [], error: Error? = nil) {
        self.favorites = favorites
        self.error = error
    }

    func execute(news: New) throws -> [New] {
        if let error {
            throw error
        }
        return favorites
    }
}

private final class FakeFavoriteImageUseCase: LoadNewsImageUseCaseProtocol {
    func execute(urlString: String?) async -> UIImage? {
        nil
    }
}

private final class FakeFavoritesRouter: FavoritesRouting {
    private(set) var selectedNews: New?
    private(set) var imageLoader: LoadNewsImageUseCaseProtocol?

    func showNewsDetails(_ news: New, imageLoader: LoadNewsImageUseCaseProtocol) {
        selectedNews = news
        self.imageLoader = imageLoader
    }
}
