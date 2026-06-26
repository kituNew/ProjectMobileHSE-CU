import Foundation

protocol FetchFavoriteNewsUseCaseProtocol {
    func execute() throws -> [New]
}

final class FetchFavoriteNewsUseCase: FetchFavoriteNewsUseCaseProtocol {
    private let repository: FavoriteNewsRepositoryProtocol

    init(repository: FavoriteNewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> [New] {
        try repository.fetchFavorites()
    }
}

protocol IsFavoriteNewsUseCaseProtocol {
    func execute(news: New) throws -> Bool
}

final class IsFavoriteNewsUseCase: IsFavoriteNewsUseCaseProtocol {
    private let repository: FavoriteNewsRepositoryProtocol

    init(repository: FavoriteNewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(news: New) throws -> Bool {
        try repository.isFavorite(news)
    }
}

protocol ToggleFavoriteNewsUseCaseProtocol {
    @discardableResult
    func execute(news: New) throws -> [New]
}

final class ToggleFavoriteNewsUseCase: ToggleFavoriteNewsUseCaseProtocol {
    private let repository: FavoriteNewsRepositoryProtocol

    init(repository: FavoriteNewsRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    func execute(news: New) throws -> [New] {
        try repository.toggleFavorite(news)
    }
}
