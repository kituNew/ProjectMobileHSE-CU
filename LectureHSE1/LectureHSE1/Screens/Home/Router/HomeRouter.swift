import UIKit

protocol HomeRouting {
    func showNewsDetails(_ news: New, imageLoader: LoadNewsImageUseCaseProtocol)
}

final class HomeRouter: HomeRouting {
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
        let router = NewsDetailRouter()
        let detailsVC = NewDetailView(
            new: news,
            imageLoader: imageLoader,
            isFavoriteUseCase: isFavoriteUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            router: router
        )
        router.viewController = detailsVC
        viewController?.navigationController?.pushViewController(detailsVC, animated: true)
    }
}

protocol NewsDetailRouting {
    func openWeb(urlString: String, title: String)
}

final class NewsDetailRouter: NewsDetailRouting {
    weak var viewController: UIViewController?

    func openWeb(urlString: String, title: String) {
        let webVC = WebViewController(url: urlString)
        webVC.title = title
        webVC.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(webVC, animated: true)
    }
}
