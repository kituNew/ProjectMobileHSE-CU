import UIKit

protocol HomeViewProtocol: AnyObject {
    func showLoading()
    func showNews(_ news: [New])
    func showError(_ message: String)
}

protocol HomePresenting: AnyObject {
    func viewDidLoad()
    func search(query: String)
    func selectNews(_ news: New)
    func loadImage(urlString: String?) async -> UIImage?
}

final class HomePresenter: HomePresenting {
    weak var view: HomeViewProtocol?

    private let searchNewsUseCase: SearchNewsUseCaseProtocol
    private let loadImageUseCase: LoadNewsImageUseCaseProtocol
    private let router: HomeRouting
    private var currentQuery = "buisness"

    init(
        searchNewsUseCase: SearchNewsUseCaseProtocol,
        loadImageUseCase: LoadNewsImageUseCaseProtocol,
        router: HomeRouting
    ) {
        self.searchNewsUseCase = searchNewsUseCase
        self.loadImageUseCase = loadImageUseCase
        self.router = router
    }

    func viewDidLoad() {
        search(query: currentQuery)
    }

    func search(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        currentQuery = trimmedQuery

        Task { [weak self] in
            guard let self else { return }
            await MainActor.run {
                self.view?.showLoading()
            }

            do {
                let news = try await searchNewsUseCase.execute(query: trimmedQuery)
                await MainActor.run {
                    self.view?.showNews(news)
                }
            } catch {
                await MainActor.run {
                    self.view?.showError(error.localizedDescription)
                }
            }
        }
    }

    func selectNews(_ news: New) {
        router.showNewsDetails(news, imageLoader: loadImageUseCase)
    }

    func loadImage(urlString: String?) async -> UIImage? {
        await loadImageUseCase.execute(urlString: urlString)
    }
}
