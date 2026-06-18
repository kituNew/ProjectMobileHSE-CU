import UIKit

protocol FavoritesRouting {
    func showNewsDetails(_ news: New, imageLoader: LoadNewsImageUseCaseProtocol)
}

final class FavoritesRouter: FavoritesRouting {
    weak var viewController: UIViewController?
    private let isFavoriteUseCase: IsFavoriteNewsUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteNewsUseCaseProtocol

    init(
        isFavoriteUseCase: IsFavoriteNewsUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteNewsUseCaseProtocol
    ) {
        self.isFavoriteUseCase = isFavoriteUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }

    func showNewsDetails(_ news: New, imageLoader: LoadNewsImageUseCaseProtocol) {
        let detailRouter = NewsDetailRouter()
        let detailsVC = NewDetailView(
            new: news,
            imageLoader: imageLoader,
            isFavoriteUseCase: isFavoriteUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            router: detailRouter
        )
        detailRouter.viewController = detailsVC
        viewController?.navigationController?.pushViewController(detailsVC, animated: true)
    }
}
