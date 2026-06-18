import UIKit

protocol FavoritesViewProtocol: AnyObject {
    func showFavorites(_ favorites: [New])
    func showError(_ message: String)
}

protocol FavoritesPresenting: AnyObject {
    func viewWillAppear()
    func selectNews(_ news: New)
    func toggleFavorite(_ news: New)
    func loadImage(urlString: String?) async -> UIImage?
}

final class FavoritesPresenter: FavoritesPresenting {
    weak var view: FavoritesViewProtocol?

    private let fetchFavoriteNewsUseCase: FetchFavoriteNewsUseCaseProtocol
    private let toggleFavoriteNewsUseCase: ToggleFavoriteNewsUseCaseProtocol
    private let loadImageUseCase: LoadNewsImageUseCaseProtocol
    private let router: FavoritesRouting

    init(
        fetchFavoriteNewsUseCase: FetchFavoriteNewsUseCaseProtocol,
        toggleFavoriteNewsUseCase: ToggleFavoriteNewsUseCaseProtocol,
        loadImageUseCase: LoadNewsImageUseCaseProtocol,
        router: FavoritesRouting
    ) {
        self.fetchFavoriteNewsUseCase = fetchFavoriteNewsUseCase
        self.toggleFavoriteNewsUseCase = toggleFavoriteNewsUseCase
        self.loadImageUseCase = loadImageUseCase
        self.router = router
    }

    func viewWillAppear() {
        reloadFavorites()
    }

    func selectNews(_ news: New) {
        router.showNewsDetails(news, imageLoader: loadImageUseCase)
    }

    func toggleFavorite(_ news: New) {
        do {
            let favorites = try toggleFavoriteNewsUseCase.execute(news: news)
            view?.showFavorites(favorites)
        } catch {
            view?.showError(error.localizedDescription)
        }
    }

    func loadImage(urlString: String?) async -> UIImage? {
        await loadImageUseCase.execute(urlString: urlString)
    }

    private func reloadFavorites() {
        do {
            view?.showFavorites(try fetchFavoriteNewsUseCase.execute())
        } catch {
            view?.showError(error.localizedDescription)
        }
    }
}
